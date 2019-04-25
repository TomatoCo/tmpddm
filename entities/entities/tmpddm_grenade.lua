AddCSLuaFile()
ENT.Type = "anim"

if SERVER then

    function ENT:Initialize()

        self.Entity:SetModel("models/weapons/w_grenade.mdl")
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
        self.Entity:SetSolid( SOLID_VPHYSICS )
        self.Entity:DrawShadow( true )
        
        local phys = self.Entity:GetPhysicsObject()

        util.SpriteTrail( self.Entity, 0, Color(255,255,255,255), false, 32, 0, 0.5, 1/16, "trails/plasma" )
        
        if (phys:IsValid()) then
            phys:Wake()
        end
        
        self.radius = 200
        self.damage = 150
    end

    function ENT:Explode()
        local pos = self.Entity:GetPos()
        
        self.Entity:EmitSound(Sound("weapons/hegrenade/explode"..math.random(3,5)..".wav"))
        
        util.BlastDamage( self.Entity, self.Owner, pos, self.radius, self.damage )
        
        local effectdata = EffectData()
        effectdata:SetOrigin( pos )
        util.Effect( "Explosion", effectdata, true, true )
        
        self.Entity:Remove()
    end

    /*---------------------------------------------------------
       Name: Touch
    ---------------------------------------------------------*/
    function ENT:Touch( entity )
        if (entity:IsPlayer() or entity:IsVehicle()) then
            self:Explode()
        end
    end

    function ENT:PhysicsCollide()
        self:Explode()
    end

end