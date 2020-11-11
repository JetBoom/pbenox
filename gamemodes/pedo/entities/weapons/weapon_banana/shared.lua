if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName = "Banana Peel"
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.Base = "weapon_base"

SWEP.HoldReady = "grenade"
SWEP.HoldNormal = "slam"

SWEP.ViewModel = "models/weapons/v_banana.mdl"
SWEP.WorldModel = "models/weapons/w_banana.mdl"

SWEP.Weight = 5
SWEP.ViewModelFlip = false

SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false

SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IsGrenade = true
SWEP.NoSights = true
SWEP.DeploySpeed = 10

AccessorFuncDT(SWEP, "ThrowTime", "Float", 0)

function SWEP:Initialize()
	if self.SetWeaponHoldType then
		self:SetWeaponHoldType(self.HoldNormal)
	end

	self:SetDeploySpeed(self.DeploySpeed)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetWeaponHoldType(self.HoldReady)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:DoAttackEvent()
	self:Throw()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return self.Owner:IsIdle()
end

function SWEP:Throw()
	if CLIENT then return end

	local owner = self.Owner
	self:CreateObject(owner:GetShootPos(), Angle(0, 0, 0), owner:GetAimVector() * 800, Vector(600, math.random(-1200, 1200), 0), owner)
	self:EmitSound("weapons/slam/throw.wav")

	owner:StripWeapons()
end

function SWEP:GetObjectToMake()
	return "pbe2_banana"
end

function SWEP:CreateObject(src, ang, vel, angimp, ply)
	local gren = ents.Create(self:GetObjectToMake())
	if gren:IsValid() then
		gren:SetPos(src)
		gren:SetAngles(ang)
		gren:SetOwner(ply)
		gren:SetPhysicsAttacker(ply)
		gren:SetGravity(0.4)
		gren:SetFriction(0.2)
		gren:SetElasticity(0.45)
		gren:Spawn()
		gren:PhysWake()

		local phys = gren:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(vel)
			phys:AddAngleVelocity(angimp)
		end
	end

	return gren
end

function SWEP:Deploy()
	if self.SetWeaponHoldType then
		self:SetWeaponHoldType(self.HoldNormal)
	end

	return true
end

function SWEP:Holster()
	return true
end
