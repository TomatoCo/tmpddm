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
        if ent:GetHasPizza() then
            ent:SetHasPizza(false)
            local score = ent:GetScore()+1
            ent:SetScore(score)
            if SERVER then
                PrintMessage(HUD_PRINTCENTER, ent:GetName() .. " has delivered a pizza! Their score is " .. score)
                GAMEMODE:SpawnPizza()
                self:Remove()
            end
        end
    end
end