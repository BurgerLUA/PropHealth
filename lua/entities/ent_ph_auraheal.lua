ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Aura Heal Machine"
ENT.Category = "Prop Health"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.HealStatic		= 1
ENT.HealPercent	= 0
ENT.Radius = 250

AddCSLuaFile()

if SERVER then

	sound.Add( {
		name = "ph_healer_loop", 
		channel = CHAN_STATIC, 
		volume = 1.0, 
		level = SNDLVL_IDLE, 
		pitch = {95, 110}, 
		sound = "ambient/machines/combine_shield_loop3.wav"
	} )
		
	sound.Add( {
		name = "ph_bitch_loop", 
		channel = CHAN_STATIC, 
		volume = 0.75, 
		level = SNDLVL_IDLE, 
		pitch = {140, 150}, 
		sound = "ambient/alarms/alarm_citizen_loop1.wav"
	} )
	
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end


function ENT:Initialize()

	self.TheCenter = self:GetPos() + self:GetRight()*12 + self:GetUp()*6 + self:GetForward()*-6

	if SERVER then
	
		self:SetModel("models/hunter/blocks/cube025x05x025.mdl") 
		self:SetAngles(Angle(0,0,90))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(0)
		end
		
		self:SetUseType(SIMPLE_USE)
		
		 self.NextHeal = 0
		 
		 self.Heat = 0
		 self.CoreHealth = 500
		
	end
	
	if CLIENT then
	
		self:SetRenderBounds( Vector(-1,-1,-1)*200, Vector(1,1,1)*200)
	
		self.detail3 = ClientsideModel( "models/maxofs2d/hover_plate.mdl" )
		self.detail3:SetPos(self.TheCenter)
		self.detail3:SetAngles(self:GetAngles() + Angle(0,0,-90))
		self.detail3:SetParent(self)
		self.detail3:Spawn()
	
	
		self.detail = ClientsideModel( "models/maxofs2d/hover_basic.mdl" )
		self.detail:SetPos(self.TheCenter + self.detail3:GetUp()*10)
		self.detail:SetAngles(self.detail3:GetAngles())
		self.detail:SetParent(self)
		self.detail:Spawn()

		self.detail2 = ClientsideModel( "models/maxofs2d/hover_rings.mdl" )
		self.detail2:SetPos(self.TheCenter + self.detail3:GetUp()*10)
		self.detail2:SetAngles(self.detail3:GetAngles())
		self.detail2:SetParent(self)
		self.detail2:Spawn()
		
		

		
		
		self.EffectRadius = 0

	end
		
	self.On = false

end

function ENT:OnRemove()
	if SERVER then
		self:StopSound("ph_healer_loop")
		self:StopSound("ph_bitch_loop")
	end

	if CLIENT then
		self.detail:Remove()
		self.detail2:Remove()
		self.detail3:Remove()
		--self.detail4:Remove()
	end
end

function ENT:Use(activator,caller,useType,value)
	if SERVER then
		if ( activator:IsPlayer() ) then
			if self.On == false then
				self.On = true
			else
				self.On = false
			end
		end
	end
end

function ENT:OnTakeDamage(dmginfo)

	local Mul
	
	if self.On == true then
		Mul = 1
	else
		Mul = 0.25
	end
		

	self.CoreHealth = math.max(0,self.CoreHealth - dmginfo:GetDamage()*Mul)
	
	self.Radius = self.CoreHealth/2

	if dmginfo:GetDamageType() ~= 268435464 then
		self:EmitSound("ambient/energy/newspark0"..math.random(1,9)..".wav")
	end
	
	local RandomCount =  math.random(1,100)
	local RandomMin = 100 - dmginfo:GetDamage()
	
	--print(RandomMin .. " <= " .. RandomCount )
	
	if self.CoreHealth <= 0 then 
		self:Detonate(dmginfo:GetAttacker())
	elseif not self:IsOnFire() and RandomMin <= RandomCount and self.On == true then
		self:Ignite(300,10)
		self:EmitSound("ph_bitch_loop")
	end
	
	--[[
	if self.On == 1 then
		self:StopSound("ph_healer_loop")
		self:EmitSound("ph_healer_loop",SNDLVL_IDLE, 100 + (1 - (self.CoreHealth/500))*50   )
	end
	--]]
	
	
	self:SetNWFloat("CoreHealth",self.CoreHealth)

end

function ENT:Detonate(attacker)

	if SERVER then
	
		if not attacker:IsValid() then return end
		
		
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() + Vector(0,0,100)) // not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 100 )
		effectdata:SetRadius( 5000 )
		
		
		
		util.Effect( "Explosion", effectdata)
		
		--util.BlastDamage(self, attacker, self:GetPos(), 400, 300)
		
		--self:EmitSound("weapons/hegrenade/explode"..math.random(3,5)..".wav",100,100)	
		
		SafeRemoveEntity(self)
		
	end
	
