-- Shared look for all Gearwise windows, in the style of GoldKompass: flat dark panel, 2 px border,
-- tinted header bar with an accent line, logo in front of the title.
local ADDON, ns = ...
local St = {}
ns.Style = St

St.LOGO = "Interface\\AddOns\\Gearwise\\Media\\Logo"
St.ARROW_UP = "Interface\\AddOns\\Gearwise\\Media\\ArrowUp"
St.ARROW_DOWN = "Interface\\AddOns\\Gearwise\\Media\\ArrowDown"
St.ARROW_OTHER = "Interface\\AddOns\\Gearwise\\Media\\ArrowOther"

St.CYAN = { 0.2, 0.8, 1 }
St.GOLD = { 1, 0.82, 0 }
St.TITLE = "|cff33ccffGear|r|cffffcc00wise|r"
St.GREEN, St.RED, St.GREY, St.ORANGE = "|cff1eff00", "|cffff3030", "|cff999999", "|cffff9900"

local BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2 }
local TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- Movable dark panel with border; closes with Escape when named.
function St.Panel(name, parent, w, h)
  local f = CreateFrame("Frame", name, parent or UIParent, TEMPLATE)
  f:SetSize(w, h)
  f:SetBackdrop(BACKDROP)
  f:SetBackdropColor(0.04, 0.05, 0.08, 0.95)
  f:SetBackdropBorderColor(St.CYAN[1], St.CYAN[2], St.CYAN[3], 1)
  f:SetClampedToScreen(true)
  if name then tinsert(UISpecialFrames, name) end
  return f
end

-- Header bar with logo, title and close button.
function St.Header(f, text)
  local h = f:CreateTexture(nil, "BACKGROUND", nil, 1)
  h:SetPoint("TOPLEFT", 2, -2); h:SetPoint("TOPRIGHT", -2, -2)
  h:SetHeight(26)
  h:SetColorTexture(0.03, 0.13, 0.18, 0.95)
  local line = f:CreateTexture(nil, "BACKGROUND", nil, 2)
  line:SetPoint("TOPLEFT", h, "BOTTOMLEFT"); line:SetPoint("TOPRIGHT", h, "BOTTOMRIGHT")
  line:SetHeight(1)
  line:SetColorTexture(St.GOLD[1], St.GOLD[2], St.GOLD[3], 0.6)

  local logo = f:CreateTexture(nil, "OVERLAY")
  logo:SetSize(20, 20); logo:SetPoint("TOPLEFT", 7, -5)
  logo:SetTexture(St.LOGO)
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("LEFT", logo, "RIGHT", 6, 0)
  title:SetText(text or St.TITLE)

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetSize(24, 24); close:SetPoint("TOPRIGHT", -1, -2)
  f.title, f.close = title, close
  return h
end

-- Dragging the window (outside buttons and rows) moves it.
function St.Movable(f)
  f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

-- Font string with a fixed size, independent of which named fonts a client has.
function St.Text(parent, size, template)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
  if size then
    local file, _, flags = fs:GetFont()
    if file then fs:SetFont(file, size, flags) end
  end
  fs:SetJustifyH("LEFT")
  return fs
end

-- Small flat button in panel colors.
function St.Button(parent, text, w)
  local b = CreateFrame("Button", nil, parent, TEMPLATE)
  b:SetSize(w, 18)
  b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  b:SetBackdropColor(0.06, 0.16, 0.22, 1)
  b:SetBackdropBorderColor(St.CYAN[1], St.CYAN[2], St.CYAN[3], 0.8)
  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  fs:SetPoint("CENTER"); fs:SetText(text)
  b:SetFontString(fs)
  b:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(St.GOLD[1], St.GOLD[2], St.GOLD[3], 1) end)
  b:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(St.CYAN[1], St.CYAN[2], St.CYAN[3], 0.8) end)
  return b
end

-- Checkbox with its own label (template label names differ between clients).
function St.Check(parent, text, get, set)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetPoint("LEFT", cb, "RIGHT", 2, 1)
  label:SetText(text)
  cb:SetScript("OnShow", function(self) self:SetChecked(get() and true or false) end)
  -- HookScript keeps the template's click sound; the label is clickable too.
  cb:HookScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
  cb:SetHitRectInsets(0, -(label:GetStringWidth() + 4), 0, 0)
  cb.label = label
  return cb
end

-- Inline texture for text: |T...|t
function St.Icon(path, size) return "|T" .. path .. ":" .. (size or 14) .. "|t" end
