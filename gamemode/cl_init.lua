include( "shared.lua" )

local pickupIcon = Material("materials/pickup.png")
local dropoffIcon = Material("materials/dropoff.png")
local carrierIcon = Material("materials/pizza.png")

local tr = {}
local trace = {start = Vector(0,0,0), endpos = Vector(0,0,0), filter = LocalPlayer(), output = tr}

local function drawIcon(ent, icon)
    local pos = ent:GetPos()
    local res = pos:ToScreen()
    if res.visible then
        local x, y = res.x, res.y
        local start = LocalPlayer():GetShootPos()
        trace.start = start
        trace.endpos = pos
        trace.filter = LocalPlayer()
        util.TraceLine(trace)
        local alpha = 100
        if tr.Entity == ent or tr.HitPos:DistToSqr(start) < 256 then
            alpha = 200
        end

        local hx, hy = ScrW()/2, ScrH()/2
        local dist = math.sqrt((hx-x)^2 + (hy-y)^2)
        local distAdjust = math.max(0,dist/(math.min(hx, hy)/10))
        local realAlpha = Lerp(distAdjust, 100, alpha)

        surface.SetMaterial(icon)
        surface.SetDrawColor(255,255,255,realAlpha)
        surface.DrawTexturedRect(x-32, y-32, 64, 64)
    end
end

function GM:HUDPaint()

    local pickup, dropoff, holder
    for _,v in pairs(ents.GetAll()) do
        if v:IsPlayer() then
            if v:GetHasPizza() then
                holder = v
            end
        else
            local class = v:GetClass()
            if class == "tmpddm_pickup" then
                pickup = v
            elseif class == "tmpddm_dropoff" then
                dropoff = v
            end
        end

    end

    if IsValid(pickup) then
        drawIcon(pickup, pickupIcon)
    end
    if IsValid(dropoff) then
        drawIcon(dropoff, dropoffIcon)
    end
    if IsValid(holder) then
        if holder ~= LocalPlayer() then
            drawIcon(holder, carrierIcon)
        else
            --TODO draw shit on the screen.
        end
    end

    -- draw pizzas
    -- pizza pointing up for pickup. pizza pointing down for dropoff. full pie for who currently has it.
    -- also do speed meter and indicator for score.
end


function GM:PostDrawViewModel( vm, ply, weapon )

    if ( weapon.UseHands || !weapon:IsScripted() ) then

        local hands = LocalPlayer():GetHands()
        if ( IsValid( hands ) ) then hands:DrawModel() end

    end

end