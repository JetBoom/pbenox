local meta = FindMetaTable("Player")
if not meta then return end

function meta:IsProjectile()
	return self:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE or self.m_IsProjectile
end

function meta:IsActivePlayer()
	return self:IsPlayer() and self:IsActive()
end

function meta:IsInWater()
	return self:WaterLevel() > 0
end

function meta:IsSwimming()
	return self:WaterLevel() >= 2
end

function meta:IsSubmerged()
	return self:WaterLevel() >= 4
end
