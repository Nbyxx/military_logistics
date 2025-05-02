-- Globale Referenzen auf Fortschrittsbalken
local supplyBar = nil
local ammoBar = nil

-- Empfang der Nachricht vom Server
net.Receive("SendVehicleInventory", function()
    local vehicle = net.ReadEntity()
    local supply = net.ReadUInt(16)
    local supplyMax = net.ReadUInt(16)
    local ammo = net.ReadUInt(16)
    local ammoMax = net.ReadUInt(16)

    if not IsValid(vehicle) then return end

    -- Fenster öffnen
    local frame = vgui.Create("DFrame")
    frame:SetSize(320, 300)
    frame:SetTitle("Fahrzeug-Inventar")
    frame:Center()
    frame:MakePopup()

    -- Fortschrittsanzeige Supplies
    supplyBar = vgui.Create("DPanel", frame)
    supplyBar:SetSize(260, 30)
    supplyBar:SetPos(30, 50)
    supplyBar.current = supply
    supplyBar.max = supplyMax

    function supplyBar:Paint(w, h)
        local percent = math.Clamp(self.current / self.max, 0, 1)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50))
        draw.RoundedBox(6, 0, 0, w * percent, h, Color(0, 150, 255))
        draw.SimpleText(self.current .. " / " .. self.max .. " Supplies", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Fortschrittsanzeige Munition
    ammoBar = vgui.Create("DPanel", frame)
    ammoBar:SetSize(260, 30)
    ammoBar:SetPos(30, 140)
    ammoBar.current = ammo
    ammoBar.max = ammoMax

    function ammoBar:Paint(w, h)
        local percent = math.Clamp(self.current / self.max, 0, 1)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50))
        draw.RoundedBox(6, 0, 0, w * percent, h, Color(255, 100, 100))
        draw.SimpleText(self.current .. " / " .. self.max .. " Munition", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Supplies Einladen
    local loadBtn = vgui.Create("DButton", frame)
    loadBtn:SetText("Supplies Einladen")
    loadBtn:SetSize(120, 30)
    loadBtn:SetPos(30, 90)
    loadBtn.DoClick = function()
        net.Start("VehicleInventoryLoad")
        net.SendToServer()
    end

    -- Supplies Entladen
    local unloadBtn = vgui.Create("DButton", frame)
    unloadBtn:SetText("Supplies Entladen")
    unloadBtn:SetSize(120, 30)
    unloadBtn:SetPos(170, 90)
    unloadBtn.DoClick = function()
        net.Start("VehicleInventoryUnload")
        net.SendToServer()
    end

    -- Munition Einladen
    local btnLoadAmmo = vgui.Create("DButton", frame)
    btnLoadAmmo:SetText("Munition Einladen")
    btnLoadAmmo:SetSize(120, 30)
    btnLoadAmmo:SetPos(30, 180)
    btnLoadAmmo.DoClick = function()
        net.Start("VehicleInventory_LoadAmmo")
        net.SendToServer()
    end

    -- Munition Entladen
    local btnUnloadAmmo = vgui.Create("DButton", frame)
    btnUnloadAmmo:SetText("Munition Entladen")
    btnUnloadAmmo:SetSize(120, 30)
    btnUnloadAmmo:SetPos(170, 180)
    btnUnloadAmmo.DoClick = function()
        net.Start("VehicleInventory_UnloadAmmo")
        net.SendToServer()
    end

    -- Bei Schließen = Referenzen löschen
    frame.OnClose = function()
        supplyBar = nil
        ammoBar = nil
    end
end)

-- Realtime Update Munition und Supplies
net.Receive("UpdateVehicleInventory", function()
    local currentSupplies = net.ReadUInt(16)
    local maxSupplies = net.ReadUInt(16)
    local currentAmmo = net.ReadUInt(16)
    local maxAmmo = net.ReadUInt(16)

    if IsValid(supplyBar) then
        supplyBar.current = currentSupplies
        supplyBar.max = maxSupplies
        supplyBar:InvalidateLayout(true)
    end

    if IsValid(ammoBar) then
        ammoBar.current = currentAmmo
        ammoBar.max = maxAmmo
        ammoBar:InvalidateLayout(true)
    end
end)

-- Inventar öffnen
hook.Add("Think", "OpenVehicleInventoryKey", function()
    if input.IsKeyDown(KEY_I) then
        if not LocalPlayer().LastInvOpen or CurTime() - (LocalPlayer().LastInvOpen or 0) > 1 then
            LocalPlayer().LastInvOpen = CurTime()
            net.Start("RequestOpenVehicleInventory")
            net.SendToServer()
        end
    end
end)
