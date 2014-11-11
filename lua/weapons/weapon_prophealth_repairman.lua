if CLIENT then
	SWEP.PrintName			= "Master Prop Repair Tool"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.ViewModelFlip 		= false
end

SWEP.HoldType				= "melee2"
SWEP.Base					= "weapon_prophealth_base"
SWEP.Spawnable				= true
SWEP.AdminOnly				= false
SWEP.Category				= "Prop Health"

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

SWEP.HealStatic		= 10
SWEP.HealPercent	= 0.01
SWEP.MaxHealth		= 100000


