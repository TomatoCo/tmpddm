AddCSLuaFile( "boomstick.lua" )

SWEP.PrintName = "Rocket Lawnchair"

SWEP.Author = "The guy who published"
SWEP.Contact = "steam account"
SWEP.Purpose = ""
SWEP.Instructions = "Why instructions to a very simple gun?"

SWEP.Category = "TomatoFall SWEPs"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
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

SWEP.Primary.Sound = Sound("NPC_Helicopter.FireRocket")
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.DefaultClip = 1
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

    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    self:TakePrimaryAmmo(1)

    if SERVER then
        if SERVER then
            self.Owner:LagCompensation(true)
        end

        local ent = ents.Create( "tmpddm_grenade" )

        if ( !IsValid( ent ) ) then return end

        ent:SetOwner(self.Owner)
        ent.Owner = self.Owner

        ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
        ent:SetAngles( self.Owner:EyeAngles() )
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if ( !IsValid( phys ) ) then ent:Remove() return end

        local velocity = self.Owner:GetAimVector()

        phys:EnableDrag( false )
        phys:EnableGravity( false)
        phys:ApplyForceCenter((self.Owner:GetAimVector() * 10000) + self.Owner:GetVelocity())
        phys:AddAngleVelocity(Vector(0,5000,0))

        if SERVER then
            self.Owner:LagCompensation(false)
        end
    end

end

function SWEP:Reload()
    if self:GetReloading() == -1 then
        self.Owner:SetAnimation( PLAYER_RELOAD )

        self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)

        local runtime = self.Weapon:SequenceDuration(self.Owner:GetViewModel():GetSequence())/1.4
        self.Owner:GetViewModel():SetPlaybackRate(1.4)
        self:SetReloading(runtime)
    end
end

function SWEP:Think()
    if self:GetReloading() ~= -1 then
        local newReloading = self:GetReloading() - FrameTime()
        if newReloading < 0 then
            self.Weapon:SetClip1(1)
            self:SetReloading(-1)
        else
            self:SetReloading(newReloading)
        end
    end
end
