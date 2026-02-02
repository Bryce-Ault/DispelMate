local addonName, ns = ...

-- Decurse spell by class
ns.CLASS_CONFIG = {
    MAGE   = { spell = "Remove Lesser Curse" },
    DRUID  = { spell = "Remove Curse" },
}

-- Debuff types we can dispel (will grow with magic support later)
ns.DISPELLABLE_TYPES = { "Curse" }

-- State
ns.playerClass = nil
ns.decurseSpell = nil
ns.queue = {}        -- { unitId, unitName } entries with active debuffs
ns.currentUnit = nil -- unit currently assigned to the button
ns.btn = nil
