hook.Add("PlayerButtonDown", "BlockVehicleShootingIfNoAmmo", function(ply, button)
    if not IsValid(ply) or not ply:InVehicle() then return end
    local vehicle = ply:GetVehicle()
    if not IsValid(vehicle) then return end

    -- Prüfung ob sim_fphys Fahzeug ist 
    if not vehicle:GetClass():StartWith("sim_fphys") then return end

    -- Munition Logik
    if vehicle.AmmoInventory and vehicle.AmmoInventory <= 0 then
        if button == KEY_MOUSE1 then 
            ply:ChatPrint("Keine Munition!")
            return true 
        end
    end
end)

