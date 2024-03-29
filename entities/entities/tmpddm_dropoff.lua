-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()

    self:SetModel("models/props_junk/wood_crate001a.mdl")

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON)
    self:SetSolid( SOLID_BBOX )
    local b = 48
    self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

    if SERVER then
        self:SetTrigger(true)
    end
    self.canDropOff = true
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() and self.canDropOff then
        if ent:GetHasPizza() then
            self.canDropOff = false
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
                if IsValid(ent.smoketrail) then
                    ent.smoketrail:Remove()
                end
                print("Delivered pizza spawning pizza")
                local pos = GAMEMODE:SpawnPizza("tmpddm_pickup", ent:GetPos())
                GAMEMODE:SpawnPizza("tmpddm_dropoff", pos)
                self:Remove()
            end
        end
    end
end
