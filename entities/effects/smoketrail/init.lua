-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

EFFECT.Mat = Material( "trails/smoke" )

function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()
	self.EndPos 	= data:GetOrigin()

	self.DieTime = CurTime() + 3

end

function EFFECT:Think( )

	if ( CurTime() > self.DieTime ) then return false end

	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	local scale = ((self.DieTime - CurTime())/3)^0.3

	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, scale*3, 1, 0, Color(255,255,255,255))

end
