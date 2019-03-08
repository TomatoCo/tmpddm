AddCSLuaFile( "wepbase.lua" )

SWEP.PrintName = "LegendaryPOS"

SWEP.Author = "The guy who published"
SWEP.Contact = "steam account"
SWEP.Purpose = ""
SWEP.Instructions = "Why instructions to a very simple gun?"

SWEP.Category = "TomatoFall SWEPs"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.UseHands = true

SWEP.HoldType            = "crossbow"
SWEP.HoldTypeIron       = "ar2"
SWEP.HoldTypeReload     = "ar2"

SWEP.FiresUnderwater = true

SWEP.DrawCrosshair = true

SWEP.DrawAmmo = false

SWEP.Base = "weapon_base"

SWEP.Primary.Sound = Sound("Weapon_XM1014.Single")
SWEP.Primary.ClipSize = 35
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CSMuzzleFlashes = true

SWEP.DoesStuff = true

function SWEP:PrimaryAttack()
    self:EmitSound(Sound(self.Primary.Sound))
    self:ShootBullet(15, 20, 0.1)
    self:SetNextPrimaryFire( CurTime() + 0.2 )
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end

function SWEP:SetupDataTables()

    self:NetworkVar( "Bool", 0, "Roping")
    self:NetworkVar( "Float", 0, "RopeLength")
    self:NetworkVar( "Entity", 0, "RopeTarget") -- the melon entity
    self:NetworkVar( "Entity", 1, "RopedEnt") -- the entity the melon is attached to

    self:NetworkVar( "Bool", 1, "DoubleJumped")

    self:NetworkVar( "Bool", 2, "WallRunning" )
    self:NetworkVar( "Vector", 0, "WallDir" )

    self:NetworkVar( "Bool", 3, "HasFinishedUnroping")

   if SERVER then
        self:SetRoping(false)
        self:SetRopeLength(0)
        self:SetRopeTarget(nil)
        self:SetRopedEnt(nil)

        self:SetDoubleJumped(false)

        self:SetWallRunning(false)
        self:SetWallDir(Vector(0,0,0))

        self:SetHasFinishedUnroping(false)
        --to add,
        --ints: titan health, shield, energy, heat, corresponding maxes.
        --floats: possibly 3-4 for the other titan special cooldowns? plus one for the ult meter.
        --bools: titan doomed
    end

end


local matBeam = Material( "cable/cable_metalwinch01" )
local ca = Color(255,255,255,255)
hook.Add("PostDrawTranslucentRenderables", "TF_Roping", function()
    render.SetMaterial( matBeam )
    for k,v in pairs(player.GetAll()) do
        local wep = v:GetActiveWeapon()
        if wep.DoesStuff then
            if wep:GetRoping() then
                local ent = wep:GetRopeTarget()
                if IsValid(ent) then
                    local startPos = v:GetPos() + Vector(0,0,28)
                    local endPos = ent:GetPos()
                    local texOffset = 0

                    local texStart = texOffset*-0.4
                    local texEnd = texOffset*-0.4 + startPos:Distance(endPos) / 256
                    render.DrawBeam(startPos, endPos, 2, texStart, texEnd, ca)
                end
            end
        end
        end
end)

local boostSounds = {"player/suit_sprint.wav"}
local matToType = {MAT_CONCRETE = "other", MAT_DIRT = "soft", MAT_METAL = "metal", MAT_WOOD = "wood"}
local stringToType = {wood = "wood", concrete = "other", metal = "metal", wood = "wood"}
local wallStepSounds = {
    other = {"player/footsteps/concrete1.wav","player/footsteps/concrete2.wav","player/footsteps/concrete3.wav","player/footsteps/concrete4.wav"},
    soft = {"player/footsteps/dirt1.wav","player/footsteps/dirt2.wav","player/footsteps/dirt3.wav","player/footsteps/dirt4.wav"},
    wood = {"player/footsteps/wood1.wav","player/footsteps/wood2.wav","player/footsteps/wood3.wav","player/footsteps/wood4.wav",},
    metal = {"player/footsteps/metal1.wav","player/footsteps/metal2.wav","player/footsteps/metal3.wav","player/footsteps/metal4.wav",}
}


if SERVER then
    util.AddNetworkString( "TF_SoundEffects" )
end

