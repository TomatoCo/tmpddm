-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

GM.Name = "Pizza Delivery Deathmatch"
GM.Author = "TomatoSoup"
GM.Email = "N/A"
GM.Website = "N/A"

AddCSLuaFile("player_ext.lua")
AddCSLuaFile("menu.lua")

include("player_ext.lua")
include("menu.lua")

function GM:Initialize()

end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

    local attacker = dmginfo:GetAttacker()

    local scale = 1

    if attacker ~= ply then

        if not (ply:GetHasPizza() or (IsValid(attacker) and attacker:GetHasPizza())) then
            scale = scale * 0.5
        end

        if ply:GetInvulnTimer() > CurTime() then
            scale = scale * 0
        end

        if ( hitgroup == HITGROUP_HEAD ) then

            scale = scale * 2

        end

        if ( hitgroup == HITGROUP_LEFTARM or
             hitgroup == HITGROUP_RIGHTARM or
             hitgroup == HITGROUP_LEFTLEG or
             hitgroup == HITGROUP_RIGHTLEG or
             hitgroup == HITGROUP_GEAR ) then

            scale = scale * 0.25
        end

    end

    dmginfo:ScaleDamage( scale )

end
