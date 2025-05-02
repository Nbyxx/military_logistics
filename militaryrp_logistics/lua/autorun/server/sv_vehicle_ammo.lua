if SERVER then

    hook.Add("EntityFireBullets", "Logistics_HandleVehicleAmmo", function(ent, data)
        if not IsValid(ent) or not ent:IsVehicle() then return end
        if not ent.AmmoInventory or ent.AmmoInventory <= 0 then return end

        local model = string.lower(ent:GetModel() or "")
        local class = ent:GetClass()
        local config = LogisticsVehicles[model] or LogisticsVehicles[class]
        if not config or not config.weaponAmmoUsage then return end

        -- je nach Fahrzeug besser unterscheiden
        local weaponName = ent:GetActiveWeapon() and ent:GetActiveWeapon():GetClass() or "default"

        -- Munition die verbraucht werden soll
        local ammoUsage = config.weaponAmmoUsage[weaponName] or 1 -- standart 1 Munition

        -- Prüfen ob genug Munition da ist
        if ent.AmmoInventory < ammoUsage then
            -- Keine Munition = Schuss blocken
            return false
        end

        -- Munition abziehen
        ent.AmmoInventory = ent.AmmoInventory - ammoUsage

        -- Update an Client schicken
        if ent:GetDriver() and ent:GetDriver():IsPlayer() then
            net.Start("UpdateVehicleInventory")
                net.WriteUInt(ent.SupplyInventory or 0, 16)
                net.WriteUInt(ent.MaxSupplyInventory or 0, 16)
                net.WriteUInt(ent.AmmoInventory or 0, 16)
                net.WriteUInt(ent.MaxAmmoInventory or 0, 16)
            net.Send(ent:GetDriver())
        end
    end)

end

