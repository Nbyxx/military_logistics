include("autorun/shared/logistics_vehicle_config.lua")

hook.Add("HUDPaint", "DrawVehicleSupplyInfo", function()
    local ply = LocalPlayer()
    local vehicle = ply:GetVehicle()

    if IsValid(vehicle) and LogisticsVehicles[vehicle:GetClass()] then
        local data = LogisticsVehicles[vehicle:GetClass()]
        draw.SimpleTextOutlined(
            "Fahrzeug: " .. data.name .. " | Max Supplies: " .. data.maxSupplies,
            "DermaLarge",
            ScrW() / 2,
            ScrH() - 100,
            Color(255, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP,
            1,
            Color(0, 0, 0)
        )
    end
end)
