local _, ns = ...

---------------------------------------------------------------------------
-- Create secure action button
---------------------------------------------------------------------------
local btn = CreateFrame("Button", "DispelMateButton", UIParent, "SecureActionButtonTemplate")
btn:SetSize(73, 51)
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
border:SetColorTexture(0.8, 0.1, 0.1, 1)
border:SetDrawLayer("BORDER")

-- Inner overlay so border appears as a frame around bg
local inner = btn:CreateTexture(nil, "ARTWORK")
inner:SetPoint("TOPLEFT", 1, -1)
inner:SetPoint("BOTTOMRIGHT", -1, 1)
inner:SetColorTexture(0.15, 0.0, 0.2, 0.85)

-- Debuff icon
local debuffIcon = btn:CreateTexture(nil, "OVERLAY")
debuffIcon:SetSize(18, 18)
debuffIcon:SetPoint("TOP", btn, "TOP", 0, -5)
btn.debuffIcon = debuffIcon

-- Label (target name)
local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
local labelFont, _, labelFlags = label:GetFont()
label:SetFont(labelFont, 10, labelFlags)
label:SetPoint("TOP", debuffIcon, "BOTTOM", 0, -2)
label:SetTextColor(1, 0.85, 0.3)
btn.label = label

-- Status line (queue count)
local status = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
local statusFont, _, statusFlags = status:GetFont()
status:SetFont(statusFont, 7, statusFlags)
status:SetPoint("BOTTOM", btn, "BOTTOM", 0, 4)
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
    local queue = ns.queue
    local inCombat = InCombatLockdown()

    if #queue == 0 then
        ns.currentUnit = nil
        if inCombat then
            -- Can't hide the button, so make it fully transparent
            btn.debuffIcon:Hide()
            btn.label:SetText("")
            btn.status:SetText("")
            bg:SetAlpha(0)
            border:SetAlpha(0)
            inner:SetAlpha(0)
        else
            btn:Hide()
        end
        return
    end

    local entry = queue[1]
    ns.currentUnit = entry.unitId

    -- Restore visuals in case they were cleared
    bg:SetAlpha(1)
    border:SetAlpha(1)
    inner:SetAlpha(1)

    if entry.icon then
        btn.debuffIcon:SetTexture(entry.icon)
        btn.debuffIcon:Show()
    else
        btn.debuffIcon:Hide()
    end

    btn.label:SetText(entry.name)

    if #queue > 1 then
        btn.status:SetText(string.format("%d more afflicted", #queue - 1))
    else
        btn.status:SetText("")
    end

    if not inCombat then
        -- Build macro: target unit -> cast dispel -> retarget previous
        local macro = string.format(
            "/target %s\n/cast %s\n/targetlasttarget",
            entry.name, ns.decurseSpell
        )

        btn:SetAttribute("type1", "macro")
        btn:SetAttribute("macrotext1", macro)

        if not btn:IsShown() then
            btn:Show()
        end
    end
end
