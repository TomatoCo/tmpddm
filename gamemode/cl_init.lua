include( "shared.lua" )

local pickupIcon = Material("materials/pickup.png")
local dropoffIcon = Material("materials/dropoff.png")
local carrierIcon = Material("materials/pizza.png")

local tr = {}
local trace = {start = Vector(0,0,0), endpos = Vector(0,0,0), filter = LocalPlayer(), output = tr}

local HASPIZZA = "You have the "

local function drawIcon(ent, icon, texttop, textbottom)
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

        surface.SetFont( "Trebuchet24" )

        surface.SetTextPos(ScrW()/2, ScrH()/2)
        local w1, h1 = surface.GetTextSize(texttop)
        local w2, h2 = surface.GetTextSize(textbottom)
        local x1, y1 = x - 32 + (32 - w1/2), y - 32 - h1
        local x2, y2 = x - 32 + (32 - w2/2), y + 32
        surface.SetTextColor(0,0,0,255)
        surface.SetTextPos(x1 + 1, y1 + 1)
        surface.DrawText(texttop)
        surface.SetTextPos(x2 + 1, y2 + 1)
        surface.DrawText(textbottom)

        surface.SetTextColor(255,255,255,255)
        surface.SetTextPos(x1, y1)
        surface.DrawText(texttop)
        surface.SetTextPos(x2, y2)
        surface.DrawText(textbottom)

    end
end

local function convertDist(dist)
    return math.floor(dist / 52.5 + 0.5)
end

local function drawTarget(self)
    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if ( !trace.Hit ) then return end
    if ( !trace.HitNonWorld ) then return end
    
    local text = "ERROR"
    local font = "TargetID"
    
    if ( trace.Entity:IsPlayer() ) then
        text = trace.Entity:Nick()
    else
        return
        --text = trace.Entity:GetClass()
    end
    
    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    
    local cx = ScrW() / 2
    local cy = ScrH() / 2
    
    x = cx - w / 2
    y = cy + 30
    
    -- The fonts internal drop shadow looks lousy with AA on
    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
    
    y = y + h + 5
    
    local text
    local timeremaining = trace.Entity:GetInvulnTimer() - CurTime()
    if timeremaining > 0 then
        text = "INVULN: " .. math.floor(timeremaining*10)/10
    else
        text = trace.Entity:Health() .. "%"
    end

    local font = "TargetIDSmall"
    
    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    local x = cx - w / 2
    
    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
end


function GM:HUDPaint()

    --TODO custom health display with invulernability display.

    local plys = {}
    for k,v in pairs(player.GetAll()) do
        plys[#plys+1] = v
    end
    table.sort(plys, function(a,b) return a:GetScore() > b:GetScore() end) -- high to low
    local ordered = {}
    for i,v in ipairs(plys) do
        if i <= 3 or i == #plys or v == LocalPlayer() then
            ordered[#ordered+1] = v:GetScore() .. ": " .. v:Nick()
        elseif ordered[#ordered] ~= "..." then
            ordered[#ordered+1] = "..."
        end
    end

    surface.SetFont( "Trebuchet24" )
    surface.SetTextColor(0,0,0,255)
    surface.SetTextPos(1,1)
    local maxwidth = 0
    for _,v in ipairs(ordered) do
        local w,h = surface.GetTextSize(v)
        maxwidth = math.max(maxwidth, w)
    end
    maxwidth = maxwidth + 5

    local x = ScrW() - maxwidth
    local y = 0
    for _,v in ipairs(ordered) do
        local w, h = surface.GetTextSize(v)
        surface.SetTextPos(x+1, y+1)
        surface.DrawText(v)
        y = y + h
    end

    local y = 0
    surface.SetTextColor(255,255,255,255)
    for _,v in ipairs(ordered) do
        local w, h = surface.GetTextSize(v)
        surface.SetTextPos(x, y)
        surface.DrawText(v)
        y = y + h
    end

    local destText = "Dropoff"
    if LocalPlayer():GetHasPizza() then
        destText = "GOAL"
        local w,h = surface.GetTextSize(HASPIZZA)
        local x = ScrW()/2 - w/2 - 32
        local y = ScrH()/2 + ScrH()/10 - h/2
        surface.SetTextColor(0,0,0,255)
        surface.SetTextPos(x+1, y+1)
        surface.DrawText(HASPIZZA)
        surface.SetTextColor(255,255,255,255)
        surface.SetTextPos(x, y)
        surface.DrawText(HASPIZZA)

        surface.SetMaterial(carrierIcon)
        surface.SetDrawColor(255,255,255,225)
        surface.DrawTexturedRect(ScrW()/2 + w/2 - 32, y + h/2 - 32, 64, 64)

        --TODO draw shit on screen
    else
        for k,v in pairs(player.GetAll()) do
            if v:GetHasPizza() then
                destText = "Guard"
            end
        end
    end

    for _,v in pairs(ents.GetAll()) do
        if v:IsPlayer() then
            if IsValid(v) and v:GetHasPizza() then
                if v ~= LocalPlayer() then
                    local dist = convertDist(v:GetPos():Distance(LocalPlayer():GetPos()))
                    drawIcon(v, carrierIcon, "KILL", dist .. "m")
                end
            end
        else
            local class = v:GetClass()
            if class == "tmpddm_pickup" then
                local dist = convertDist(v:GetPos():Distance(LocalPlayer():GetPos()))
                drawIcon(v, pickupIcon, "Pickup", dist .. "m")
            elseif class == "tmpddm_dropoff" then
                local dist = convertDist(v:GetPos():Distance(LocalPlayer():GetPos()))
                drawIcon(v, dropoffIcon, destText, dist .. "m")
            end
        end
    end

    drawTarget(self)
    -- also do speed meter
end


function GM:PostDrawViewModel( vm, ply, weapon )

    if ( weapon.UseHands || !weapon:IsScripted() ) then

        local hands = LocalPlayer():GetHands()
        if ( IsValid( hands ) ) then hands:DrawModel() end

    end

end
