AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/logistics_init.lua")



util.AddNetworkString("OpenLogisticsBoxInterface")
util.AddNetworkString("UpdateStorageSupplies")
util.AddNetworkString("AddSuppliesToBox")
util.AddNetworkString("RemoveSuppliesFromBox")

function ENT:Initialize()
    self:SetModel("models/bigsupplies/big_supplies.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.Supplies = 0
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then
        net.Start("OpenLogisticsBoxInterface")
        net.WriteEntity(self)
        net.WriteUInt(self.Supplies, 16)
        net.Send(caller)
    end
end

function ENT:AddSupplies(amount)
    if not amount or type(amount) ~= "number" then return end

    local newAmount = math.Clamp(self.Supplies + amount, 0, LogisticsConfig.MaxStorage)
    self.Supplies = newAmount

    net.Start("UpdateStorageSupplies")
    net.WriteEntity(self)
    net.WriteInt(self.Supplies, 16)
    net.Broadcast()
end
net.Receive("AddSuppliesToBox", function(len, ply)
    local box = net.ReadEntity()
    local amount = net.ReadUInt(16)

    if IsValid(box) and amount > 0 then
        box:AddSupplies(amount)
    end
end)

net.Receive("RemoveSuppliesFromBox", function(len, ply)
    local box = net.ReadEntity()
    local amount = net.ReadUInt(16)

    if IsValid(box) and amount > 0 then
        box:AddSupplies(-amount)
    end
end)


