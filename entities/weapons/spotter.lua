SWEP.Primary.Automatic = false

local trace = {start = Vector(0,0,0), endpos = Vector(0,0,0), filter = nil}

function SWEP:Initialize()
    self.posList = {}
end

function SWEP:Reload()
    print("res = {")
    for _,v in ipairs(self.posList) do
        print("    Vector(" .. v.x .. ", " .. v.y .. ", " .. v.z .. "),")
    end
    print("}")
end

function SWEP:Think()
    for _,v in ipairs(self.posList) do

        debugoverlay.Cross( v, 20, 1, Color( 0, 255, 0 ), false ) 
        debugoverlay.Cross( v, 10, 1, Color( 255, 0, 0 ), true ) 
    end
end

function SWEP:PrimaryAttack()
    trace.filter = self.Owner
    trace.start = self.Owner:GetShootPos()
    trace.endpos = trace.start + self.Owner:GetAimVector()*1e6
    local tr = util.TraceLine(trace)
    local realpos = tr.HitPos + (tr.HitNormal*32)
    self.posList[#self.posList+1] = tr.HitPos
end

function SWEP:SecondaryAttack()
    self.posList[#self.posList] = nil
end