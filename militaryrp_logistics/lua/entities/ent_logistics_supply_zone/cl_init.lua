include("shared.lua")

-- Konfig laden
local cfg = LogisticsDepotConfig or {}

local depotSupplies = 0  -- Supplies Anfangswert

-- Netzwerkempfang für aktualisierte Supplies
net.Receive("UpdateDepotSupplies", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    ent.Supplies = net.ReadInt(32)
    ent.Ammo = net.ReadInt(32)
end)



-- Position auf Boden berechnen
local function GetGroundPos(ent)
    local start = ent:GetPos()
    local tr = util.TraceLine({
        start = start,
        endpos = start - Vector(0, 0, 500),
        filter = ent
    })
    return tr.HitPos
end

function ENT:Draw()
    self:DrawModel()

    local cfg = LogisticsDepotConfig or {}
    local ply = LocalPlayer()
    local plyPos = ply:GetPos()
    local entPos = self:GetPos()
    local dist = entPos:Distance(plyPos)
    if dist > (cfg.DrawDistance or 750) then return end

    --- Kreis Radius um Depot ---
    local radius = cfg.DepotARadius or 500
    local lineColor = cfg.CircleColor or Color(255, 0, 0, 200)
    local lineWidth = cfg.LineWidth or 5
    local lineMat = Material(cfg.LineMaterial or "cable/redlaser")
    local segments = 360

    if cfg.RequireLineOfSight and dist > radius then
        local trace = util.TraceLine({
            start = ply:EyePos(),
            endpos = entPos + Vector(0, 0, 30),
            filter = ply
        })
        if trace.Hit and trace.Entity ~= self then return end
    end

    local function GetGroundPos(ent)
        local start = ent:GetPos()
        local tr = util.TraceLine({
            start = start,
            endpos = start - Vector(0, 0, 500),
            filter = ent
        })
        return tr.HitPos
    end

    local groundPos = GetGroundPos(self) + Vector(0, 0, 0.5)

    render.OverrideDepthEnable(true, true)
    cam.Start3D()
        render.SetMaterial(lineMat)
        for i = 0, segments do
            local angle1 = math.rad(i)
            local angle2 = math.rad(i + 1)
            local x1 = math.cos(angle1) * radius
            local y1 = math.sin(angle1) * radius
            local x2 = math.cos(angle2) * radius
            local y2 = math.sin(angle2) * radius
            render.DrawBeam(
                groundPos + Vector(x1, y1, 0),
                groundPos + Vector(x2, y2, 0),
                lineWidth, 0, 1, lineColor
            )
        end
    cam.End3D()
    render.OverrideDepthEnable(false, false)

    --- 3D2D Supplies & Munition Anzeige ---
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local scale = 0.3
    local barWidth, barHeight = 200, 40

    local supplies = self.Supplies or 0
    local maxSupplies = self.MaxSupplies or 10000
    local ammo = self.Ammo or 0
    local maxAmmo = self.MaxAmmo or 10000

    local supplyFill = math.Clamp(supplies / maxSupplies, 0, 1)
    local ammoFill = math.Clamp(ammo / maxAmmo, 0, 1)

    local supplyFilledWidth = barWidth * supplyFill
    local ammoFilledWidth = barWidth * ammoFill

    -- Seite A
    do
        local offsetA = Vector(48, -13, 55)
        local worldOffsetA = pos 
            + ang:Forward() * offsetA.x 
            + ang:Right() * offsetA.y 
            + ang:Up() * offsetA.z
        local angleA = Angle(0, ang.y + 90, 90)

        cam.Start3D2D(worldOffsetA, angleA, scale)
            draw.RoundedBox(8, -barWidth / 2, -barHeight - 2, barWidth, barHeight, Color(50, 50, 50))
            draw.RoundedBox(8, -barWidth / 2, -barHeight - 2, supplyFilledWidth, barHeight, Color(0, 255, 0))
            draw.SimpleText("Supplies: " .. supplies .. "/" .. maxSupplies, "Trebuchet24", 0, -barHeight / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.RoundedBox(8, -barWidth / 2, 42, barWidth, barHeight, Color(50, 50, 50))
            draw.RoundedBox(8, -barWidth / 2, 42, ammoFilledWidth, barHeight, Color(255, 0, 0))
            draw.SimpleText("Munition: " .. ammo .. "/" .. maxAmmo, "Trebuchet24", 0, 62, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

