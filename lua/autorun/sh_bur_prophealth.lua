

CreateConVar("sv_prophealth_healthscale", "1", FCVAR_REPLICATED + FCVAR_ARCHIVE , "This is value that multiplies base total health." )



function PropSpawned(ply,model,ent)

	ent:SetNWBool("hasburgerpropdamage",true)
	ent:SetHealth(999999)

	ent:SetNWFloat("propcurhealth",1)
	ent:SetNWFloat("propmaxhealth",1)
	
end
hook.Add("PlayerSpawnedProp","Prop Damage Initialize",PropSpawned)

function PropTakeDamage( ent, dmg )

	if ent:GetNWBool("hasburgerpropdamage",false) == true then
		
		local health = ent:GetNWFloat("propcurhealth")
		local maxhealth = ent:GetNWFloat("propmaxhealth")
		
		if health - dmg:GetDamage() < 0 then
			ent:Fire( "break" )
			return
		end
		
		ent:SetNWFloat("propcurhealth",health - math.floor(dmg:GetDamage()))
		
		local colormod = (health/maxhealth) * 255
		
		if colormod > 0 then
			ent:SetColor( Color(colormod,colormod,colormod,255) )
		end
	
	end
	
end
hook.Add("EntityTakeDamage","Prop Take Damage",PropTakeDamage)

