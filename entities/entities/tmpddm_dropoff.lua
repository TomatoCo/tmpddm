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
            if score == 10 then
                for k,v in pairs(player.GetAll()) do
                    v:SetScore(0)
                end
                if SERVER then
                    PrintMessage(HUD_PRINTCENTER, ent:GetName() .. " has delivered ten pizzas! Restarting the scores")
                end
            else
                ent:SetScore(score)
                if SERVER then
                    PrintMessage(HUD_PRINTCENTER, ent:GetName() .. " has delivered a pizza! Their score is " .. score)
                end
            end
            if SERVER then
                GAMEMODE:SpawnPizza()
                self:Remove()
            end
        end
    end
end