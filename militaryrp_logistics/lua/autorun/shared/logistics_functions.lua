-- Globale Ressourcen-Typen
RESOURCE_TYPES = {
    ["Supplies"] = true,
    ["Munition"] = true,
}

-- Standart Maximum falls Fahrzeug keine Angabe hat
DEFAULT_MAX_CAPACITY = 100

-- Prüft ob Waffe feuern darf (benötigt Munition im Fahrzeug)
function SimfphysCanFireWeapon(wep, requiredAmmo)
    local vehicle = wep:GetParent()
    if not IsValid(vehicle) then return false end

    if not vehicle.AmmoInventory then
        if SERVER then
            wep:EmitSound("weapons/clipempty_pistol.wav")
        end
        return false
    end

    local ammo = vehicle.AmmoInventory["Ammo"] or 0

    if ammo < (requiredAmmo or 1) then
        if SERVER then
            wep:EmitSound("weapons/clipempty_pistol.wav")
        end
        return false
    end

    if SERVER then
        vehicle.AmmoInventory["Ammo"] = math.max(ammo - (requiredAmmo or 1), 0)
    end

    return true
end

-- Gibt maximale Kapazität eines Fahrzeugs zurück
function GetVehicleMaxCapacity(vehicle)
    if not IsValid(vehicle) then return DEFAULT_MAX_CAPACITY end
    return vehicle.MaxInventoryCapacity or DEFAULT_MAX_CAPACITY
end
