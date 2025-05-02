include("autorun/logistics_vehicle_inventory.lua")

-- Globale Konfiguration
LogisticsConfig = LogisticsConfig or {}
LogisticsConfig.MaxStorage = 100

LogisticsConfig = LogisticsConfig or {}

-- Position von Lager A (für Beladung)
LogisticsConfig.SupplyDepotPosition = Vector(1000, 1000, 0)  
LogisticsConfig.SupplyDepotRadius = 300  -- Radius in dem Beladung möglich ist

-- Fahrzeuge mit Inventargröße
LogisticsConfig.VehicleInventories = {
    ["sim_fphys_tank"] = 100,
    ["sim_fphys_m35a2"] = 200,
    ["sim_fphys_brdm2"] = 50,


}
