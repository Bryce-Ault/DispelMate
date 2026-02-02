local _, ns = ...

-- Check if a specific unit has a dispellable debuff
local function UnitDispellableDebuff(unitId)
    local i = 1
    while true do
        local name, icon, _, debuffType = UnitDebuff(unitId, i)
        if not name then break end
        for _, t in ipairs(ns.DISPELLABLE_TYPES) do
            if debuffType == t then
                return icon
            end
        end
        i = i + 1
    end
    return nil
end

-- Build a list of group members who currently have a dispellable debuff
function ns.ScanForDispellableUnits()
    local afflicted = {}
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        -- Solo – check only player
        local pIcon = UnitDispellableDebuff("player")
        if pIcon then
            table.insert(afflicted, { unitId = "player", name = UnitName("player"), icon = pIcon })
        end
    elseif inRaid then
        for i = 1, groupSize do
            local unitId = "raid" .. i
            if UnitExists(unitId) and not UnitIsDeadOrGhost(unitId)
               and UnitIsConnected(unitId) and IsSpellInRange(ns.decurseSpell, unitId) == 1
               then
                local uIcon = UnitDispellableDebuff(unitId)
                if uIcon then
                    table.insert(afflicted, { unitId = unitId, name = UnitName(unitId), icon = uIcon })
                end
            end
        end
    else
        -- Party (includes player as "player")
        local pIcon = UnitDispellableDebuff("player")
        if pIcon then
            table.insert(afflicted, { unitId = "player", name = UnitName("player"), icon = pIcon })
        end
        for i = 1, groupSize - 1 do
            local unitId = "party" .. i
            if UnitExists(unitId) and not UnitIsDeadOrGhost(unitId)
               and UnitIsConnected(unitId) and IsSpellInRange(ns.decurseSpell, unitId) == 1
               then
                local uIcon = UnitDispellableDebuff(unitId)
                if uIcon then
                    table.insert(afflicted, { unitId = unitId, name = UnitName(unitId), icon = uIcon })
                end
            end
        end
    end

    ns.queue = afflicted
end
