local meta = FindMetaTable("Player")
if not meta then return end

function meta:GetCurrentItem()
	for _, itemInfo in ipairs(GAMEMODE.ItemsList) do
		if IsValid(self:GetActiveWeapon()) and itemInfo["swep"] == self:GetActiveWeapon():GetClass() then
			return itemInfo
		end
	end

	return false
end
