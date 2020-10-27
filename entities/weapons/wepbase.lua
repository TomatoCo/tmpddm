-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

AddCSLuaFile( "wepbase.lua" )

CreateConVar("tf_ropehold", 0, bit.bor(FCVAR_USERINFO, FCVAR_ARCHIVE))

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
SWEP.Primary.EmptySound = Sound("Weapon_Pistol.Empty")
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

SWEP.MagneticBones = {}

local function computeMagnet(shootPos, target, bone)
	local boneId = target:LookupBone(bone)
	local bonePos = target:GetBonePosition(boneId)
	return (bonePos - shootPos):GetNormal()
end

function SWEP:getShootVector()
	local origin = self.Owner:GetShootPos()
	local forwardDir = self.Owner:GetAimVector()

	local realDir = forwardDir

	local bestVector
	local bestFrac = 0
	for k,v in pairs(player.GetAll()) do
		if v ~= self.Owner and IsValid(v) then
			for _,b in pairs(self.MagneticBones) do
				if b[1] then
					local vec = computeMagnet(origin, v, b[1])
					local dot = forwardDir:Dot(vec)
					local frac = math.max(0, 1 - math.max(0, (1-dot)/(1-b[2])))^2
					if frac > bestFrac then
						bestVector = vec
						bestFrac = frac
					end
				end
			end
		end
	end
	if bestFrac > 0 then
		realDir = LerpVector(bestFrac, forwardDir, bestVector)
	end
	return realDir
end

--[[
function SWEP:DrawHUD()
	local actualaimvector = self:getShootVector()
	actualaimvector = (self.Owner:GetShootPos() + 16384*actualaimvector):ToScreen()
	surface.SetDrawColor(255,255,255,255)
	surface.DrawLine(actualaimvector.x-5, actualaimvector.y-5, actualaimvector.x+5, actualaimvector.y+5)
	surface.DrawLine(actualaimvector.x+5, actualaimvector.y-5, actualaimvector.x-5, actualaimvector.y+5)
end
]]

function SWEP:ShootBullet( damage, num_bullets, aimcone )

	if SERVER then
		self.Owner:LagCompensation(true)
	end

	local origin = self.Owner:GetShootPos()
	local realDir = self:getShootVector()

	if SERVER then
		self.Owner:LagCompensation(false)
	end

	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= origin			-- Source
	bullet.Dir		= realDir			-- Dir of bullet
	bullet.Spread	= Vector( aimcone, aimcone, 0 )		-- Aim Cone
	bullet.Tracer	= 5						-- Show a tracer on every x bullets
	bullet.Force	= 1						-- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = self.Primary.Ammo

	self.Owner:FireBullets( bullet )
	self:ShootEffects()

end

function SWEP:PrimaryAttack()
    self:EmitSound(self.Primary.Sound)
    self:ShootBullet(15, 12, 0.15) --dmg, shots, spread
    self:SetNextPrimaryFire( CurTime() + 0.5 )
    self.Owner:SetInvulnTimer(0)
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end

function SWEP:SetupDataTables()

    self:NetworkVar( "Bool", 0, "Roping")
    self:NetworkVar( "Float", 0, "RopeLength")
    self:NetworkVar( "Entity", 0, "RopedEnt") -- the entity the melon is attached to
    self:NetworkVar( "Entity", 1, "TargetEnt") -- the entity that is shootable

	self:NetworkVar("Float", 3, "RopeTargetX")
	self:NetworkVar("Float", 4, "RopeTargetY")
	self:NetworkVar("Float", 5, "RopeTargetZ")

    self:NetworkVar( "Bool", 1, "DoubleJumped")

    self:NetworkVar( "Bool", 2, "WallRunning" )
    self:NetworkVar( "Vector", 0, "WallDir" )

    self:NetworkVar( "Bool", 3, "HasFinishedUnroping")

    self:NetworkVar( "Float", 1, "Reloading")
    self:NetworkVar( "Float", 2, "TriggerDownTime")

   if SERVER then
        self:SetRoping(false)
        self:SetRopeLength(-1)
        self:SetRopedEnt(nil)
		self:SetTargetEnt(nil)

		self:SetRopeTargetX(0)
		self:SetRopeTargetY(0)
		self:SetRopeTargetZ(0)

        self:SetDoubleJumped(true)

        self:SetWallRunning(false)
        self:SetWallDir(Vector(0,0,0))

        self:SetHasFinishedUnroping(false)

        self:SetReloading(-1)
        self:SetTriggerDownTime(-1)
    end

