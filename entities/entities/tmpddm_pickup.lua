AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()

    self:SetModel("models/props_junk/wood_crate001a.mdl")

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON)
    self:SetSolid( SOLID_BBOX )
    local b = 48
    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))
    self.falling = false
    self.startpos = self:GetPos()
    self.endpos = Vector(0,0,0)
    self.fallend = 0
    self:SetRespawnTime(-1)

    if SERVER then
        self:SetTrigger(true)
    end

end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "RespawnTime")

    if SERVER then
        self:SetRespawnTime(-1)
    end
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() then
        ent:SetHasPizza(true)
        ent:SetInvulnTimer(CurTime() + 2)

        if SERVER then
            self:Remove()
            local trail = util.SpriteTrail( ent, 0, Color(255,255,255,255), false, 24, 8, 5, 1/16, "trails/laser" )
            ent.smoketrail = trail
        end
    end
end

function ENT:StartDrop()
    local res = util.TraceLine({start = self.startpos, endpos = self.startpos - Vector(0,0,2^16), filter = self})
    self.endpos = (res.HitPos + self.startpos)/2
    self.falling = true
    self.fallend = CurTime() + 15
    self:SetRespawnTime(CurTime() + 30)
end

function ENT:Think()
    if self.falling then
        self.falllerp = math.max(0, (self.fallend - CurTime())/15)
        self:SetPos(LerpVector(1-self.falllerp, self.startpos, self.endpos))
    end

    if SERVER then
        local respawnTime = self:GetRespawnTime()
        if respawnTime ~= -1 and respawnTime < CurTime() then
            local pos = Vector(0,0,0)
            local num = 0
            for k,v in pairs(player.GetAll()) do
                pos = pos + v:GetPos()
                num = num + 1
            end
            GAMEMODE:SpawnPizza("tmpddm_pickup", pos/num)
            print("Dropped pizza spawning pizza")
            self:Remove()
        end
    end
end