local function SafePlaySound(ply, sound)
    if SERVER or (CLIENT and IsFirstTimePredicted()) then
        --if SERVER then
        --    SuppressHostEvents(ent) --SuppressHostEvents doesn't work with emitsound?
        --end
        if CLIENT then
            ply:EmitSound(sound)
        end
        if SERVER then
            local rf = RecipientFilter()
            rf:AddPAS(ply:GetPos())
            rf:RemovePlayer(ply)
            net.Start("TF_SoundEffects")
                net.WriteEntity(ply)
                net.WriteString(sound)
            net.Send(rf)
        end
    end
end

if CLIENT then
    net.Receive("TF_SoundEffects", function(len, ply)
        local ent = net.ReadEntity()
        local sound = net.ReadString()
        if IsValid(ent) then
            ent:EmitSound(sound)
        end
    end)
end

local function playRandomWallrunSound(ply, tr)
    if tr.Hit then
        local t
        if matToType[tr.MatType] then
            t = wallStepSounds[matToType[tr.MatType]]
        else
            for k,v in pairs(stringToType) do
                if string.find(tr.HitTexture, k) then
                    t = wallStepSounds[v]
                    break
                end
            end
            if not t then
                for k,v in pairs(stringToType) do
                    if IsValid(tr.Entity) then
                        local m = tr.Entity:GetModel()
                        if string.find(m,k) then
                            t = wallStepSounds[v]
                            break
                        end
                    end
                end
            end
        end
        t = t or wallStepSounds.other
        SafePlaySound(ply, t[math.random(#t)])
    end
end

local ropeMinMass = 10
local function TestCanRope(ply, wep)
    local user_aim = ply:GetAimVector()
    local s = ply:GetShootPos() -- Sets trace start position
    local e = s + ( user_aim * (75*52.5) ) -- Sets trace end position, range = constant number
    local tr = util.TraceLine( {start = s, endpos = e, filter = ply} ) -- Initiates the actual trace with the parameters stored in the trace
    if tr.HitSky then return end
    if tr.HitWorld then return true, tr end
    if tr.HitNonWorld and tr.Entity:IsValid() and ( not tr.Entity:IsPlayer() ) and ( not tr.Entity:IsWeapon() ) then
        if not tr.Entity then return end
        local phys = tr.Entity:GetPhysicsObject()
        if not phys or not IsValid(phys) then return end
        if not (phys:GetMass() > ropeMinMass) then return end
        return true, tr
    end
end

local function RopeOn(ply, wep)
    local can, tr = TestCanRope(ply)

    if can then
        local ent = tr.Entity
        local user_aim = tr.Normal
		local user_pos = ply:GetPos()
        wep:SetRoping(true)
        										-- Set hit position
		local tension = (tr.HitPos - user_pos):Length() + 32
        wep:SetRopeLength(tension)

        wep:SetRopedEnt(ent)
        if tr.HitWorld then
            ent = nil
        end

        if SERVER then
            local piton = ents.Create( "prop_physics" )
            piton:SetModel( "models/props_junk/watermelon01.mdl" ) --"models/props_junk/GlassBottle01a.mdl" "models/kunai.mdl"
            piton:SetPos( tr.HitPos + ( user_aim * -2.0 ) )
            piton:SetAngles( ( -1.0 * user_aim ):Angle() )
            piton:Spawn()
            piton:SetColor(0,0,0,255)
            piton:EmitSound( "weapons/crossbow/hit1.wav" )
            piton:SetKeyValue( "targetname", "vip_piton1" )
            piton:SetMoveType(MOVETYPE_NONE)
            local physent = piton:GetPhysicsObject()
            physent:EnableMotion(false)
            if ent then
                piton:SetParent(ent)
                physent:EnableCollisions(false)
            end

            wep:SetRopeTarget(piton)
        end
    end

end

local function RopeOff(ply, wep)
    if wep:GetRoping() then
        local ent = wep:GetRopeTarget()
        if IsValid(ent) then
            if SERVER then
                ent:EmitSound( "ambient/machines/slicer3.wav" )
                ent:Remove()
            end
        end
        wep:SetRoping(false)
        wep:SetRopeLength(0)
    end
end


local ropeMinMass = 10
local ropeCounterMass = 60
local ropePullback = 6
--TODO roping on causes wild spaz sometimes? Seems to mostly be on super thin brushes.
local function Roping(ply, md, dt, wep)
    local buttons = md:GetButtons()
    if (bit.band(buttons, IN_ATTACK2) ~= 0) then
        if wep:GetRoping() then
            if ((bit.band(md:GetOldButtons(), IN_ATTACK2)) == 0) then
                RopeOff(ply, wep)
                wep:SetHasFinishedUnroping(false)
            end
        else
            if wep:GetHasFinishedUnroping() then
                RopeOn(ply, wep)
            end
        end
    else
        wep:SetHasFinishedUnroping(true)
    end

    if wep:GetRoping() then
        local ent = wep:GetRopeTarget()
        local ropedEnt = wep:GetRopedEnt()
        if not (IsValid(ent) and (IsValid(ropedEnt) or ropedEnt == game.GetWorld())) then
            RopeOff(ply, wep)
        else
            local plyPos = md:GetOrigin()
            local melPos = ent:GetPos()

            local tension = melPos - plyPos
            local stretch = tension:Length()
            local ropeLength = wep:GetRopeLength()
            if stretch > (ropeLength + 250) then
                RopeOff(ply, wep)
            end

            if (bit.band(buttons, IN_SPEED) ~= 0) then
                local rewindLength
                if ropeLength > (stretch+32) then
                    rewindLength = 600
                else
                    rewindLength = 200
                end
                ropeLength = math.max(32, ropeLength - rewindLength*dt)
                wep:SetRopeLength(ropeLength)
            end

            if ropeLength < stretch then
                local tensionDir = tension:GetNormal()
                local userVel = md:GetVelocity()

                local physObj
                if IsValid(ropedEnt) and not ropedEnt:IsWorld() then
                    physObj = ropedEnt:GetPhysicsObject()
                end

                if IsValid(physObj) then
                    userVel = userVel - ropedEnt:GetVelocity()
                end

                local tensionVelMag = tensionDir:DotProduct(userVel)

                local ropeForce
                local strength = (stretch - ropeLength)
                if tensionVelMag < 0 then
                    --TODO what does this do?
                    ropeForce = tensionDir * ((tensionVelMag * -1.25) + strength)
                else
                    ropeForce = tensionDir * strength
                end

                if IsValid(physObj) then
                    local reactionForce = -1.0 * ropeCounterMass * ropeForce
                    physObj:ApplyForceOffset(reactionForce, melPos)
                end

                md:SetVelocity(userVel + ropeForce)
            end
        end
    end
end

local function WallRunning(ply, md, dt, wep)
    local buttons = md:GetButtons()
    if (not ply:IsOnGround()) then
        if (bit.band(buttons, IN_SPEED) ~= 0) then

            local eyeAngs = md:GetAngles()
            local perpendicular = eyeAngs:Right()
            local desiredPos = md:GetVelocity():GetNormal()
            if (bit.band(buttons, IN_MOVELEFT) ~= 0) then
                desiredPos = desiredPos - perpendicular/2
            elseif (bit.band(buttons, IN_MOVERIGHT) ~= 0) then
                desiredPos = desiredPos + perpendicular/2
            end

            local dir
            local start = (ply:GetShootPos() + ply:GetPos())/2

            if wep:GetWallRunning() then
                dir = wep:GetWallDir()
            else
                local dot = perpendicular:DotProduct(desiredPos)
                if (dot > 0) then
                    dir = perpendicular
                elseif (dot < 0) then
                    dir = -perpendicular
                end
            end

            if dir then
                local tr = util.TraceLine({start = start, endpos = start + dir*32, filter = ply})

                if tr.Hit and not tr.HitSky then
                    dir = tr.HitNormal*-1
                    wep:SetWallDir(dir)
                    wep:SetWallRunning(true)

                    local vel = md:GetVelocity()
                    dir.z = 0
                    if (vel.x^2 + vel.y^2) > vel.z^2 then
                        vel = vel + dir*600*dt
                    end
                    local eyeVec = eyeAngs:Forward()
                    if (bit.band(buttons, IN_FORWARD) ~= 0) then
                        local horizontalEyeVec = eyeAngs:Forward()
                        horizontalEyeVec.z = 0
                        vel = vel + horizontalEyeVec*240*dt
                    end
                    if vel:GetNormal().z < eyeVec.z and vel.z <= 50 then
                        playRandomWallrunSound(ply, tr)
                        vel = vel + Vector(0,0,200)
                    end
                    md:SetVelocity(vel)
                    return
                end
            end
        end
    end
    wep:SetWallRunning(false)
    wep:SetWallDir(Vector(0,0,0))
end

local function DoubleJumping(ply, md, dt, wep)
    if (ply:IsOnGround()) then
        wep:SetDoubleJumped(false)
    end

    local buttons = md:GetButtons()
    if (not ply:IsOnGround()) and (bit.band(buttons, IN_JUMP) ~= 0) then
        if (bit.band(md:GetOldButtons(), IN_JUMP) == 0) then
            local vel = md:GetVelocity()
            if wep:GetWallRunning() then
                SafePlaySound(ply, boostSounds[math.random(#boostSounds)])
                vel = vel + -400*wep:GetWallDir()
                vel = vel + Vector(0, 0, 300)
                wep:SetWallDir(Vector(0,0,0))
                wep:SetWallRunning(false)
                wep:SetDoubleJumped(false)
            elseif wep:GetDoubleJumped() == false then
                SafePlaySound(ply, boostSounds[math.random(#boostSounds)])
                local upForce = 300
                if vel.z < 0 then
                    upForce = upForce - vel.z/2
                end
                vel = vel + Vector(0,0, upForce)
                wep:SetDoubleJumped(true)
            end
            md:SetVelocity(vel)
        end
    end
end


local function SprintBoostJump(ply, md, dt, wep)
    local buttons = md:GetButtons()
    if bit.band( buttons, IN_JUMP ) ~= 0 and bit.band( md:GetOldButtons(), IN_JUMP ) == 0 and ply:OnGround() then
        local forward = md:GetAngles()
        forward.p = 0
        forward = forward:Forward()

        local speedBoostPerc = ( ( not ply:Crouching() ) and 0.5 ) or 0.1

        local speedAddition = math.abs( md:GetForwardSpeed() * speedBoostPerc )
        local maxSpeed = md:GetMaxSpeed() * ( 1 + speedBoostPerc )
        local newSpeed = speedAddition + md:GetVelocity():Length2D()

        -- Clamp it to make sure they can't bunnyhop to ludicrous speed
        if newSpeed > maxSpeed then
            speedAddition = speedAddition - (newSpeed - maxSpeed)
        end

        -- Reverse it if the player is running backwards
        if md:GetVelocity():Dot(forward) < 0 then
            speedAddition = -speedAddition
        end

        -- Apply the speed boost
        md:SetVelocity(forward * speedAddition + md:GetVelocity())
    end
end

hook.Add("Move", "DoTheMoveful", function(ply, md)

    local dt = FrameTime()

    local wep = ply:GetActiveWeapon()

    if wep.DoesStuff then
        if not ply:Alive() then
            if wep:GetRoping() then
                RopeOff(ply, wep) --TODO need to get rid of the melon on death/holster/etc.
            end
            wep:SetWallDir(Vector(0,0,0))
            wep:SetWallRunning(false)
            wep:SetDoubleJumped(false)
        else
            Roping(ply, md, dt, wep)
            WallRunning(ply, md, dt, wep)
            DoubleJumping(ply, md, dt, wep)
            SprintBoostJump(ply, md, dt, wep)
        end
    end
end)


if CLIENT then
    -- https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua use some inOut
    local cos, pi = math.cos, math.pi
    local function smooth(t, b, c, d) -- current: inOutSine
        return -c / 2 * (cos(pi * t / d) - 1) + b
    end

    local wallMod = 0
    local wallDir = Vector(0,0,0)
    hook.Add("CalcView", "WallrunLean", function(ply, origin, angles, fov, znear, zfar)
        local wep = LocalPlayer():GetActiveWeapon()
        if wep.DoesStuff then
            local dt = FrameTime()*4

            if wep:GetWallRunning() then
                wallDir = wep:GetWallDir()
                wallMod = wallMod + dt
            else
                --TODO trace in direction of travel, decide if about to run. 
                wallMod = wallMod - dt
            end

            wallMod = math.max(0,math.min(1,wallMod))

            local res = {origin = origin, fov = fov, znear = znear, zfar = zfar}
            local dot = angles:Right():Dot(wallDir)

            angles:RotateAroundAxis(angles:Forward(), -10*dot*smooth(wallMod, 0, 1, 1))
            res.angles = angles

            return res
            end
    end)
end
