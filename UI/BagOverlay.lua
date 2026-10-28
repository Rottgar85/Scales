-- Pawn-style arrows on bag item icons: green up for upgrades, red down for downgrades.
local ADDON, ns = ...
local C = ns.C
local B = {}
ns.Bags = B

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
  local verdict
  if (ScalesDB.bagArrows or ScalesDB.bagDown or ScalesDB.bagOther) and bag and slot then
    local link = C.GetContainerItemLink(bag, slot)
    if link then
      local r
      verdict, r = ns.Compare.Verdict(link)
      -- Not better for the active spec, but for another ticked spec: gold arrow (like Pawn).
      -- No result means no equipment (potions, materials), so the other specs are skipped.
      if r and not r.unusable and verdict ~= "up" and ScalesDB.bagOther
        and ns.Compare.UpgradeForOtherSpec(link) then verdict = "other" end
    end
  end
  if verdict == "up" and not ScalesDB.bagArrows then verdict = nil end
  if verdict == "down" and not ScalesDB.bagDown then verdict = nil end
  if verdict then
    local t = GetArrow(button)
    t:SetTexture(verdict == "up" and ns.Style.ARROW_UP or verdict == "other" and ns.Style.ARROW_OTHER or ns.Style.ARROW_DOWN)
    t:Show()
  elseif button.ScalesArrow then
    button.ScalesArrow:Hide()
  end
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

local pending = false
function B.QueueRefresh()
  if pending then return end
  pending = true
  C_Timer.After(0.1, function() pending = false; B.Refresh() end)
end

function B.Init()
  if ContainerFrame_Update then hooksecurefunc("ContainerFrame_Update", B.QueueRefresh) end
  if ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.UpdateItemUpgradeIcon then
    hooksecurefunc(ContainerFrameItemButtonMixin, "UpdateItemUpgradeIcon", B.QueueRefresh)
  end
  if ToggleAllBags then hooksecurefunc("ToggleAllBags", B.QueueRefresh) end
  if OpenAllBags then hooksecurefunc("OpenAllBags", B.QueueRefresh) end
  if ToggleBag then hooksecurefunc("ToggleBag", B.QueueRefresh) end
end
