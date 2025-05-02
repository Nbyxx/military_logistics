hook.Add("Think", "CheckForVehicleTransferKey", function()
    if input.IsKeyDown(KEY_E) and input.IsKeyDown(KEY_LALT) then
        local ply = LocalPlayer()
        if not IsFirstTimePredicted() then return end

        net.Start("RequestVehicleToBoxTransfer")
        net.SendToServer()
    end
end)

net.Receive("TransferVehicleToBoxFeedback", function()
    local amount = net.ReadInt(16)
    chat.AddText(Color(0, 200, 255), "[Logistik] ", Color(255, 255, 255), "Es wurden ", Color(0, 255, 0), amount, Color(255, 255, 255), " Supplies in die Lagerbox übertragen.")
end)
