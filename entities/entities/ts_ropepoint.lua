-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

AddCSLuaFile()
ENT.Type = "anim"

sound.Add( {
    name = "tf_ropeoff",
    channel = CHAN_AUTO,
    volume = 0.5,
    level = SNDLVL_NORM ,
    pitch = { 95, 110 },
    sound = "ambient/machines/slicer3.wav"
} )
sound.Add( {
    name = "tf_ropeon",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = SNDLVL_NORM ,
    pitch = { 99, 101 },
    sound = "weapons/crossbow/hit1.wav"
} )

if SERVER then

    function ENT:Initialize()

        self:SetModel("models/props_junk/watermelon01.mdl")
        self:SetMoveType( MOVETYPE_NONE )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:DrawShadow( true )

        self:GetPhysicsObject():EnableMotion(false)

        self:EmitSound( "tf_ropeon" )
    end

    function ENT:OnTakeDamage()
        self:Remove()
    end

    function ENT:OnRemove()
        self.OwnerWep:SetRoping(false)
        self:EmitSound( "tf_ropeoff" )
    end

end
