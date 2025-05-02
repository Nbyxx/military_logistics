ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Logistics Depot"
ENT.Author = "Nyxo"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "MLS"

-- Radius 
ENT.Radius = 300

-- Prüft ob Fahrzeug innerhalb des Radius ist
function ENT:IsVehicleInRange(vehicle)
    if not IsValid(vehicle) then return false end
    return self:GetPos():Distance(vehicle:GetPos()) <= self.Radius
end


-- Ressourcen Konfiguration
ENT.InitialSupplies = 0
ENT.MaxSupplies = 10000

ENT.InitialAmmo = 0
ENT.MaxAmmo = 10000