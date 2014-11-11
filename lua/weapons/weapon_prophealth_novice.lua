if CLIENT then
	SWEP.PrintName			= "Novice Prop Repair Tool"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.ViewModelFlip 		= false
end

SWEP.HoldType				= "melee2"
SWEP.Base					= "weapon_prophealth_base"
SWEP.Spawnable				= true
SWEP.AdminOnly				= false
SWEP.Category				= "Prop Health"

SWEP.ViewModel 		= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"

SWEP.HitSound 		= {}
SWEP.HitSound[0] 	= "physics/metal/metal_box_impact_bullet1.wav"
SWEP.HitSound[1] 	= "physics/metal/metal_box_impact_bullet2.wav"
SWEP.HitSound[2] 	= "physics/metal/metal_box_impact_bullet3.wav"

SWEP.MissSound 		= {}
SWEP.MissSound[0] 	= "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MissSound[1] 	= "weapons/slam/throw.wav"

SWEP.FailSound 		= {}
SWEP.FailSound[0] 	= "physics/metal/metal_computer_impact_soft1.wav"	
SWEP.FailSound[1] 	= "physics/metal/metal_computer_impact_soft2.wav"		

SWEP.HealStatic		= 5
SWEP.HealPercent	= 0.005
SWEP.MaxHealth		= 50000