end


local matBeamCache = {}
local ca = Color(255,255,255,255)
hook.Add("PostDrawTranslucentRenderables", "TF_Roping", function()
    for k,v in pairs(player.GetAll()) do
        local wep = v:GetActiveWeapon()
        if wep.DoesStuff then
            if wep:GetRoping() then
                local ent = wep:GetRopedEnt()
                if IsValid(ent) or ent == game.GetWorld() then
                    local startPos = v:GetPos() + Vector(0,0,28)

                    local endPos = ent:LocalToWorld(Vector(wep:GetRopeTargetX(), wep:GetRopeTargetY(), wep:GetRopeTargetZ()))
                    local texOffset = 0

                    local texStart = texOffset*-0.4
                    local texEnd = texOffset*-0.4 + startPos:Distance(endPos) / 256

                    local matIndex = v:GetRopeIndex()
                    local matField = ROPE_LIST[matIndex]
                    if matField == nil then
                        matIndex = 1
                        matField = ROPE_LIST[matIndex]
                    end
                    local mat = matBeamCache[matIndex]
                    if mat == nil then
                        mat = Material( matField[2] )
                        matBeamCache[matIndex] = mat
                    end

                    render.SetMaterial( mat )
                    render.DrawBeam(startPos, endPos, 2, texStart, texEnd, ca)
                end
            end
        end
    end
end)

if SERVER then
    util.AddNetworkString( "TF_SoundEffects" )
end

sound.Add( {
    name = "tf_boostsound",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = SNDLVL_NORM ,
    pitch = { 75, 85 },
    sound = "player/suit_sprint.wav"
} )

local function SafePlaySound(ply, sound)
    if CLIENT and IsFirstTimePredicted() then
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

if CLIENT then
    net.Receive("TF_SoundEffects", function(len, ply)
        local ent = net.ReadEntity()
        local sound = net.ReadString()
        if IsValid(ent) then
            ent:EmitSound(sound)
        end
    end)
end

local function WallrunSound(ply, tr)
    if tr.Hit then
        local surfaceId = tr.SurfaceProps
        local data = util.GetSurfaceData(surfaceId)
        if data then
            local left, right = data.stepLeftSound, data.stepRightSound
            if left and right then
                SafePlaySound(ply, math.random() > 0.5 and left or right)
            elseif left then
                SafePlaySound(ply, left)
            elseif right then
                SafePlaySound(ply, right)
            end
        end
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

		local offset = ent:WorldToLocal(tr.HitPos)
		wep:SetRopeTargetX(offset.x)
		wep:SetRopeTargetY(offset.y)
		wep:SetRopeTargetZ(offset.z)

		if SERVER then
			local te = ents.Create("ts_ropepoint")
			te:SetPos(tr.HitPos)
			te:Spawn()
			if not tr.HitWorld then
				te:SetParent(tr.Entity)
			end
			te.OwnerWep = wep
			wep:SetTargetEnt(te)
		end

    end

end

