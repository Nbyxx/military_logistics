LogisticsDepotConfig = LogisticsDepotConfig or {}

-- Sichtbarer Radius um das Depot A
LogisticsDepotConfig.DepotARadius = 500

-- Sichtweite ab wann der Kreis gezeichnet wird (aus Spielersicht)
LogisticsDepotConfig.DrawDistance = 750

-- Sichtbarkeit durch Wände
LogisticsDepotConfig.RequireLineOfSight = false  -- true = nicht durch Wände sichtbar false = immer sichtbar (auch im Kreis ist)

LogisticsDepotConfig.CircleColor = Color(0, 255, 0, 150)

-- Linienmaterial
LogisticsDepotConfig.LineMaterial = "debug/debugdrawflat" -- Alternativen "cable/physbeam", "cable/redlaser", "debug/debugwhite"

-- Dicke der Linien (funktioniert nur bei bestimmten Materialien)
LogisticsDepotConfig.LineWidth = 3
