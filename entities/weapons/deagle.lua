AddCSLuaFile( "deagle.lua" )

SWEP.PrintName = "DEAGLE"

SWEP.Author = "The guy who published"
SWEP.Contact = "steam account"
SWEP.Purpose = ""
SWEP.Instructions = "Why instructions to a very simple gun?"

SWEP.Category = "TomatoFall SWEPs"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
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

SWEP.Primary.Sound = Sound("Weapon_DEagle.Single")
SWEP.Primary.ClipSize = 7
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CSMuzzleFlashes = true

SWEP.DoesStuff = true

function SWEP:PrimaryAttack()
    self.Owner:SetInvulnTimer(0)

    if self.Weapon:Clip1() <= 0 or self:GetReloading() ~= -1 then
        self:EmitSound( self.Primary.EmptySound )
        self:SetNextPrimaryFire( CurTime() + 0.2 )
        return
    end

    self:EmitSound(self.Primary.Sound)
    self:ShootBullet(50, 1, 0.04) --dmg, shots, spread
    self:SetNextPrimaryFire( CurTime() + 0.1 )
    self:TakePrimaryAmmo(1)
end

function SWEP:Reload()
    if self:GetReloading() == -1 then
        self.Owner:SetAnimation( PLAYER_RELOAD )

        self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)

        local runtime = self.Weapon:SequenceDuration(self.Owner:GetViewModel():GetSequence())
        self:SetReloading(runtime)
    end
end

function SWEP:Think()
    if self:GetReloading() ~= -1 then
        local newReloading = self:GetReloading() - FrameTime()
        if newReloading < 0 then
            self.Weapon:SetClip1(7)
            self:SetReloading(-1)
        else
            self:SetReloading(newReloading)
        end
    end
end