end



function ENT:Think()

	if CLIENT then
		--self:RunSphere()
	end


	if SERVER then
	
		self.TheCenter = self:GetPos() + self:GetRight()*12 + self:GetUp()*6 + self:GetForward()*-6
	
		--print(tostring(self) .. " START THINK: " .. tostring(self.TheCenter))
	
		if self.On then
		
			local phys = self:GetPhysicsObject()
			
			if not phys:IsMotionEnabled() then
				--print(self.Owner)
				--self:GetOwner():ChatPrint("This object cannot be frozen")
				phys:EnableMotion( true )
			end

			phys:ApplyForceCenter(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))*10)
			--phys:ApplyForceOffset( Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))*0.25, Vector(0,0,10) )
			
			self:SetNWInt("Skin",2)
			

			
			if not self.soundp then
				self:EmitSound("ph_healer_loop")
				self.soundp = true
			end
			
			if self.NextHeal < CurTime() then
			
				if self:IsOnFire() == false then
				
					--print(tostring(self) .. " FIND : " .. tostring(self.TheCenter))
					
					for k,v in pairs(ents.FindInSphere(self.TheCenter,5000)) do
						if v ~= self then
						
							if v:GetClass() == self:GetClass() then
								if v.TheCenter:Distance(self.TheCenter) <= (self.Radius + v.Radius) then
									self.On = false
								end
							end
						
							if v:GetPos():Distance(self.TheCenter) <= self.Radius then
								if v:GetClass() == "prop_physics" then
									self:HealProp(v)
								end
							end
							
						end
					end
					
				else
				
					for k,v in pairs(ents.FindInSphere(self.TheCenter,self.Radius)) do
					
						if v:IsPlayer() or v:IsNPC() then
							local dmginfo = DamageInfo()
							dmginfo:SetDamage( (self.Radius - v:GetPos():Distance(self.TheCenter))*0.1 )
							dmginfo:SetDamageType(DMG_RADIATION)
							dmginfo:SetAttacker(self)
							dmginfo:SetInflictor(self)
							dmginfo:SetDamagePosition(self:GetPos())
							
							v:TakeDamageInfo(dmginfo)
						end
					end

				end
				
				self.NextHeal = CurTime() + 1
				
			end
			
			
			if self:IsOnFire() then
				for k,v in pairs(ents.FindInSphere(self.TheCenter,self.Radius*2)) do
					if v:IsPlayer() then
						v:EmitSound("player/geiger"..math.random(1,3)..".wav",SNDLVL_30dB,math.Rand(90,100),0.25,CHAN_ITEM)
					end
				end
			end
			
			
			if self:IsOnFire() == false then
				self:StopSound("ph_bitch_loop")
			end
			
			
		else
			self.soundp = false
			self:StopSound("ph_healer_loop")
			self:StopSound("ph_bitch_loop")
			self:SetNWInt("Skin",0)
		
		end
	end

end

function ENT:Draw()
	if CLIENT then
		--self:DrawModel()

		self:RunSphere()
		
		
	end
end

--[[
function ENT:RenderOverride()
	
	--self:RunSphere()

end
--]]

local mat = Material("models/wireframe")


function ENT:RunSphere()

	self.detail:SetSkin(self:GetNWInt("Skin",0))
			
	if self:GetNWInt("Skin",0) == 2 or self.EffectRadius > 1 then
			
		local Amount
				
		if self:GetNWInt("Skin",0) == 2 then
			Amount = 1
		else
			Amount = -1
		end
		
				
		self.EffectRadius = math.Clamp(self.EffectRadius + Amount,0, self:GetNWFloat("CoreHealth",self.Radius*2)/2 )
				
		cam.Start3D(EyePos(),EyeAngles() + Angle(0,0,0) )
			render.SetMaterial( mat )
			render.DrawSphere( self.detail3:GetPos(), self.EffectRadius, 32, 32, Color(255,255,255,55) )
			render.DrawSphere( self.detail3:GetPos(), -self.EffectRadius, 32, 32, Color(255,255,255,55) )
		cam.End3D()
		
	else
				
		self.EffectRadius = 0
			
	end
	
end



function ENT:HealProp(ent)

	if ent:GetNWFloat("propcurhealth",-1) ~= -1 then
		
		local health = ent:GetNWFloat("propcurhealth")
		local maxhealth = ent:GetNWFloat("propmaxhealth")
		
		local percent = health/maxhealth
		
		if percent < 0.01 then return end
		
		local heal = self.HealStatic
		local desired = math.Clamp(health + heal ,1,maxhealth)	
		
		print(math.floor(CurTime()) .. ": " .. tostring(self) .. " healed " .. tostring(ent) .. " for 1 hp")
		
				
		if health < maxhealth then
			ent:SetNWFloat("propcurhealth", math.floor(desired)  )
		end
		

	end

end


