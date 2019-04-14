AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON)
    self:SetSolid( SOLID_BBOX )
    local b = 32
    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))
    self.falling = false
    self.startpos = self:GetPos()
    self.endpos = Vector(0,0,0)
    self.fallspeed = 0
    self.falllerp = 0

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

function ENT:StartDrop()
    local res = util.TraceLine({start = self.startpos, endpos = self.startpos - Vector(0,0,2^16)})
    self.endpos = (res.HitPos + self.startpos)/2
    self.fallspeed = 30/(self.endpos:Length())
    self.falling = true
end

function ENT:Think()
    if self.falling then
        self.falllerp = math.min(1, self.falllerp + FrameTime()/30)
        self:SetPos(self.startpos, self.endpos, self.falllerp)
    end
end