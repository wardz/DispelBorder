local _G = getfenv(0)
local locale = GetLocale()
local _, playerClass = UnitClass("player")
local FocusFrameLoaded = IsAddOnLoaded("FocusFrame")
local scantip = CreateFrame("GameTooltip", "DispelBorderScan", nil, "GameTooltipTemplate")

local MAX_TARGET_BUFFS = MAX_TARGET_BUFFS

local STRING_SCHOOL_MAGIC =
    locale == "deDE" and "Magie" or
    locale == "esES" and "Mágica" or
    locale == "esMX" and "Mágica" or
    locale == "frFR" and "Magique" or
    locale == "koKR" and "마법" or
    locale == "zhCN" and "魔法" or
    locale == "zhTW" and "魔法" or
    locale == "ruRU" and "Магия" or "Magic"

local function SetBorder(index, unit, buffType, isEnemy)
    local parent = unit == "target" and "TargetFrameBuff" or "FocusFrameBuff"
    local buff = _G[parent .. index]
    if not buff then return end

    if not buff.stealable then
        buff.stealable = buff:CreateTexture(nil, "OVERLAY", nil, 7)
        buff.stealable:SetTexture("Interface\\AddOns\\DispelBorder\\UI-TargetingFrame-Stealable")
        buff.stealable:SetPoint("CENTER", 0, 0)
        buff.stealable:SetBlendMode("ADD")
    end

    -- Buff size changes depending on amount of buffs shown,
    -- so just update it everytime
    local width = buff:GetWidth() + 2
    buff.stealable:SetWidth(width)
    buff.stealable:SetHeight(width)

    if isEnemy then
        if buffType == STRING_SCHOOL_MAGIC or playerClass == "ROGUE" and buffType == "Enrage" then
            return buff.stealable:Show()
        end
    end

    buff.stealable:Hide()
end

local function DebuffButtonUpdate(unitID)
    local unit = unitID or this.unit
    if not unit or unit == "targettarget" then return end
    if not FocusFrameLoaded and unit == "focus" then return end
    if not UnitExists(unit) then return end

    -- Reattach scantip everytime, if you don't
    -- :SetUnitBuff() will randomly stop working after a while
    scantip:SetOwner(WorldFrame, "ANCHOR_NONE")
    local scantipTextLeft1 = _G.DispelBorderScanTextLeft1
    local scantipTextRight1 = _G.DispelBorderScanTextRight1

    local isEnemy = UnitIsEnemy("player", unit)

    for i = 1, MAX_TARGET_BUFFS do
        scantip:ClearLines()
        scantipTextRight1:SetText(nil)
        scantip:SetUnitBuff(unit, i)
        if not scantipTextLeft1:GetText() then return end

        SetBorder(i, unit, scantipTextRight1:GetText(), isEnemy)
    end
end

local function ClassicUpdateAuras(self)
    local unit = self.unit
    if not UnitCanAttack("player", unit) then return end

    local selfName = self:GetName().."Buff"
    for i = 1, 32 do
        local name, _, _, debuffType = UnitAura(unit, i, "HELPFUL")
        if not name then return end

        if debuffType == "Magic" then
            _G[selfName..i.."Stealable"]:Show()
        end
    end
end

if WOW_PROJECT_ID then -- Classic TBC/Era
    hooksecurefunc("TargetFrame_UpdateAuras", ClassicUpdateAuras)
elseif GetBuildInfo() == "2.4.3" then -- TBC old
    hooksecurefunc("TargetDebuffButton_Update", DebuffButtonUpdate)
    if FocusFrameLoaded then
        hooksecurefunc("FocusDebuffButton_Update", DebuffButtonUpdate)
    end
else -- Vanilla 1.12.1
    local orig_TargetDebuffButton_Update = TargetDebuffButton_Update
    TargetDebuffButton_Update = function()
        orig_TargetDebuffButton_Update()
        DebuffButtonUpdate()
    end

    if FocusFrameLoaded and FocusCore then
        FocusCore:OnEvent("UNIT_AURA", function()
            local buffData = FocusCore:GetBuffs()
            local buffs = buffData.buffs
            local isEnemy = FocusCore:GetData("unitIsEnemy")

            for i = 1, 5 do
                if buffs[i] then
                    local type = buffs[i].debuffType == "magic" and "Magic" -- fast strupper
                    SetBorder(i, "focus", type, isEnemy)
                end
            end
        end)
    end
end
