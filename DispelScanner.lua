local _, ns = ...

-- Check if a specific unit has a dispellable debuff
local function UnitHasDispellable(unitId)
    local i = 1
    while true do
        local name, _, _, debuffType = UnitDebuff(unitId, i)
        if not name then break end
        for _, t in ipairs(ns.DISPELLABLE_TYPES) do
            if debuffType == t then
                return true
            end
        end
        i = i + 1
    end
    return false
end

-- Build a list of group members who currently have a dispellable debuff
function ns.ScanForDispellableUnits()
    local afflicted = {}
    local inRaid = IsInRaid()
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        -- Solo – check only player
        if UnitHasDispellable("player") then
            table.insert(afflicted, { unitId = "player", name = UnitName("player") })
        end
    elseif inRaid then
        for i = 1, groupSize do
            local unitId = "raid" .. i
            if UnitExists(unitId) and not UnitIsDeadOrGhost(unitId)
               and UnitIsConnected(unitId) and IsSpellInRange(ns.decurseSpell, unitId)
               and UnitHasDispellable(unitId) then
                table.insert(afflicted, { unitId = unitId, name = UnitName(unitId) })
            end
        end
    else
        -- Party (includes player as "player")
        if UnitHasDispellable("player") then
            table.insert(afflicted, { unitId = "player", name = UnitName("player") })
        end
        for i = 1, groupSize - 1 do
            local unitId = "party" .. i
            if UnitExists(unitId) and not UnitIsDeadOrGhost(unitId)
               and UnitIsConnected(unitId) and IsSpellInRange(ns.decurseSpell, unitId)
               and UnitHasDispellable(unitId) then
                table.insert(afflicted, { unitId = unitId, name = UnitName(unitId) })
            end
        end
    end

    ns.queue = afflicted
end
