include("shared.lua")

local LogisticsBoxUI = nil

net.Receive("OpenLogisticsBoxInterface", function()
    local box = net.ReadEntity()
    local currentSupplies = net.ReadUInt(16)
    if not IsValid(box) then return end

    if IsValid(LogisticsBoxUI) then
        LogisticsBoxUI:Close()
    end

    LogisticsBoxUI = vgui.Create("DFrame")
    local frame = LogisticsBoxUI
    frame:SetSize(400, 300)
    frame:SetTitle("Logistics Box")
    frame:Center()
    frame:MakePopup()

    -- Fortschrittsanzeige
    local progressBar = vgui.Create("DPanel", frame)
    progressBar:SetSize(350, 30)
    progressBar:SetPos(25, 50)

    local supplies = currentSupplies
    local maxSupplies = 100

    function progressBar:Paint(w, h)
        local percent = math.Clamp(supplies / maxSupplies, 0, 1)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50))
        draw.RoundedBox(8, 0, 0, w * percent, h, Color(0, 150, 255))
        draw.SimpleText(supplies .. " / " .. maxSupplies, "DermaLarge", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local amountEntry = vgui.Create("DTextEntry", frame)
    amountEntry:SetSize(100, 30)
    amountEntry:SetPos(150, 100)
    amountEntry:SetNumeric(true)
    amountEntry:SetPlaceholderText("Menge eingeben")

    local addButton = vgui.Create("DButton", frame)
    addButton:SetSize(150, 40)
    addButton:SetPos(25, 150)
    addButton:SetText("Einlagern")
    addButton.DoClick = function()
        local amount = tonumber(amountEntry:GetValue()) or 0
        net.Start("AddSuppliesToBox")
        net.WriteEntity(box)
        net.WriteUInt(math.Clamp(amount, 0, 65535), 16)
        net.SendToServer()
    end

    local removeButton = vgui.Create("DButton", frame)
    removeButton:SetSize(150, 40)
    removeButton:SetPos(225, 150)
    removeButton:SetText("Entnehmen")
    removeButton.DoClick = function()
        local amount = tonumber(amountEntry:GetValue()) or 0
        net.Start("RemoveSuppliesFromBox")
        net.WriteEntity(box)
        net.WriteUInt(math.Clamp(amount, 0, 65535), 16)
        net.SendToServer()
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(150, 40)
    closeButton:SetPos(125, 220)
    closeButton:SetText("Schließen")
    closeButton.DoClick = function()
        frame:Close()
    end

    -- Live Update Supplies
    net.Receive("UpdateStorageSupplies", function()
        local updatedBox = net.ReadEntity()
    end)
end) 