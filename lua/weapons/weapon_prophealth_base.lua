if CLIENT then
	SWEP.PrintName			= "Base Prop Repair Wrench"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.ViewModelFlip 		= false
end

SWEP.HoldType				= "melee2"
SWEP.Base					= "weapon_base"
SWEP.Spawnable				= false
SWEP.AdminOnly				= false
SWEP.Category				= "Prop Health"

SWEP.Primary.Ammo			= "none"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic 		= true

SWEP.Secondary.Ammo 		= "none"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic	= true

SWEP.UseHands 				= true

SWEP.ViewModel 		= "models/weapons/c_stunstick.mdl"
SWEP.WorldModel		= "models/weapons/w_stunbaton.mdl"


SWEP.HitSound 		= {}
SWEP.HitSound[0] 	= "weapons/stunstick/stunstick_impact1.wav"
SWEP.HitSound[1] 	= "weapons/stunstick/stunstick_impact2.wav"

SWEP.MissSound 		= {}
SWEP.MissSound[0] 	= "weapons/stunstick/stunstick_swing1.wav"
SWEP.MissSound[1] 	= "weapons/stunstick/stunstick_swing2.wav"

SWEP.FailSound 		= {}
SWEP.FailSound[0] 	= "weapons/stunstick/spark1.wav"	
SWEP.FailSound[1] 	= "weapons/stunstick/spark2.wav"	

SWEP.HealStatic		= 5
SWEP.HealPercent	= 0.005
SWEP.MaxHealth		= 50000


function SWEP:Initialize()
	--self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType( self.HoldType )
	
	if self.HoldType == "melee2" then
		self.AnimAttack1 = ACT_VM_HITCENTER
		self.AnimAttack2 = ACT_VM_MISSCENTER
	else
		self.AnimAttack1 = ACT_VM_SECONDARYATTACK
		self.AnimAttack2 = ACT_VM_PRIMARYATTACK
		--self.AnimAttack2 = ACT_VM_RELOAD
	end
	
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
		
		local heal = self.HealStatic +  ( maxhealth * self.HealPercent )
		local desired = math.Clamp(health + heal ,1,maxhealth)
			
		if health + heal > self.MaxHealth then
			if SERVER then
				self.Owner:ChatPrint("Your skill is too low to repair this prop.")
			end
			self:SetNWFloat("propcurhealth",self.MaxHealth)
			self:ErrorEffects()
		return end
		
			
			
		if SERVER then
		
			self:SetNWInt("proprepairhits",self:GetNWInt("proprepairhits") + 1)
			
			--[[
			if GAMEMODE.FolderName ~= "darkrp" then return end
			
			if (heal + health) > maxhealth then
				if health < maxhealth then

					local hits = self:GetNWInt("proprepairhits",0)
					
					local time = hits * 0.5
						
					--self.Owner:addMoney(award)
					--DarkRP.notify(self.Owner, 1, 7,  "You've been paid $"..award.." for repairing this prop!")
					self:SetNWInt("proprepairhits",0)
						
				end
			end
			--]]
			
		end
				
				
			if health < maxhealth then
				self:Hit()
				ent:SetNWFloat("propcurhealth", math.floor(desired)  )
			else
				self:ErrorEffects()
			end
			
	
	else

	end

end

function SWEP:DestroyProp(ent)
	if ent:GetNWBool("hasburgerpropdamage",false) == true then

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

	local count = table.Count(self.MissSound) - 2
	local rand = math.random(0,count)
	local sound = self.MissSound[rand]

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(self.AnimAttack2)
	self:EmitSound(sound)
	self:SetNextPrimaryFire(CurTime()+0.75)
	self:SetNextSecondaryFire(CurTime()+0.75)
end

function SWEP:Hit()

	local count = table.Count(self.HitSound) - 2
	local rand = math.random(0,count)
	local sound = self.HitSound[rand]
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(self.AnimAttack1)
	self:EmitSound(sound)
	self:SetNextPrimaryFire(CurTime()+0.5)
	self:SetNextSecondaryFire(CurTime()+0.5)
end

function SWEP:ErrorEffects()

	local count = table.Count(self.FailSound) - 2
	local rand = math.random(0,count)
	local sound = self.FailSound[rand]

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(self.AnimAttack1)
	self:EmitSound(sound)			
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
end