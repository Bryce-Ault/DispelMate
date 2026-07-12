local _, ns = ...

local eventFrame = CreateFrame("Frame")
local scanTicker = nil

local function StartScanTicker()
    if scanTicker then return end
    scanTicker = C_Timer.NewTicker(0.5, function()
        ns.ScanForDispellableUnits()
        ns.UpdateButton()
    end)
end

local function StopScanTicker()
    if scanTicker then
        scanTicker:Cancel()
        scanTicker = nil
    end
end

local function Enable()
    -- Pre-show the button while outside combat so it exists in the "shown"
    -- state before combat lockdown; alpha controls actual visibility.
    if not InCombatLockdown() then
        ns.btn:Show()
    end
    StartScanTicker()
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

---------------------------------------------------------------------------
-- Aura throttle – avoid scanning every single UNIT_AURA event
---------------------------------------------------------------------------
local auraThrottle = 0

---------------------------------------------------------------------------
-- Event handler
---------------------------------------------------------------------------
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, className = UnitClass("player")
        ns.playerClass = className

        local config = ns.CLASS_CONFIG[className]
        if not config then
            self:UnregisterAllEvents()
            StopScanTicker()
            return
        end

        ns.decurseSpell = config.spell
        -- Always enable — solo, party, raid, BG, arena
        Enable()

    elseif event == "GROUP_ROSTER_UPDATE" then
        ns.ScanForDispellableUnits()
        ns.UpdateButton()

    elseif event == "UNIT_AURA" then
        local now = GetTime()
        if now - auraThrottle < 0.3 then return end
        auraThrottle = now
        ns.ScanForDispellableUnits()
        ns.UpdateButton()

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit = ...
        if unit == "player" then
            C_Timer.After(0.2, function()
                ns.ScanForDispellableUnits()
                ns.UpdateButton()
            end)
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        ns.ScanForDispellableUnits()
        ns.UpdateButton()
    end
end)
