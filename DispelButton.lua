local _, ns = ...

---------------------------------------------------------------------------
-- Create secure action button
---------------------------------------------------------------------------
local btn = CreateFrame("Button", "DispelMateButton", UIParent, "SecureActionButtonTemplate")
btn:SetSize(100, 100)
btn:SetPoint("TOP", UIParent, "TOP", -150, -180)
btn:SetFrameStrata("HIGH")
btn:SetMovable(true)
btn:EnableMouse(true)
btn:RegisterForDrag("LeftButton")
btn:RegisterForClicks("AnyUp", "AnyDown")
btn:Hide()

ns.btn = btn

---------------------------------------------------------------------------
-- Visuals
---------------------------------------------------------------------------
-- Background
local bg = btn:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.15, 0.0, 0.2, 0.85)

-- Border
local border = btn:CreateTexture(nil, "BORDER")
border:SetPoint("TOPLEFT", -2, 2)
border:SetPoint("BOTTOMRIGHT", 2, -2)
border:SetColorTexture(0.6, 0.2, 0.8, 1)
border:SetDrawLayer("BORDER")

-- Inner overlay so border appears as a frame around bg
local inner = btn:CreateTexture(nil, "ARTWORK")
inner:SetPoint("TOPLEFT", 1, -1)
inner:SetPoint("BOTTOMRIGHT", -1, 1)
inner:SetColorTexture(0.15, 0.0, 0.2, 0.85)

-- Label (target name)
local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
label:SetPoint("CENTER", btn, "CENTER", 0, 10)
label:SetTextColor(1, 0.85, 0.3)
btn.label = label

-- Status line (queue count)
local status = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
status:SetPoint("CENTER", btn, "CENTER", 0, -10)
status:SetTextColor(0.8, 0.8, 0.8)
btn.status = status

---------------------------------------------------------------------------
-- Dragging
---------------------------------------------------------------------------
btn:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)

btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

---------------------------------------------------------------------------
-- Update button attributes & text from ns.queue
---------------------------------------------------------------------------
function ns.UpdateButton()
    if InCombatLockdown() then return end

    local queue = ns.queue
    if #queue == 0 then
        btn:Hide()
        ns.currentUnit = nil
        return
    end

    local entry = queue[1]
    ns.currentUnit = entry.unitId

    -- Build macro: target unit -> cast dispel -> retarget previous
    local macro = string.format(
        "/target %s\n/cast %s\n/targetlasttarget",
        entry.name, ns.decurseSpell
    )

    btn:SetAttribute("type1", "macro")
    btn:SetAttribute("macrotext1", macro)

    btn.label:SetText("Dispel: " .. entry.name)

    if #queue > 1 then
        btn.status:SetText(string.format("%d more afflicted", #queue - 1))
    else
        btn.status:SetText("")
    end

    if not btn:IsShown() then
        btn:Show()
    end
end
