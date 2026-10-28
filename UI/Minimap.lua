-- Minimap button like GoldKompass: drag to move around the minimap, left click opens the window,
-- right click the options. In Retail Gearwise is also listed in the addon compartment.
local ADDON, ns = ...
local L = ns.L
local St = ns.Style
local M = {}
ns.Minimap = M

local button

local function Place()
  local a = math.rad(GearwiseDB.minimap.angle or 225)
  local r = (Minimap:GetWidth() or 140) / 2 + 10
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", r * math.cos(a), r * math.sin(a))
end

local function ShowTooltip(owner)
  GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
  GameTooltip:AddLine(St.TITLE)
  local last = ns.Sim.last
  if last and last.value then
    GameTooltip:AddDoubleLine(last.role == "TANK" and L.EHP or (last.role == "HEALER" and L.HPS or L.DPS),
      BreakUpLargeNumbers(math.floor(last.value + 0.5)), 1, 0.82, 0, 1, 1, 1)
  end
  GameTooltip:AddLine(L.MM_LEFT, 1, 1, 1)
  GameTooltip:AddLine(L.MM_RIGHT, 1, 1, 1)
  GameTooltip:AddLine(L.MM_DRAG, 0.6, 0.6, 0.6)
  GameTooltip:Show()
end

local function OnClick(_, btn)
  if btn == "RightButton" then ns.Options.Toggle() else ns.UI.Toggle() end
end

function M.Init()
  local b = CreateFrame("Button", "GearwiseMinimapButton", Minimap)
  button = b
  b:SetSize(31, 31); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(8)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetSize(24, 24); bg:SetPoint("CENTER")
  bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  local icon = b:CreateTexture(nil, "ARTWORK")
  icon:SetSize(21, 21); icon:SetPoint("CENTER", 0, 1)
  icon:SetTexture(St.LOGO)
  local ring = b:CreateTexture(nil, "OVERLAY")
  ring:SetSize(54, 54); ring:SetPoint("TOPLEFT")
  ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:RegisterForDrag("LeftButton")
  b:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local sc = Minimap:GetEffectiveScale()
      GearwiseDB.minimap.angle = math.deg(math.atan2(py / sc - my, px / sc - mx))
      Place()
    end)
  end)
  b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  b:SetScript("OnClick", OnClick)
  b:SetScript("OnEnter", ShowTooltip)
  b:SetScript("OnLeave", GameTooltip_Hide)
  M.Apply()
end

function M.Apply()
  if not button then return end
  Place()
  button:SetShown(not GearwiseDB.minimap.hide)
end

-- Addon compartment (Retail), declared in Gearwise_Mainline.toc.
function Gearwise_OnAddonCompartmentClick(_, btn) OnClick(nil, btn) end
function Gearwise_OnAddonCompartmentEnter(_, frame) ShowTooltip(frame) end
function Gearwise_OnAddonCompartmentLeave() GameTooltip:Hide() end
