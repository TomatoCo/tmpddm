AddCSLuaFile( "rifle.lua" )

SWEP.PrintName = "Rifle"

SWEP.Author = "The guy who published"
SWEP.Contact = "steam account"
SWEP.Purpose = ""
SWEP.Instructions = "Why instructions to a very simple gun?"

SWEP.Category = "TomatoFall SWEPs"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/cstrike/c_rif_sg552.mdl"
SWEP.WorldModel = "models/weapons/w_rif_sg552.mdl"
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

SWEP.Base = "wepbase"

SWEP.Primary.Sound = Sound("Weapon_SG552.Single")
SWEP.Primary.BigSound = Sound("Weapon_AWP.Single")
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
    self.Owner:SetInvulnTimer(0)
    self:SetNextPrimaryFire( CurTime() + 0.125 )
    self:SetTriggerDownTime(0)
end

function SWEP:Reload()
end

function SWEP:Think()
    if self:GetTriggerDownTime() ~= -1 then
        local downTime = self:GetTriggerDownTime() + FrameTime()

        if not self.Owner:KeyDown(IN_ATTACK) then
            --TODO different sound for heavy attack, draw bigass tracer through the air
            if downTime > 0.5 then
                self:ShootBullet(75, 1, 0.0) --dmg, shots, spread
                self:EmitSound(self.Primary.BigSound)

                local start, endpos = self.Owner:GetShootPos(), self.Owner:GetEyeTrace().HitPos

                local fx = EffectData()
                fx:SetOrigin(start)
                fx:SetStart(endpos)
                util.Effect("smoketrail",fx)

                fx:SetOrigin(endpos)
                fx:SetStart(start)
                util.Effect("smoketrail",fx)

            else
                self:ShootBullet(25, 1, 0.03) --dmg, shots, spread
                self:EmitSound(self.Primary.Sound)
            end
            self:SetTriggerDownTime(-1)
        else
            self:SetTriggerDownTime(downTime)
        end
    end

end

function SWEP:TranslateFOV(fov)
    if self:GetTriggerDownTime() > 0.7 then
        return fov/4
    end
end

function SWEP:AdjustMouseSensitivity()
    if self:GetTriggerDownTime() > 0.7 then
        return 0.25
    end
    return 1
end