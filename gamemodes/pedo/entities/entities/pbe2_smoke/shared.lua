ENT.Type 				= "anim"

function ENT:Initialize()
	if(SERVER)then
		self:SetModel( "models/weapons/w_grenade.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(1)
		end
	end
	self.CreatedTime = CurTime()
	self.Exploded = false
end
function ENT:Think()
	if(self.CreatedTime+3 < CurTime())then
		
		if(SERVER)then
			self:Remove()
		end
	end
end
function ENT:OnRemove()
	if(CLIENT)then
		if(self.Exploded == false)then
			sound.Play("weapons/grenade_launcher1.wav", self:GetPos(), 100)
			local em = ParticleEmitter(self:GetPos())
			for i=1, 20 do
				local prpos = VectorRand() * 40
				if(i%2 == 0)then
					model = Model("particle/particle_smokegrenade")
				else
					model = Model("particle/particle_noisesphere")
				end
				local part = em:Add(model, self:GetPos() + prpos + Vector(0,0,30))
				if part then
					local color = math.random(25, 150)
					part:SetColor(color, color, color)
					part:SetStartAlpha(255)
					part:SetEndAlpha(200)
					part:SetVelocity(VectorRand() * math.Rand(900, 1300))
					part:SetLifeTime(0)
					part:SetDieTime(math.Rand(20, 25))
					part:SetStartSize(math.random(300, 350))
					part:SetEndSize(1)
					part:SetRoll(math.random(-180, 180))
					part:SetRollDelta(math.Rand(-0.1, 0.1))
					part:SetAirResistance(600)
					part:SetCollide(true)
					part:SetBounce(0.4)
					part:SetLighting(false)
				end
			end

			em:Finish()
			self.Exploded = true
		end
	end
end