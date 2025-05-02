-- Konfiguriere Fahrzeug-Modelle oder Klassen
LogisticsVehicles = LogisticsVehicles or {}

--Simfphys Basisfahrzeug
LogisticsVehicles["gmod_sent_vehicle_fphysics_base"] = {
    name = "Simfphys Fahrzeug",
    maxSupplies = 0,
    maxAmmo = 100

}

--Fahrzeug Typen

LogisticsVehicles["models/blu/avia/avia.mdl"] = {
    name = "Transport-LKW",
    maxSupplies = 250,
    maxAmmo = 400
}

LogisticsVehicles["models/cars/ger/ampv/ampv.mdl"] = {
    name = "AMPV",
    maxSupplies = 200,
    maxAmmo = 400,
}

LogisticsVehicles["models/cars/ger/wolf/wolf.mdl"] = {
    name = "Wolf",
    maxSupplies = 50,
    maxAmmo = 100
}

LogisticsVehicles["models/apc/ger/tpz/tpz1a6.mdl"] = {
    name = "TPZ 1A6",
    maxSupplies = 100,
    maxAmmo = 300,
}

LogisticsVehicles["models/simfphys/leopard2a6.mdl"] = {
    maxSupplies = 100, 
    maxAmmo = 120, 

}
