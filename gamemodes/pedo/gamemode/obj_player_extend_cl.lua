local meta = FindMetaTable("Player")
if not meta then return end

function meta:EndState(nocallended)
	if self == MySelf then
		self:SetState(STATE_NONE, nil, nil, nocallended)
	end
end
