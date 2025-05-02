util.AddNetworkString("OpenVehicleInventory")
util.AddNetworkString("SendVehicleInventory")
util.AddNetworkString("RequestOpenVehicleInventory")
util.AddNetworkString("UpdateVehicleInventory")
util.AddNetworkString("VehicleInventoryLoad")
util.AddNetworkString("VehicleInventoryUnload")
util.AddNetworkString("VehicleInventory_LoadAmmo")
util.AddNetworkString("VehicleInventory_UnloadAmmo")

if SERVER then
    AddCSLuaFile("autorun/shared/logistics_functions.lua")
end

include("autorun/shared/logistics_functions.lua")



-- Konfig Datei einbinden
include("autorun/shared/logistics_vehicle_config.lua")
include("autorun/server/sv_vehicle_ammo.lua")

-- Initialisiert Fahrzeug Inventar
function InitializeVehicleInventory(vehicle)
    if not IsValid(vehicle) then return end

    local model = string.lower(vehicle:GetModel() or "")
    local class = vehicle:GetClass()
    local config = LogisticsVehicles[model] or LogisticsVehicles[class]

    if not config then
        print("[LOGISTICS] Kein Fahrzeug-Config:", model, class)
        vehicle.SupplyInventory = 0
        vehicle.MaxSupplyInventory = 0
        vehicle.AmmoInventory = 0
        vehicle.MaxAmmoInventory = 0
        return
    end

    vehicle.SupplyInventory = 0
    vehicle.MaxSupplyInventory = config.maxSupplies or 0
    vehicle.AmmoInventory = 0
    vehicle.MaxAmmoInventory = config.maxAmmo or 0

    print("[LOGISTICS] Initialisiert: " .. (config.name or class) .. " mit " .. vehicle.MaxSupplyInventory .. " Supplies & " .. vehicle.MaxAmmoInventory .. " Munition.")
end

-- Fahrzeug Spawn Hook
hook.Add("PlayerSpawnedVehicle", "Logistics_InitializeVehicleInventory", function(ply, vehicle)
    timer.Simple(0, function()
        InitializeVehicleInventory(vehicle)
    end)
end)

-- Inventar öffnen
net.Receive("RequestOpenVehicleInventory", function(_, ply)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsVehicle() then return end
    if ply:GetPos():Distance(ent:GetPos()) > 150 then return end
    if not ent.SupplyInventory or not ent.AmmoInventory then
        InitializeVehicleInventory(ent)
    end

    net.Start("SendVehicleInventory")
        net.WriteEntity(ent)
        net.WriteUInt(ent.SupplyInventory or 0, 16)
        net.WriteUInt(ent.MaxSupplyInventory or 0, 16)
        net.WriteUInt(ent.AmmoInventory or 0, 16)
        net.WriteUInt(ent.MaxAmmoInventory or 0, 16)
    net.Send(ply)
end)

-- Supplies einladen
net.Receive("VehicleInventoryLoad", function(_, ply)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsVehicle() or ent.SupplyInventory == nil then return end

    -- Nächstgelegene Supplies Zone
    local nearestZone
    local shortestDist = math.huge
    for _, zone in ipairs(ents.FindByClass("ent_logistics_supply_zone")) do
        if zone:IsVehicleInRange(ent) then
            local dist = ent:GetPos():Distance(zone:GetPos())
            if dist < shortestDist then
                shortestDist = dist
                nearestZone = zone
            end
        end
    end

    if not IsValid(nearestZone) then
        ply:ChatPrint("Nicht in Nachschubzone – Supplies können hier nicht geladen werden.")
        return
    end

    -- Prüfen ob genug supplies vorhanden
    if (nearestZone.Supplies or 0) < 20 then
        ply:ChatPrint("Nachschubzone hat nicht genug Supplies!")
        return
    end

    -- Supplies laden
    ent.SupplyInventory = math.min(ent.SupplyInventory + 20, ent.MaxSupplyInventory)

    -- Supplies vom Depot abziehen
    nearestZone.Supplies = math.max((nearestZone.Supplies or 0) - 20, 0)

    -- Update an Vehicle-Client
    net.Start("UpdateVehicleInventory")
        net.WriteUInt(ent.SupplyInventory, 16)
        net.WriteUInt(ent.MaxSupplyInventory, 16)
        net.WriteUInt(ent.AmmoInventory or 0, 16)
        net.WriteUInt(ent.MaxAmmoInventory or 0, 16)
    net.Send(ply)

    -- Update an Depot-Client (3D2D wird neu gezeichnet)
    net.Start("UpdateDepotSupplies")
        net.WriteEntity(nearestZone)
        net.WriteInt(nearestZone.Supplies or 0, 32)
        net.WriteInt(nearestZone.Ammo or 0, 32)
    net.Broadcast()

    
end)

