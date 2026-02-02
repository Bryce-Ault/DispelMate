local _, ns = ...

local eventFrame = CreateFrame("Frame")
local scanTicker = nil

---------------------------------------------------------------------------
-- Ticker control
---------------------------------------------------------------------------
local function StartScanTicker()
    if scanTicker then return end
    scanTicker = C_Timer.NewTicker(0.5, function()
        ns.ScanForDispellableUnits()
        if not InCombatLockdown() then
            ns.UpdateButton()
        end
    end)
end

local function StopScanTicker()
    if scanTicker then
        scanTicker:Cancel()
        scanTicker = nil
    end
end

---------------------------------------------------------------------------
-- Enable / Disable
---------------------------------------------------------------------------
local function Enable()
    StartScanTicker()
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

local function Disable()
    StopScanTicker()
    eventFrame:UnregisterEvent("UNIT_AURA")
    eventFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    if not InCombatLockdown() then
        ns.btn:Hide()
    end
end

---------------------------------------------------------------------------
-- Aura throttle – avoid scanning every single UNIT_AURA event
---------------------------------------------------------------------------
local auraThrottle = 0

---------------------------------------------------------------------------
-- Event handler
---------------------------------------------------------------------------
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_JOINED")
eventFrame:RegisterEvent("GROUP_LEFT")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, className = UnitClass("player")
        ns.playerClass = className

        local config = ns.CLASS_CONFIG[className]
        if not config then
            -- This class cannot dispel; disable entirely
            self:UnregisterAllEvents()
            StopScanTicker()
            return
        end

        ns.decurseSpell = config.spell

        -- If already in a group, start scanning
        if IsInGroup() or IsInRaid() then
            Enable()
        end

    elseif event == "GROUP_JOINED" then
        Enable()

    elseif event == "GROUP_LEFT" then
        Disable()

    elseif event == "GROUP_ROSTER_UPDATE" then
        if not IsInGroup() and not IsInRaid() then
            Disable()
            return
        end
        ns.ScanForDispellableUnits()
        if not InCombatLockdown() then
            ns.UpdateButton()
        end

    elseif event == "UNIT_AURA" then
        local now = GetTime()
        if now - auraThrottle < 0.3 then return end
        auraThrottle = now

        ns.ScanForDispellableUnits()
        if not InCombatLockdown() then
            ns.UpdateButton()
        end

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellId = ...
        if unit == "player" then
            -- After our dispel cast, rescan quickly
            C_Timer.After(0.2, function()
                ns.ScanForDispellableUnits()
                if not InCombatLockdown() then
                    ns.UpdateButton()
                end
            end)
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended – safe to update button
        ns.ScanForDispellableUnits()
        ns.UpdateButton()
    end
end)
