if CLIENT then
	SWEP.PrintName			= "Prop Repair Wrench"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 1
	SWEP.ViewModelFlip 		= false
	SWEP.WepSelectIcon 		= surface.GetTextureID("vgui/gfx/vgui/ak47")
end

SWEP.HoldType				= "melee2"
SWEP.Base					= "weapon_base"
SWEP.Spawnable				= true
SWEP.Category				= "Prop Health"

SWEP.ViewModel				= "models/weapons/c_stunstick.mdl"
SWEP.WorldModel				= "models/weapons/w_stunbaton.mdl"


SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic 		= true

SWEP.Secondary.Ammo 		= "none"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic	= true

SWEP.UseHands 				= true

function SWEP:Initialize()
	util.PrecacheSound("weapons/stunstick/stunstick_impact1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact2.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_swing1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_swing2.wav")
	
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(true)
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) < 50 then
		self:HealProp(trace.Entity)
	else
		self:Miss()
	end
end

function SWEP:SecondaryAttack()
	--[[
	local trace = self.Owner:GetEyeTrace()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) < 50 then
		self:DestroyProp(trace.Entity)
	else
		self:Miss()
	end
	--]]
end

function SWEP:HealProp(ent)

	--if ent:GetNWBool("hasburgerpropdamage",false) == true then
	if ent:GetNWFloat("propcurhealth",-1) ~= -1 then

		local health = ent:GetNWFloat("propcurhealth")
		local maxhealth = ent:GetNWFloat("propmaxhealth")
		
		local desired = math.Clamp(health + 1 + maxhealth*0.025,1,maxhealth)
			
		self.Owner:SetAnimation(PLAYER_ATTACK1)	
			
		if health < maxhealth then
		
			local colormod = (health/maxhealth) * 255
	
			if colormod > 0 then
				ent:SetColor( Color(colormod,colormod,colormod,255) )
			end
		
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			self:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1,2)..".wav")
			self:SetNextPrimaryFire(CurTime()+0.5)
			self:SetNextSecondaryFire(CurTime()+0.5)
			ent:SetNWFloat("propcurhealth", math.floor(desired)  )
			
		else
		
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			self:EmitSound("weapons/stunstick/spark"..math.random(1,2)..".wav")
				
			self:SetNextPrimaryFire(CurTime()+1)
			self:SetNextSecondaryFire(CurTime()+1)

		end
			
	
	end

end


function SWEP:DestroyProp(ent)
	if ent:GetNWBool("hasburgerpropdamage",false) == true then

		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self:EmitSound("weapons/stunstick/alyx_stunner"..math.random(1,2)..".wav")

		local damage = DamageInfo()
		damage:SetAttacker(self.Owner)
		damage:SetInflictor(self)
		damage:SetDamage(50 + ent:GetNWFloat("propcurhealth") * 0.05)
		damage:SetDamageType(DMG_DISSOLVE)
	
		ent:TakeDamageInfo(damage)
		
		self:SetNextPrimaryFire(CurTime()+1)
		self:SetNextSecondaryFire(CurTime()+1)
			
	
	end
end


function SWEP:Miss()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1,2)..".wav")
	self:SetNextPrimaryFire(CurTime()+0.75)
	self:SetNextSecondaryFire(CurTime()+0.75)
end