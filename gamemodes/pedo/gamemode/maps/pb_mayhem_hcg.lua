hook.Add("InitPostEntityMap", "profile", function()
	for k, ent in pairs(ents.FindByClass("pb_spawn")) do
		if k > 4 then
			ent:Remove()
		end
	end
end)
