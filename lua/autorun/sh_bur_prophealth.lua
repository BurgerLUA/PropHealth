

CreateConVar("sv_prophealth_healthscale", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE , "This is value that multiplies base total health." )

function InitializePropHealth(ent)

	local volume = ent:GetPhysicsObject():GetVolume()
	local surfacearea = ent:GetPhysicsObject():GetSurfaceArea()
	local mass = ent:GetPhysicsObject():GetMass()
	
	ent.MaxHealth = math.ceil(volume * 0.1/12.77 * GetConVar("sv_prophealth_healthscale"):GetInt())
			
	ent:SetNWFloat("propmass",mass)
	ent:SetNWFloat("propcurhealth",ent.MaxHealth)
	ent:SetNWFloat("propmaxhealth",ent.MaxHealth)
	ent:SetNWInt("proprepairhits",0)

end

function PropTakeDamage( ent, dmg )
	
	if ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_ragdoll" then
	
		if IsValid(dmg:GetInflictor()) then
			if dmg:GetInflictor():GetClass() == "stunstick" then return end
		end
		
		local health = ent:GetNWFloat("propcurhealth")
		local maxhealth = ent:GetNWFloat("propmaxhealth")
		
		local takeaway = health - math.floor(dmg:GetDamage())
		
		ent:SetNWFloat("propcurhealth",math.Max(0,takeaway))
		
		if takeaway <= 0 then
			ent.RegenPeriod = true
			ent:SetNWInt("damagedcurtime",CurTime() + 120)
		else
			ent:GetPhysicsObject():EnableCollisions(true)
		end

	
	end
	
end

hook.Add("EntityTakeDamage","Prop Take Damage",PropTakeDamage)

function PropThink()

	if CLIENT then return end

	local NewTable = ents.FindByClass("prop_physics")
	NewTable = table.Add(NewTable,ents.FindByClass("prop_ragdoll"))
	
	
	for k,ent in pairs(NewTable) do
	
		if not IsValid(ent:GetPhysicsObject()) then return end
	
	
		if not ent.MaxHealth then
			
			InitializePropHealth(ent)
			
		else
		
			local scale = ent:GetNWFloat("propcurhealth",ent.MaxHealth) / ent:GetNWFloat("propmaxhealth",ent.MaxHealth)

		
			if ent:GetNWFloat("propcurhealth") == 0 then
			
				ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				ent:SetMaterial("models/wireframe")
				ent:SetColor(Color(255,255,255,255))

			else
			
				if ent:GetMaterial() == "models/wireframe" then
					ent:SetMaterial("")
				end
				
				if ent:GetPhysicsObject():IsPenetrating() == false then
					ent:SetCollisionGroup(COLLISION_GROUP_NONE)
				end
				
				ent.RegenPeriod = false
				
				local colormod = scale * 255

			end

			if ent:GetNWInt("damagedcurtime",CurTime() + 1) <= CurTime() then
				
				if ent.RegenPeriod == true then
					local newhealth = math.max(2,math.floor(ent:GetNWFloat("propmaxhealth",1) * 0.01))
					
					ent:SetNWFloat("propcurhealth", newhealth )
					ent.RegenPeriod = false
				end
				
			end

			
		end
	end
end

hook.Add("Think", "Prop Think", PropThink)


if SERVER then return end

surface.CreateFont( "HudFontProp", {
	font = "roboto condensed", 
	size = 24, 
	weight = 0, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = true, 
	additive = false, 
	outline = false, 
} )


function ShowPropHealth()
	
	local x = ScrW()/2
	local y = ScrH()/2 + ScrH()/16
	
	local ent = LocalPlayer():GetEyeTrace().Entity
	
	if IsValid(ent) == false then return end
	
	if ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_ragdoll" then
		health = ent:GetNWFloat("propcurhealth")
		maxhealth = ent:GetNWFloat("propmaxhealth")
	
	
		local hitstotake = math.ceil((maxhealth - health) / (5 + maxhealth*0.005))
		local time = hitstotake * 0.5
		
		
		local autofelatio = math.floor(ent:GetNWInt("damagedcurtime",-1) - CurTime())
	
		if health == 0 then
			draw.DrawText("Repair Time: "..time.. " sec","HudFontProp",x,y,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Automatic Self-Repair Time: " .. autofelatio .. " sec","HudFontProp",x,y + 24,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		else
			if LocalPlayer():KeyDown(IN_RELOAD) then
				draw.DrawText("Repair Time: "..time.. " sec","HudFontProp",x,y,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			else
				draw.DrawText(health .. "/" .. maxhealth,"HudFontProp",x,y,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
		end

	end

end

hook.Add("HUDPaint", "Show Prop Health", ShowPropHealth)