local function RopeOff(ply, wep)
    if wep:GetRoping() then
		if SERVER then
			wep:GetTargetEnt():Remove()
			--TODO remove ropepoint
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
    local holdToRope = ply:GetInfoNum("tf_ropehold", 0) > 0
    local buttons = md:GetButtons()
    if holdToRope then
        if (bit.band(buttons, IN_ATTACK2) ~= 0) then
            if not wep:GetRoping() and wep:GetHasFinishedUnroping() then
                RopeOn(ply, wep)
                wep:SetHasFinishedUnroping(false)
            end
        else
            if wep:GetRoping() then
                RopeOff(ply, wep)
            end
            wep:SetHasFinishedUnroping(true)
        end
    else
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
    end

    if wep:GetRoping() then
        local ropedEnt = wep:GetRopedEnt()
        if not IsValid(ropedEnt) and ropedEnt ~= game.GetWorld() then
            RopeOff(ply, wep)
        else
            local plyPos = md:GetOrigin()
            local melPos = ropedEnt:LocalToWorld(Vector(wep:GetRopeTargetX(), wep:GetRopeTargetY(), wep:GetRopeTargetZ()))

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

                if IsValid(physObj) and (physObj:GetMass() > ropeMinMass) then
                    userVel = userVel - ropedEnt:GetVelocity()
                end

                local tensionVelMag = tensionDir:DotProduct(userVel)

                local strength = (stretch - ropeLength)
                if tensionVelMag < 0 then
                    strength = strength + (tensionVelMag * -1.25) -- > -1 is mushy, < -2 is positive feedback.
                end
                local ropeForce = tensionDir * strength

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
                local start = (ply:GetShootPos() + ply:GetPos())/2
                local tr = util.TraceLine({start = start, endpos = start + dir*32, filter = ply})

                if tr.Hit and not tr.HitSky then
                    dir = tr.HitNormal * -1
                    wep:SetWallDir(dir)
                    wep:SetWallRunning(true)

                    local vel = md:GetVelocity()

                    local eyeVec = eyeAngs:Forward()
                    if (bit.band(buttons, IN_FORWARD) ~= 0) then
                        local x = math.max(0, vel:Length() * vel:GetNormalized():Dot(eyeVec))
                        local scale = md:GetMaxSpeed()/320
                        local speed = (200 + (400 / (1 + math.exp((x - 1000)/200))))*scale

                        local accel = eyeVec*speed
                        accel.z = 0

                        vel = vel + accel*dt
                    end
                    if vel:GetNormal().z < eyeVec.z and vel.z < 50 then
                        WallrunSound(ply, tr)
                        vel = vel + Vector(0,0,200)
                    end

                    vel = vel + dir*600*dt

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
                SafePlaySound(ply, "tf_boostsound")
                vel = vel + -400*wep:GetWallDir()
                vel = vel + Vector(0, 0, 300)
                wep:SetWallDir(Vector(0,0,0))
                wep:SetWallRunning(false)
                wep:SetDoubleJumped(false)
            elseif wep:GetDoubleJumped() == false then
                SafePlaySound(ply, "tf_boostsound")
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

local function PackUpWeapon(ply, wep)
    if wep:GetRoping() then
        RopeOff(ply, wep)
    end
    wep:SetWallDir(Vector(0,0,0))
    wep:SetWallRunning(false)
    wep:SetDoubleJumped(true)
end

hook.Add("Move", "DoTheMoveful", function(ply, md)

    local dt = FrameTime()

    local wep = ply:GetActiveWeapon()

    if wep.DoesStuff then

        if (wep:GetReloading() ~= -1) then
            PackUpWeapon(ply, wep)
        else
            Roping(ply, md, dt, wep)
            WallRunning(ply, md, dt, wep)
            DoubleJumping(ply, md, dt, wep)
            SprintBoostJump(ply, md, dt, wep)
        end
    end
end)

function SWEP:OnRemove()
    PackUpWeapon(self.Owner, self)
end
function SWEP:Holster()
    PackUpWeapon(self.Owner, self)
end
function SWEP:OnDrop()
    PackUpWeapon(self.Owner, self)
end


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
