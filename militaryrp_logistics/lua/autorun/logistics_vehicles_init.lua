-- Lade Server-Dateien
if SERVER then
    include("autorun/server/sv_logistics_network.lua")
    include("autorun/server/sv_vehicle_inventory.lua")
end

-- Lade Client-Dateien
if CLIENT then
    include("autorun/client/cl_vehicle_inventory.lua")
end

-- Lade geteilte Konfiguration
include("autorun/shared/logistics_vehicle_config.lua")
