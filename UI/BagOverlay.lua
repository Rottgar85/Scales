-- Pawn-style arrows on bag item icons: green up for upgrades, red down for downgrades,
-- gold up for upgrades for another ticked spec. Works with the Blizzard bags and EllesmereUI Bags.
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

-- EllesmereUI Bags -------------------------------------------------------------------
-- Uses its public overlay API (EUI_Bags.RegisterItemOverlayIcon). As it asks, no state is kept on its
-- secure buttons: our textures hang on btn._textOverlay and are tracked in our own weak table.

local euiArrows = setmetatable({}, { __mode = "k" })
-- Counters for /scales debug.
local stats = { paints = 0, withLink = 0, noHost = 0, arrows = 0 }

local function PaintEUIInner(btn, data)
  stats.paints = stats.paints + 1
  local host = btn._textOverlay
  if not host then stats.noHost = stats.noHost + 1; return end -- EllesmereUI asks for overlays on _textOverlay only
  if data and data.itemLink then stats.withLink = stats.withLink + 1 end
  local verdict = data and data.itemLink and ArrowFor(data.itemLink)
  if verdict then stats.arrows = stats.arrows + 1 end
  local t = euiArrows[btn]
  if verdict and not t then
    t = host:CreateTexture(nil, "OVERLAY", nil, 7)
    t:SetSize(16, 16)
    t:SetPoint("TOPLEFT", host, "TOPLEFT", 1, -1)
    euiArrows[btn] = t
  end
  if t then ShowArrow(t, verdict) end
end

-- EllesmereUI hides painter errors from the player, so they are kept for /scales debug.
local function PaintEUI(btn, data)
  local ok, err = pcall(PaintEUIInner, btn, data)
  if not ok then stats.lastError = tostring(err) end
end

local function RefreshEUI()
  local eui = _G.EUI_Bags
  if eui and eui.RefreshInventory and eui:IsShown() then eui:RefreshInventory() end
end

-- Queueing ---------------------------------------------------------------------------

local pending, pendingFull = false, false
local function Run()
  pending = false
  B.Refresh()
  if pendingFull then pendingFull = false; RefreshEUI() end
end

-- After bag changes: the bag addons repaint on their own, only the Blizzard bags need us.
function B.QueueRefresh()
  if pending then return end
  pending = true
  C_Timer.After(0.1, Run)
end

-- After a re-simulation, an option change or new item data: results are stale and bag addons have to repaint too.
function B.QueueFullRefresh()
  wipe(cache)
  pendingFull = true
  B.QueueRefresh()
end

function B.Init()
  if ContainerFrame_Update then hooksecurefunc("ContainerFrame_Update", B.QueueRefresh) end
  if ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.UpdateItemUpgradeIcon then
    hooksecurefunc(ContainerFrameItemButtonMixin, "UpdateItemUpgradeIcon", B.QueueRefresh)
  end
  if ToggleAllBags then hooksecurefunc("ToggleAllBags", B.QueueRefresh) end
  if OpenAllBags then hooksecurefunc("OpenAllBags", B.QueueRefresh) end
  if ToggleBag then hooksecurefunc("ToggleBag", B.QueueRefresh) end
  local eui = _G.EUI_Bags
  if eui and eui.RegisterItemOverlayIcon then eui.RegisterItemOverlayIcon(ADDON, PaintEUI) end
end

-- /scales debug: what the bag integration sees, to find out why arrows are missing.
function B.Debug(say)
  local eui = _G.EUI_Bags
  say("EllesmereUI Bags: " .. (eui and "found" or "not found")
    .. ", API: " .. tostring(eui and eui.RegisterItemOverlayIcon ~= nil)
    .. ", registered: " .. tostring(eui and eui.itemOverlayIcons and eui.itemOverlayIcons[ADDON] == PaintEUI)
    .. ", shown: " .. tostring(eui and eui:IsShown()))
  say(string.format("Paint calls: %d, with item: %d, without overlay frame: %d, arrows: %d",
    stats.paints, stats.withLink, stats.noHost, stats.arrows))
  if stats.lastError then say("Last painter error: " .. stats.lastError) end
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
