AddCSLuaFile( "shotgun.lua" )

SWEP.PrintName = "Shotgun"

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

SWEP.Base = "wepbase"

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
    self:EmitSound(self.Primary.Sound)
    self:ShootBullet(10, 20, 0.12) --dmg, shots, spread
    self:SetNextPrimaryFire( CurTime() + 0.4 )
    self.Owner:SetInvulnTimer(0)
end

function SWEP:Reload()
end