-- Munition Einladen
net.Receive("VehicleInventory_LoadAmmo", function(_, ply)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsVehicle() or ent.AmmoInventory == nil then return end

    -- Nächstgelegene Supply-Zone finden
    local nearestZone
    local shortestDist = math.huge
    for _, zone in ipairs(ents.FindByClass("ent_logistics_supply_zone")) do
        if zone:IsVehicleInRange(ent) then
            local dist = ent:GetPos():Distance(zone:GetPos())
            if dist < shortestDist then
                shortestDist = dist
                nearestZone = zone
            end
        end
    end

    if not IsValid(nearestZone) then
        ply:ChatPrint("Nicht in Nachschubzone – Munition kann hier nicht geladen werden.")
        return
    end

    -- Prüfen ob genug Munition vorhanden
    if (nearestZone.Ammo or 0) < 10 then
        ply:ChatPrint("Nachschubzone hat nicht genug Munition!")
        return
    end

    -- Munition laden
    ent.AmmoInventory = math.min(ent.AmmoInventory + 10, ent.MaxAmmoInventory)

    -- Munition vom Depot abziehen
    nearestZone.Ammo = math.max((nearestZone.Ammo or 0) - 10, 0)

    -- Update an Vehicle-Client
    net.Start("UpdateVehicleInventory")
        net.WriteUInt(ent.SupplyInventory, 16)
        net.WriteUInt(ent.MaxSupplyInventory, 16)
        net.WriteUInt(ent.AmmoInventory, 16)
        net.WriteUInt(ent.MaxAmmoInventory, 16)
    net.Send(ply)

    -- Update an Depot-Client (3D2D wird neu gezeichnet)
    net.Start("UpdateDepotSupplies")
        net.WriteEntity(nearestZone)
        net.WriteInt(nearestZone.Supplies or 0, 32)
        net.WriteInt(nearestZone.Ammo or 0, 32)
    net.Broadcast()

   
end)


-- Supplies Entladen
net.Receive("VehicleInventoryUnload", function(_, ply)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsVehicle() or not ent.SupplyInventory then return end

    ent.SupplyInventory = math.max(ent.SupplyInventory - 10, 0)
    net.Start("UpdateVehicleInventory")
        net.WriteUInt(ent.SupplyInventory, 16)
        net.WriteUInt(ent.MaxSupplyInventory, 16)
        net.WriteUInt(ent.AmmoInventory, 16)
        net.WriteUInt(ent.MaxAmmoInventory, 16)
    net.Send(ply)
end)

-- Munition Entladen
net.Receive("VehicleInventory_UnloadAmmo", function(_, ply)
    local ent = ply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent:IsVehicle() or not ent.AmmoInventory then return end

    ent.AmmoInventory = math.max(ent.AmmoInventory - 10, 0)

    net.Start("UpdateVehicleInventory")
        net.WriteUInt(ent.SupplyInventory, 16)
        net.WriteUInt(ent.MaxSupplyInventory, 16)
        net.WriteUInt(ent.AmmoInventory, 16)
        net.WriteUInt(ent.MaxAmmoInventory, 16)
    net.Send(ply)

    ply:ChatPrint("10 Munition entladen.")
end)


util.AddNetworkString("OpenVehicleInventory")
util.AddNetworkString("LoadSupplies")
util.AddNetworkString("UnloadSupplies")

-- Inventar initialisieren
hook.Add("PlayerSpawnedVehicle", "InitializeVehicleInventory", function(ply, vehicle)
    vehicle.Inventory = {}
    vehicle.MaxInventoryCapacity = DEFAULT_MAX_CAPACITY
end)



-- Debug: Fahrzeugklasse,Model
concommand.Add("get_vehicle_class", function(ply)
    local ent = ply:GetEyeTrace().Entity
    if IsValid(ent) and ent:IsVehicle() then
        print("[VEHICLE CLASS] " .. ent:GetClass())
        print("[VEHICLE MODEL] " .. ent:GetModel())
        ply:ChatPrint("Fahrzeugklasse: " .. ent:GetClass())
        ply:ChatPrint("Fahrzeugmodell: " .. ent:GetModel())
    else
        ply:ChatPrint("Kein gültiges Fahrzeug.")
    end
end) 



hook.Add("simfphys_OnFire", "Logistics_HandleVehicleAmmo", function(vehicle, weaponName)
    if not IsValid(vehicle) then return end
    if not vehicle.AmmoInventory or vehicle.AmmoInventory <= 0 then
        -- Fahrzeug hat keine Munition = Schießen verhindern
        if istable(vehicle.SimfphysWeapons) then
            local wep = vehicle.SimfphysWeapons[weaponName]
            if wep then
                wep:SetNextPrimary( CurTime() + 1 ) -- verhindert sofortiges Weiterschießen
            end
        end
        return false
    end

    local model = string.lower(vehicle:GetModel() or "")
    local class = vehicle:GetClass()
    local config = LogisticsVehicles[model] or LogisticsVehicles[class]
    if not config or not config.weaponAmmoUsage then return end

    local usage = config.weaponAmmoUsage[weaponName] or 1

    if vehicle.AmmoInventory < usage then
        -- Nicht genug Munition = verhindern
        if istable(vehicle.SimfphysWeapons) then
            local wep = vehicle.SimfphysWeapons[weaponName]
            if wep then
                wep:SetNextPrimary( CurTime() + 1 )
            end
        end
        return false
    end

    -- Munition abziehen
    vehicle.AmmoInventory = vehicle.AmmoInventory - usage

    -- Update an Client
    if vehicle:GetDriver() and vehicle:GetDriver():IsPlayer() then
        net.Start("UpdateVehicleInventory")
            net.WriteUInt(vehicle.SupplyInventory or 0, 16)
            net.WriteUInt(vehicle.MaxSupplyInventory or 0, 16)
            net.WriteUInt(vehicle.AmmoInventory or 0, 16)
            net.WriteUInt(vehicle.MaxAmmoInventory or 0, 16)
        net.Send(vehicle:GetDriver())
    end
end)

