AddCSLuaFile()
include("shared.lua")

util.AddNetworkString("UpdateDepotSupplies")
util.AddNetworkString("SupplyBoxUpdated")

DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Supply Zone"
ENT.Spawnable = true

ENT.ZoneRadius = 500
ENT.SupplyCooldown = {}

function ENT:Initialize()
    self:SetModel("models/bigcontsup/big_container_sup.mdl")
    self:SetSkin(1)
    self:SetMaterial("")
    self:SetColor(Color(255, 255, 255, 255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Anfangswerte
    self.Supplies = 0
    self.Ammo = 0
    self.MaxSupplies = 10000
    self.MaxAmmo = 10000

    -- Regenerationsraten pro Tick
    self.SupplyRegenRate = 400  
    self.AmmoRegenRate = 200   

    timer.Create("AutoGenerateSupplies_" .. self:EntIndex(), 10, 0, function()
        if not IsValid(self) then return end

        -- Supplies auffüllen
        if self.Supplies < self.MaxSupplies then
            self.Supplies = math.min(self.Supplies + self.SupplyRegenRate, self.MaxSupplies)
        end

        -- Ammo auffüllen
        if self.Ammo < self.MaxAmmo then
            self.Ammo = math.min(self.Ammo + self.AmmoRegenRate, self.MaxAmmo)
        end

        net.Start("UpdateDepotSupplies")
        net.WriteEntity(self)
        net.WriteInt(self.Supplies, 32)
        net.WriteInt(self.Ammo, 32)
        net.Broadcast()
    end)
end

function ENT:OnRemove()
    timer.Remove("AutoGenerateSupplies_" .. self:EntIndex())
end

-- Prüfe ob Fahrzeug in Reichweite
function ENT:IsVehicleInRange(vehicle)
    if not IsValid(vehicle) then return false end
    local zonePos = self:GetPos()
    local vehiclePos = vehicle:GetPos()
    return zonePos:Distance(vehiclePos) <= (self.ZoneRadius or 300)
end

-- DEBUG Zeichnung + UI
function ENT:Draw()
    self:DrawModel()

    -- Grüner Kreis
    local pos = self:GetPos()
    local ang = self:GetAngles()

    cam.Start3D2D(pos, Angle(0, ang.y, 0), 1)
        surface.SetDrawColor(0, 255, 0, 100)
        draw.NoTexture()
        surface.DrawPoly(self:GenerateCircle(self.ZoneRadius, 50))
    cam.End3D2D()

    -- 3D2D UI für Supplies & Munition
    local imguiPos = self:GetPos() + Vector(0, 0, 100)
    local imguiAngle = self:GetAngles()
    imguiAngle:RotateAroundAxis(imguiAngle:Up(), 45)
    local scale = 0.25

    cam.Start3D2D(imguiPos, Angle(0, imguiAngle.y, 90), scale)
        -- Supplies Bar
        local barWidth, barHeight = 200, 20
        local supplies = self.Supplies or 0
        local maxSupplies = self.MaxSupplies or 10000
        local ammo = self.Ammo or 0
        local maxAmmo = self.MaxAmmo or 10000

        local fillSupplies = math.min(supplies / maxSupplies, 1)
        local fillAmmo = math.min(ammo / maxAmmo, 1)

        draw.RoundedBox(8, -barWidth/2, -barHeight-10, barWidth, barHeight, Color(50, 50, 50))
        draw.RoundedBox(8, -barWidth/2, -barHeight-10, barWidth * fillSupplies, barHeight, Color(0, 255, 0))
        draw.SimpleText("Supplies: " .. supplies .. " / " .. maxSupplies, "Trebuchet24", 0, -barHeight, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Munition bar (darunter)
        draw.RoundedBox(8, -barWidth/2, 20, barWidth, barHeight, Color(50, 50, 50))
        draw.RoundedBox(8, -barWidth/2, 20, barWidth * fillAmmo, barHeight, Color(255, 100, 100))
        draw.SimpleText("Munition: " .. ammo .. " / " .. maxAmmo, "Trebuchet24", 0, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:GenerateCircle(radius, segments)
    local circle = {}
    for i = 0, segments do
        local theta = (i / segments) * math.pi * 2
        local x = math.cos(theta) * radius
        local y = math.sin(theta) * radius
        table.insert(circle, {x = x, y = y})
    end
    return circle
end

--Zugriff für andere Scripts (optional)
function ENT:GetSupplies() return self.Supplies end
function ENT:GetAmmo() return self.Ammo end
function ENT:SetSupplies(val) self.Supplies = math.Clamp(val, 0, self.MaxSupplies or 10000) end
function ENT:SetAmmo(val) self.Ammo = math.Clamp(val, 0, self.MaxAmmo or 10000) end