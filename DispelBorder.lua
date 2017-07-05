local _G = getfenv(0)
local loc = GetLocale()
local _, playerClass = UnitClass("player")
local FocusFrameLoaded = IsAddOnLoaded("FocusFrame")

local STRING_SCHOOL_MAGIC =
    loc == "deDE" and "Magie" or
    loc == "esES" and "Mágica" or
    loc == "esMX" and "Mágica" or
    loc == "frFR" and "Magique" or
    loc == "koKR" and "마법" or
    loc == "zhCN" and "魔法" or
    loc == "zhTW" and "魔法" or
    loc == "ruRU" and "Магия" or "Magic"

-- tooltip used for buff scanning
local scantip = CreateFrame("GameTooltip", "DispelBorderScan", nil, "GameTooltipTemplate")
local scantipTextLeft1 = _G.DispelBorderScanTextLeft1
local scantipTextRight1 = _G.DispelBorderScanTextRight1
scantip:SetOwner(UIParent, "ANCHOR_NONE")
scantip:SetFrameStrata("TOOLTIP")

local function SetBorder(index, unit, debuffType, isEnemy)
    local parent = unit == "target" and "TargetFrameBuff" or "FocusFrameBuff"
    local buff = _G[parent .. index]

    if not buff.stealable then
        buff.stealable = buff:CreateTexture(nil, "OVERLAY", nil, 7)
        buff.stealable:SetWidth(buff:GetWidth()+2)
        buff.stealable:SetHeight(buff:GetWidth()+2)
        buff.stealable:SetTexture("Interface\\AddOns\\DispelBorder\\UI-TargetingFrame-Stealable")
        buff.stealable:SetPoint("CENTER")
        buff.stealable:SetBlendMode("ADD")
    end

    if isEnemy then
        if debuffType == STRING_SCHOOL_MAGIC or playerClass == "ROGUE" and debuffType == "Enrage" then
            return buff.stealable:Show()
        end
    end

    buff.stealable:Hide()
end

local function DebuffButtonUpdate()
    local unit = this.unit ~= "targettarget" and this.unit
    if not unit then return end
    if not FocusFrameLoaded and unit == "focus" then return end
    
    local isEnemy = UnitIsEnemy("player", unit)
    for i = 1, 16 do
        scantip:ClearLines()
        scantipTextRight1:SetText(nil)
        scantip:SetUnitBuff(unit, i)
        if not scantipTextLeft1:GetText() then return end

        SetBorder(i, unit, scantipTextRight1:GetText(), isEnemy)
    end
end

if FocusFrameLoaded then
    hooksecurefunc("FocusDebuffButton_Update", DebuffButtonUpdate)
end
hooksecurefunc("TargetDebuffButton_Update", DebuffButtonUpdate)
