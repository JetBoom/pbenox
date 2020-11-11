hook.Add("InitPostEntityMap", "profile", function()
	timer.Create("StopMapSounds", 1, 0, function()
		for _, ent in pairs(ents.FindByName("Music")) do
			ent:Fire("stopsound", "", 0)
		end
	end)
end)
