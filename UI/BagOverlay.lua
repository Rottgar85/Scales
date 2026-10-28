-- Pawn-style arrows on bag item icons: green up for upgrades, red down for downgrades,
-- gold up for upgrades for another ticked spec. Works with the Blizzard bags and the bag addons below
-- (EllesmereUI Bags, Bagnon, ElvUI, Baganator, AdiBags, BetterBags).
local ADDON, ns = ...
local C = ns.C
local B = {}
ns.Bags = B

-- Bag addons repaint every slot on each bag change, so results are cached per link
-- and cleared with every full refresh (re-simulation, option change, item data arriving).
local cache = {}

local function Compute(link)
  local verdict, r = ns.Compare.Verdict(link)
  -- Not better for the active spec, but for another ticked spec: gold arrow (like Pawn).
  -- No result means no equipment (potions, materials), so the other specs are skipped.
  if r and not r.unusable and verdict ~= "up" and ScalesDB.bagOther
    and ns.Compare.UpgradeForOtherSpec(link) then verdict = "other" end
  if verdict == "up" and not ScalesDB.bagArrows then return nil end
  if verdict == "down" and not ScalesDB.bagDown then return nil end
  return verdict
end

-- "up", "down", "other" or nil for an item link, already filtered by the arrow options.
local function ArrowFor(link)
  if not link or not (ScalesDB.bagArrows or ScalesDB.bagDown or ScalesDB.bagOther) then return nil end
  local cached = cache[link]
  if cached ~= nil then return cached or nil end
  local verdict = Compute(link)
  cache[link] = verdict or false
  return verdict
end

local function ShowArrow(t, verdict)
  if verdict then
    t:SetTexture(verdict == "up" and ns.Style.ARROW_UP or verdict == "other" and ns.Style.ARROW_OTHER or ns.Style.ARROW_DOWN)
    t:Show()
  else
    t:Hide()
  end
end

-- Blizzard bags ----------------------------------------------------------------------

local function GetArrow(button)
  if not button.ScalesArrow then
    local t = button:CreateTexture(nil, "OVERLAY", nil, 7)
    t:SetSize(16, 16)
    t:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button.ScalesArrow = t
  end
  return button.ScalesArrow
end

local function UpdateButton(button, bag, slot)
  if not button then return end
  local verdict = bag and slot and ArrowFor(C.GetContainerItemLink(bag, slot))
  if verdict then ShowArrow(GetArrow(button), verdict)
  elseif button.ScalesArrow then button.ScalesArrow:Hide() end
end

