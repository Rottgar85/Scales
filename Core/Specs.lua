-- All specs of the player's class with name, icon and weights, for the spec bar and the Pawn-style tooltip lines.
local ADDON, ns = ...
local C, L = ns.C, ns.L
local Sp = {}
ns.Specs = Sp

local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local cache

-- Name and icon of spec/talent tree i on every client.
local function Info(i)
  if GetSpecializationInfo then
    local _, name, _, icon = GetSpecializationInfo(i)
    if name then return name, icon end
  end
  if GetTalentTabInfo then
    local r = { GetTalentTabInfo(i) }
    -- Era: (name, icon, pointsSpent, ...); newer classics: (id, name, description, icon, pointsSpent, ...)
    if type(r[1]) == "number" then return r[2], r[4] end
    if r[1] then return r[1], r[2] end
  end
end

-- Number of specs the class has in Gearwise's tables.
function Sp.Count()
  local _, class = UnitClass("player")
  return #(ns.Weights.specMap[class] or {})
end

-- The manual override from /gearwise spec only counts if that spec exists.
function Sp.ActiveIndex()
  local o = GearwiseCharDB and GearwiseCharDB.specOverride
  if o and o >= 1 and o <= Sp.Count() then return o end
  return C.GetSpecIndex()
end

-- { { index, key, weights, name, icon, active }, ... }
function Sp.List()
  if cache then return cache end
  local _, class = UnitClass("player")
  local list = ns.Weights.specMap[class] or {}
  local active = Sp.ActiveIndex()
  cache = {}
  for i = 1, #list do
    local weights, key = ns.Weights.Get(class, i)
    local name, icon = Info(i)
    cache[i] = { index = i, key = key, weights = weights, name = name or L["ARCH_" .. key], icon = icon or FALLBACK_ICON,
      active = i == active }
  end
  return cache
end

function Sp.Invalidate() cache = nil end

-- Specs ticked for the tooltip (per character, default: all).
function Sp.InTooltip(i)
  local t = GearwiseCharDB and GearwiseCharDB.tooltipSpecs
  return not t or t[i] ~= false
end

function Sp.SetInTooltip(i, on)
  GearwiseCharDB.tooltipSpecs = GearwiseCharDB.tooltipSpecs or {}
  GearwiseCharDB.tooltipSpecs[i] = on and true or false
end
