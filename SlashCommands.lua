local _, ns = ...

SLASH_DISPELMATE1 = "/dispelmate"
SLASH_DISPELMATE2 = "/dm"

SlashCmdList["DISPELMATE"] = function(msg)
    local cmd = strtrim(msg):lower()

    if cmd == "test" then
        if InCombatLockdown() then
            print("|cffff6600DispelMate:|r Cannot show test button during combat.")
            return
        end

        -- Use a fallback spell name if class isn't configured (so the UI still shows)
        if not ns.decurseSpell then
            ns.decurseSpell = "Remove Lesser Curse"
        end

        local playerName = UnitName("player")
        local testIcon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
        ns.queue = {
            { unitId = "player", name = playerName, icon = testIcon },
            { unitId = "player", name = "FakeTarget", icon = testIcon },
        }
        ns.UpdateButton()
        print("|cff00ff00DispelMate:|r Test mode – button shown with 2 dummy entries. Click or type |cfffff000/dm reset|r to hide.")

    elseif cmd == "reset" then
        if InCombatLockdown() then
            print("|cffff6600DispelMate:|r Cannot hide button during combat.")
            return
        end
        ns.queue = {}
        ns.UpdateButton()
        print("|cff00ff00DispelMate:|r Button hidden.")

    else
        print("|cff00ff00DispelMate|r commands:")
        print("  |cfffff000/dm test|r  – Show button with dummy debuff entries")
        print("  |cfffff000/dm reset|r – Hide the button")
    end
end