function B.Refresh()
  -- Retail combined/individual bags expose EnumerateValidItems on container frames.
  local frames = {}
  if ContainerFrameCombinedBags then frames[#frames + 1] = ContainerFrameCombinedBags end
  for i = 1, (NUM_CONTAINER_FRAMES or 13) do
    local f = _G["ContainerFrame" .. i]
    if f then frames[#frames + 1] = f end
  end
  for _, frame in ipairs(frames) do
    if frame:IsShown() then
      if frame.EnumerateValidItems then
        for _, button in frame:EnumerateValidItems() do
          UpdateButton(button, button:GetBagID(), button:GetID())
        end
      else
        local bag = frame:GetID()
        local name = frame:GetName()
        for j = 1, (frame.size or C.GetContainerNumSlots(bag) or 0) do
          local button = _G[name .. "Item" .. j]
          if button then UpdateButton(button, bag, button:GetID()) end
        end
      end
    end
  end
end


-- Bag addons -------------------------------------------------------------------------
-- Each bag addon tells us through its own hook or API when it updates an item button. A painter draws
-- our arrow on a host frame of that button, remembers the button and its link (weak tables, no state on
-- the addon's secure buttons) and can repaint everything it has seen without the addon redrawing, which
-- is cheap and allowed in combat.

local painters = {}

local function NewPainter(name, point, x, y, size)
  local p = { name = name, arrows = setmetatable({}, { __mode = "k" }),
    seen = setmetatable({}, { __mode = "k" }), calls = 0 }

  function p.Paint(button, host, link)
    p.calls = p.calls + 1
    p.seen[button] = { host = host, link = link }
    local verdict = link and ArrowFor(link)
    local t = p.arrows[button]
    if verdict and not t then
      t = host:CreateTexture(nil, "OVERLAY", nil, 7)
      t:SetSize(size, size)
      t:SetPoint(point, host, point, x, y)
      p.arrows[button] = t
    end
    if t then ShowArrow(t, verdict) end
  end

  -- A Scales error must never break the bag addon's redraw.
  function p.SafePaint(button, host, link)
    if not button or not host then return end
    local ok, err = pcall(p.Paint, button, host, link)
    if not ok then p.lastError = tostring(err) end
  end

  function p.Repaint()
    for button, s in pairs(p.seen) do
      if button:IsVisible() then p.SafePaint(button, s.host, s.link) end
    end
  end

  painters[#painters + 1] = p
  return p
end

-- EllesmereUI Bags: public overlay API. It asks for overlays on btn._textOverlay; the bottom right is
-- where it puts Pawn's arrow, the top left holds its item level text.
local function InitEllesmere()
  local eui = _G.EUI_Bags
  if not (eui and eui.RegisterItemOverlayIcon) then return end
  local p = NewPainter("EllesmereUI Bags", "BOTTOMRIGHT", -1, 1, 18)
  eui.RegisterItemOverlayIcon(ADDON, function(btn, data)
    if btn and btn._textOverlay then p.SafePaint(btn, btn._textOverlay, data and data.itemLink) end
  end)
end

-- Bagnon and the other BagBrother bags: Item:UpdateUpgradeIcon runs on every item update (Bagnon uses it
-- for Pawn). Bagnon copies all class methods onto each button the first time it builds one (Item:Bind
-- caches the list per class), so this hook runs while Scales loads, right after BagBrother (OptionalDeps)
-- and before any Bagnon window exists. Cached method lists are dropped to be safe.
do
  local bb = _G.BagBrother
  if bb and bb.Item and type(bb.Item.UpdateUpgradeIcon) == "function" then
    local p = NewPainter("Bagnon", "TOPLEFT", 0, 0, 16)
    hooksecurefunc(bb.Item, "UpdateUpgradeIcon", function(item)
      p.SafePaint(item, item, item.info and item.info.hyperlink)
    end)
    for _, class in pairs(bb) do
      if type(class) == "table" and rawget(class, "__bindList") then rawset(class, "__bindList", nil) end
    end
  end
end

-- ElvUI bags: B:UpdateSlot(frame, bagID, slotID) updates one slot (ElvUI asks Pawn there too).
local function InitElvUI()
  local E = _G.ElvUI and _G.ElvUI[1]
  local Bags = E and E.GetModule and E:GetModule("Bags", true)
  if not (Bags and type(Bags.UpdateSlot) == "function") then return end
  local p = NewPainter("ElvUI", "TOPLEFT", 1, -1, 16)
  hooksecurefunc(Bags, "UpdateSlot", function(_, frame, bagID, slotID)
    local bag = frame and frame.Bags and frame.Bags[bagID]
    local slot = bag and bag[slotID]
    if slot then p.SafePaint(slot, slot, slot.itemLink) end
  end)
end

-- Baganator: its corner widget API. The corner can be changed in Baganator's settings ("Icon corners").
local function InitBaganator()
  local api = _G.Baganator and _G.Baganator.API
  if not (api and api.RegisterCornerWidget) then return end
  local p = NewPainter("Baganator", "TOPLEFT", 0, 0, 16)
  local ok, err = pcall(api.RegisterCornerWidget, "Scales", "scales_arrow",
    function(corner, details)
      p.calls = p.calls + 1
      local link = details and details.itemLink
      if not link then return false end
      local ok2, verdict = pcall(ArrowFor, link)
      if not ok2 then p.lastError = tostring(verdict); return false end
      if not verdict then return false end
      ShowArrow(corner, verdict)
      return true
    end,
    function(itemButton)
      local t = itemButton:CreateTexture(nil, "OVERLAY", nil, 7)
      t:SetSize(16, 16)
      p.arrows[itemButton] = t
      return t
    end,
    { corner = "top_left", priority = 1 })
  if not ok then p.lastError = tostring(err) end
  -- Baganator redraws its own corners on request.
  p.Repaint = function() if api.RequestItemButtonsRefresh then pcall(api.RequestItemButtonsRefresh) end end
end

-- AdiBags: every button update ends with the message AdiBags_UpdateButton.
local function InitAdiBags()
  local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
  local AceEvent = LibStub and LibStub("AceEvent-3.0", true)
  if not (AceAddon and AceEvent and AceAddon:GetAddon("AdiBags", true)) then return end
  local p = NewPainter("AdiBags", "TOPLEFT", 0, 0, 16)
  local listener = {}
  AceEvent:Embed(listener)
  listener:RegisterMessage("AdiBags_UpdateButton", function(_, button)
    if button then p.SafePaint(button, button, button.itemLink) end
  end)
end

-- BetterBags: every item update ends with the message item/Updated (item, decoration).
local function InitBetterBags()
  local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
  local addon = AceAddon and AceAddon:GetAddon("BetterBags", true)
  local events = addon and addon.GetModule and addon:GetModule("Events", true)
  if not (events and events.RegisterMessage) then return end
  local p = NewPainter("BetterBags", "TOPLEFT", 0, 0, 16)
  events:RegisterMessage("item/Updated", function(_, item, decoration)
    if not item then return end
    local data = item.GetItemData and item:GetItemData()
    local link = data and data.itemInfo and data.itemInfo.itemLink
    p.SafePaint(item, decoration or item.button, link)
  end)
end

-- Queueing ---------------------------------------------------------------------------

local pending, pendingFull = false, false
local function Run()
  pending = false
  B.Refresh()
  if pendingFull then
    pendingFull = false
    for _, p in ipairs(painters) do p.Repaint() end
  end
end

-- After bag changes: the bag addons repaint on their own, only the Blizzard bags need us.
function B.QueueRefresh()
  if pending then return end
  pending = true
  C_Timer.After(0.1, Run)
end

-- After a re-simulation, an option change or new item data: results are stale, our arrows in the bag
-- addons are repainted too.
function B.QueueFullRefresh()
  wipe(cache)
  pendingFull = true
  B.QueueRefresh()
end

-- Item data arrives in bursts (one event per item); refresh once when it has settled.
local infoTimer
function B.QueueItemInfoRefresh()
  if infoTimer then return end
  infoTimer = C_Timer.NewTimer(0.5, function() infoTimer = nil; B.QueueFullRefresh() end)
end

function B.Init()
  if ContainerFrame_Update then hooksecurefunc("ContainerFrame_Update", B.QueueRefresh) end
  if ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.UpdateItemUpgradeIcon then
    hooksecurefunc(ContainerFrameItemButtonMixin, "UpdateItemUpgradeIcon", B.QueueRefresh)
  end
  if ToggleAllBags then hooksecurefunc("ToggleAllBags", B.QueueRefresh) end
  if OpenAllBags then hooksecurefunc("OpenAllBags", B.QueueRefresh) end
  if ToggleBag then hooksecurefunc("ToggleBag", B.QueueRefresh) end
  for _, init in ipairs({ InitEllesmere, InitElvUI, InitBaganator, InitAdiBags, InitBetterBags }) do
    local ok, err = pcall(init)
    if not ok then B.initError = tostring(err) end
  end
end

-- /scales debug: what the bag integration sees, to find out why arrows are missing.
function B.Debug(say)
  if #painters == 0 then say("Bags: Blizzard bags (no supported bag addon found)") end
  for _, p in ipairs(painters) do
    local n, vis = 0, 0
    for _, t in pairs(p.arrows) do n = n + 1; if t:IsVisible() then vis = vis + 1 end end
    say(string.format("%s: updates %d, arrow textures %d, visible %d", p.name, p.calls, n, vis))
    if p.lastError then say("  Last error: " .. p.lastError) end
  end
  if B.initError then say("Bag addon setup error: " .. B.initError) end
  say("Options: green " .. tostring(ScalesDB.bagArrows) .. ", red " .. tostring(ScalesDB.bagDown)
    .. ", gold " .. tostring(ScalesDB.bagOther) .. ", active scale: " .. tostring(ns.archetype))
  -- First few equipment items in the bags, computed fresh (no cache).
  local shown = 0
  for bag = 0, C.NUM_BAGS do
    for slot = 1, (C.GetContainerNumSlots(bag) or 0) do
      local link = C.GetContainerItemLink(bag, slot)
      local equipLoc
      if link then equipLoc = select(4, C.GetItemInfoInstant(link)) end
      if equipLoc and C.SlotsForEquipLoc[equipLoc] and shown < 6 then
        shown = shown + 1
        local verdict, r = ns.Compare.Verdict(link)
        local ok, arrow = pcall(Compute, link)
        say(string.format("  %s: verdict %s, pct %s, arrow %s", link, tostring(verdict),
          r and r.pct and string.format("%.1f", r.pct) or "-", ok and tostring(arrow) or ("ERROR " .. tostring(arrow))))
      end
    end
  end
  if shown == 0 then say("  No equipment found in bags.") end
end
