
local mat = Material("models/effects/vortshield")

function DrawTest()
	--[[
	cam.Start3D(EyePos(),EyeAngles() + Angle(0,0,0) )
	
		for k,v in pairs(ents.FindByClass("ent_ph_auraheal")) do
			render.SetMaterial( mat )
			render.DrawSphere( v.detail3:GetPos(), v.EffectRadius, 32, 32, Color(255,255,255,55) )
			render.DrawSphere( v.detail3:GetPos(), -v.EffectRadius, 32, 32, Color(255,255,255,55) )
		end
	
	cam.End3D()
	--]]
	
end

hook.Add("HUDPaint","Prop Aura Sphere",DrawTest)