function PropThink()

	if CLIENT then return end

	for k,ent in pairs(ents.FindByClass("prop_physics")) do
			
		if ent:GetNWBool("hasburgerpropdamage",false) == true then
		
			--if ent:GetNWFloat("oldmass",-1) ~= ent:GetPhysicsObject():GetMass() then
				
				local oldhealth = ent:GetNWFloat("propcurhealth")
				local oldmaxhealth = ent:GetNWFloat("propmaxhealth")
				
				local scale = oldhealth/oldmaxhealth
				
				local volume = ent:GetPhysicsObject():GetVolume()
				local surfacearea = ent:GetPhysicsObject():GetSurfaceArea()
				local mass = ent:GetPhysicsObject():GetMass()
	
				local newmaxhealth = ((mass/volume) * mass * 10 ^ 4 + 100) * GetConVar("sv_prophealth_healthscale"):GetInt()

				ent:SetNWFloat("propmass",mass)
				ent:SetNWFloat("propcurhealth",math.floor(scale * newmaxhealth))
				ent:SetNWFloat("propmaxhealth",math.floor(newmaxhealth))
				
					
			--end

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
	
	if ent:GetNWBool("hasburgerpropdamage",false) == true then
	
		health = ent:GetNWFloat("propcurhealth")
		maxhealth = ent:GetNWFloat("propmaxhealth")
	
	
		draw.DrawText(health .. "/" .. maxhealth,"HudFontProp",x,y,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		
	end

end

hook.Add("HUDPaint", "Show Prop Health", ShowPropHealth)

surface.CreateFont( "PropHealthFont", {
	font = "Arial", 
	size = 24, 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )



function PropDamageDerma()

	local x = ScrW()/2
	local y = ScrH()/2


	local MenuBase = vgui.Create("DFrame")
		MenuBase:SetSize(x,y)
		MenuBase:SetPos(0,0)
		MenuBase:SetTitle("Prop Resistance")
		MenuBase:SetDeleteOnClose(false)
		MenuBase:SetDraggable( false )
		MenuBase:SetBackgroundBlur(false)
		MenuBase:Center(true)
		MenuBase:SetVisible( true )
		MenuBase.Paint = function()
			Update()
			draw.RoundedBox( 8, 0, 0, MenuBase:GetWide(), MenuBase:GetTall(), Color( 0, 0, 0, 150 ) )
		end
		MenuBase:MakePopup()
		
	--BEFORE WE BEGIN--
	local prop = LocalPlayer():GetEyeTrace().Entity
	local DeltaMass = prop:GetNWFloat("propmass")
	
	local StrengthLevel = prop:GetNWInt("propstrength",1)
	local AbsorbLevel = prop:GetNWInt("propabsorb",1)
	local ReinLevel = prop:GetNWInt("proprein",1)
	
	
	--NOW--
	
	local ModelInfo = vgui.Create( "DModelPanel", MenuBase )
	ModelInfo:SetPos(5,20)
	ModelInfo:SetSize(x/4,x/4)
	ModelInfo:SetModel(prop:GetModel())
	ModelInfo:SetCamPos(prop:OBBCenter() - prop:GetForward()*prop:OBBMaxs():Length()*2 + prop:GetUp()*50)
	ModelInfo:SetLookAt(prop:OBBCenter())
	
	local DStrength = vgui.Create ("DButton", MenuBase)
	DStrength:SetPos(x/4 + 50, 20)
	DStrength:SetSize(24,24)
	DStrength:SetText("-")
	DStrength.Paint = function()
		draw.RoundedBox( 8, 0, 0, DStrength:GetWide(), DStrength:GetTall(), Color( 255, 0, 0, 255 ) )
	end
	DStrength.DoClick = function()
		StrengthLevel = math.Max(StrengthLevel - 1,1)
		Update()
	end
	
	local IStrength = vgui.Create ("DButton", MenuBase)
	IStrength:SetPos(x/4 + 50 + 24, 20)
	IStrength:SetSize(24,24)
	IStrength:SetText("+")
	IStrength.Paint = function()
		draw.RoundedBox( 8, 0, 0, IStrength:GetWide(), IStrength:GetTall(), Color( 0, 255, 0, 255 ) )
	end
	
	IStrength.DoClick = function()
		StrengthLevel = StrengthLevel + 1
		Update()
	end
	
	local StrengthTitle = vgui.Create("DLabel", MenuBase)
	StrengthTitle:SetPos(x/4 + 50 + 24 + 24 + 5, 20)
	StrengthTitle:SetText("Strength: " .. StrengthLevel)
	StrengthTitle:SetFont("PropHealthFont")
	StrengthTitle:SizeToContents()
	
	---
	---
	---
	
	local DAbsorb = vgui.Create ("DButton", MenuBase)
	DAbsorb:SetPos(x/4 + 50, 20 + 24)
	DAbsorb:SetSize(24,24)
	DAbsorb:SetText("-")
	DAbsorb.DoClick = function()
		AbsorbLevel = math.Max(AbsorbLevel - 1,1)
		Update()
	end
	
	local IAbsorb = vgui.Create ("DButton", MenuBase)
	IAbsorb:SetPos(x/4 + 50 + 24, 20  + 24)
	IAbsorb:SetSize(24,24)
	IAbsorb:SetText("+")
	IAbsorb.DoClick = function()
		AbsorbLevel = AbsorbLevel + 1
		Update()
	end
	
	local AbsorbTitle = vgui.Create("DLabel", MenuBase)
	AbsorbTitle:SetPos(x/4 + 50 + 24 + 24 + 5, 20  + 24)
	AbsorbTitle:SetText("Absorption: " .. AbsorbLevel)
	AbsorbTitle:SetFont("PropHealthFont")
	AbsorbTitle:SizeToContents()
	
	---
	---
	---
	
	local DRein = vgui.Create ("DButton", MenuBase)
	DRein:SetPos(x/4 + 50, 20 + 24 + 24)
	DRein:SetSize(24,24)
	DRein:SetText("-")
	DRein.DoClick = function()
		ReinLevel = math.Max(ReinLevel - 1,1)
		Update()
	end
	
	local IRein = vgui.Create ("DButton", MenuBase)
	IRein:SetPos(x/4 + 50 + 24, 20  + 24 + 24)
	IRein:SetSize(24,24)
	IRein:SetText("+")
	IRein.DoClick = function()
		ReinLevel = ReinLevel + 1
		Update()
	end
	
	local ReinTitle = vgui.Create("DLabel", MenuBase)
	ReinTitle:SetPos(x/4 + 50 + 24 + 24 + 5, 20 + 24 + 24)
	ReinTitle:SetText("Reinforcement: " .. ReinLevel)
	ReinTitle:SetFont("PropHealthFont")
	ReinTitle:SizeToContents()
	
	
	
	
	
	
	function Update()
		--MassStat:SetText("Mass: " .. DeltaMass + (MassLevel + (MassLevel * DeltaMass * 0.15)) )
		--MassStat:SizeToContents()
		
		StrengthTitle:SetText("Strength: " .. StrengthLevel .. " (+" ..StrengthLevel*0.15 .. "% Health)")
		StrengthTitle:SizeToContents()
		
		AbsorbTitle:SetText("Absorption: " .. AbsorbLevel  .. " (+" ..AbsorbLevel*0.5 .. " Damage Resistance)")
		AbsorbTitle:SizeToContents()
		
		ReinTitle:SetText("Reinforcement: " .. ReinLevel .. " (+" ..ReinLevel*50 .. " Health)")
		ReinTitle:SizeToContents()
		
	end
	
	--[[
	local NewMass = vgui.Create ("DLabel", MenuBase)
	NewMass:SetPos(x/4 + 50 + 24 + 24 + 5, 20)
	NewMass:SetText("Mass:")
	NewMass:SetFont("PropHealthFont")
	NewMass:SizeToContents()
	--]]
	
	
	
	--local IMass
	
	
	
		
		
		
		
end

concommand.Add("showpropderma", PropDamageDerma)




