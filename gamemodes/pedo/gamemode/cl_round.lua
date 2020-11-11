net.Receive("pbe2_roundstatechange", function()
	local newstate = net.ReadUInt(4)

	if newstate == ROUND_PLAY then
		LocalPlayer():EmitSound(table.Random(GAMEMODE.RoundStartSounds), 100, 100)
	end
end)
