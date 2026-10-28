local ADDON, ns = ...
local L = ns.L

local defaults = { tooltip = true, bagArrows = true, bagDown = true, bagOther = true, minUpgradePct = 0.5,
  customWeights = {}, minimap = { hide = false, angle = 225 }, language = "auto" }

-- Language: "auto" follows the game client, "en" or "de" forces it. Applied once at load, so a change needs /reload.
local function ApplyLanguage()
  local lang = ScalesDB.language
  if lang == "de" or (lang ~= "en" and GetLocale() == "deDE") then
    for k, v in pairs(ns.LocaleDE) do L[k] = v end
  end
end

function ns.SetLanguage(lang)
  ScalesDB.language = lang
  print("|cff33ccffScales|r: " .. L.LANG_RELOAD)
end

function ns.UpdateWeights()
  local _, class = UnitClass("player")
  ns.Specs.Invalidate()
  ns.weights, ns.archetype = ns.Weights.Get(class, ns.Specs.ActiveIndex())
end

-- Re-simulates automatically whenever gear, stats, spec or level change (throttled).
-- In combat, buffs distort the stats and Midnight/Forever hide some of them, so it waits until combat ends.
local queued, deferred = false, false
local function Resim()
  if InCombatLockdown() then deferred = true; return end
  deferred = false
  ns.UpdateWeights()
  ns.Compare.InvalidateBudget()
  ns.Sim.Run(ns.weights)
  ns.Bags.QueueRefresh()
  if ns.UI.frame and ns.UI.frame:IsShown() then ns.UI.Refresh() end
end

local function QueueResim()
  if queued then return end
  queued = true
  C_Timer.After(0.2, function() queued = false; Resim() end)
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
ev:RegisterEvent("BAG_UPDATE_DELAYED")
ev:RegisterEvent("GET_ITEM_INFO_RECEIVED")
ev:RegisterEvent("PLAYER_LEVEL_UP")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterUnitEvent("UNIT_STATS", "player")
if C_EventUtils == nil or C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
  pcall(ev.RegisterEvent, ev, "PLAYER_SPECIALIZATION_CHANGED")
end
pcall(ev.RegisterEvent, ev, "CHARACTER_POINTS_CHANGED")

ev:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    ScalesDB = ScalesDB or {}
    for k, v in pairs(defaults) do if ScalesDB[k] == nil then ScalesDB[k] = v end end
    ScalesCharDB = ScalesCharDB or {}
    ApplyLanguage()
  elseif event == "PLAYER_LOGIN" then
    if type(ScalesDB.minimap) ~= "table" then ScalesDB.minimap = { hide = false, angle = 225 } end
    ns.Bags.Init()
    ns.Minimap.Init()
    Resim()
  elseif event == "BAG_UPDATE_DELAYED" or event == "GET_ITEM_INFO_RECEIVED" then
    ns.Bags.QueueRefresh()
  elseif event == "PLAYER_REGEN_ENABLED" then
    if deferred then QueueResim() end
  elseif event ~= "ADDON_LOADED" then
    QueueResim()
  end
end)

SLASH_SCALES1 = "/scales"
SlashCmdList.SCALES = function(msg)
  local cmd, arg = (msg or ""):lower():match("^(%S*)%s*(.-)$")
  if cmd == "" then ns.UI.Toggle()
  elseif cmd == "spec" then
    local n = tonumber(arg)
    if not n or n < 1 or n > ns.Specs.Count() then
      print("|cff33ccffScales|r: " .. L.SPEC .. " 1-" .. ns.Specs.Count())
      return
    end
    ScalesCharDB.specOverride = n
    Resim()
    print("|cff33ccffScales|r: " .. L.SPEC .. " = " .. tostring(L["ARCH_" .. tostring(ns.archetype)]))
  elseif cmd == "arrows" then
    ScalesDB.bagArrows = not ScalesDB.bagArrows
    ScalesDB.bagDown = ScalesDB.bagArrows
    ns.Bags.QueueRefresh()
  elseif cmd == "options" or cmd == "config" then
    ns.Options.Toggle()
  elseif cmd == "minimap" then
    ScalesDB.minimap.hide = not ScalesDB.minimap.hide
    ns.Minimap.Apply()
  elseif cmd == "language" or cmd == "sprache" then
    local lang = ({ en = "en", english = "en", de = "de", deutsch = "de", german = "de", auto = "auto" })[arg]
    if lang then ns.SetLanguage(lang) else print("|cff33ccffScales|r: /scales language en | de | auto") end
  elseif cmd == "reset" then
    ScalesCharDB.specOverride = nil
    ScalesDB.customWeights = {}
    Resim()
  else
    print("|cff33ccffScales|r " .. L.HELP)
  end
end
