hook.Add("InitPostEntityMap", "profile", function()
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove()
	end
end)
