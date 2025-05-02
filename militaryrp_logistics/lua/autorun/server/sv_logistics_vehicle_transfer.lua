util.AddNetworkString("RequestVehicleToBoxTransfer")
util.AddNetworkString("TransferVehicleToBoxFeedback")

-- Spieler fordert Transfer an 
net.Receive("RequestVehicleToBoxTransfer", function(len, ply)
    local vehicle = ply:GetVehicle()

    if not IsValid(vehicle) or not LogisticsVehicles[vehicle:GetClass()] then
        vehicle = ply:GetEyeTrace().Entity
        if not IsValid(vehicle) or not LogisticsVehicles[vehicle:GetClass()] then return end
    end

    local supplies = vehicle.LogisticsSupplies or 0
    if supplies <= 0 then return end

    local tr = ply:GetEyeTrace()
    local box = tr.Entity
    if not IsValid(box) or not box:GetClass() == "ent_logistics_box" then return end
    if ply:GetPos():Distance(box:GetPos()) > 200 then return end

    local amount = math.min(20, supplies)

    vehicle.LogisticsSupplies = vehicle.LogisticsSupplies - amount
    box:AddSupplies(amount)

    net.Start("TransferVehicleToBoxFeedback")
    net.WriteInt(amount, 16)
    net.Send(ply)
end)
