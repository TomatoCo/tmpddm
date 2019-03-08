AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON)
    self:SetSolid( SOLID_BBOX )
    local b = 32
    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

    if SERVER then
        self:SetTrigger(true)
    end
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() then
        ent:SetHasPizza(true)            
        if SERVER then
            self:Remove()
        end
    end
end