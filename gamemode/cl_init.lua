-- Copyright (c) 2020 TomatoSoup
-- This file and tmpddm gamemode are released under AGPL

include( "shared.lua" )

CreateConVar("tf_highcontrastxhair", 0, bit.bor(FCVAR_USERINFO, FCVAR_ARCHIVE))

local pickupIcon = Material("materials/pickup.png")
local dropoffIcon = Material("materials/dropoff.png")
local carrierIcon = Material("materials/pizza.png")

local DontDraw = {
    CHudWeaponSelection = true,
    CHudHealth = true,
    CHudSecondaryAmmo = true,
    CHudAmmo = true,
    CHudCrosshair = true,
    CHudBattery = true
}

function GM:HUDShouldDraw( name )
    if DontDraw[name] then return false end
    return true
end

local function getScale(size)
    return size * math.min((ScrW()/640), ScrH()/480)
end

local smallscale = getScale(16)
surface.CreateFont("TS_HUD_Full", {font = "Coolvetica", size=smallscale})

local invertTab1 = {
    [ "$pp_colour_addr" ] = 0.0,
    [ "$pp_colour_addg" ] = 0.0,
    [ "$pp_colour_addb" ] = 0.0,
    [ "$pp_colour_brightness" ] = -1.0,
    [ "$pp_colour_contrast" ] = -1.0,
    [ "$pp_colour_colour" ] = -1.0,
    [ "$pp_colour_mulr" ] = 0.0,
    [ "$pp_colour_mulg" ] = 0.0,
    [ "$pp_colour_mulb" ] = 0.0
}

local invertTab2 = {
    [ "$pp_colour_addr" ] = 0.0,
    [ "$pp_colour_addg" ] = 0.0,
    [ "$pp_colour_addb" ] = 0.0,
    [ "$pp_colour_brightness" ] = 0,
    [ "$pp_colour_contrast" ] = 1,
    [ "$pp_colour_colour" ] = -1.0,
    [ "$pp_colour_mulr" ] = 0.0,
    [ "$pp_colour_mulg" ] = 0.0,
    [ "$pp_colour_mulb" ] = 0.0
}

local function drawCrosshair(ply)
    local dir = ply:GetAimVector()
    local startpos = ply:GetShootPos()
    local endpos = startpos+(16384*dir)

    dir = dir:Angle()

    local middledist = 0.05

    local xhairlen = 2

    local invertColors = ply:GetInfoNum("tf_highcontrastxhair", 0)

    if invertColors > 0 then
        render.SetStencilWriteMask( 0xFF )
        render.SetStencilTestMask( 0xFF )
        render.ClearStencil()

        render.SetStencilEnable( true )

        render.SetStencilReferenceValue( 1 )

        render.SetStencilCompareFunction( STENCIL_NEVER )
        render.SetStencilPassOperation( STENCIL_KEEP )
        render.SetStencilFailOperation( STENCIL_REPLACE )
        render.SetStencilZFailOperation( STENCIL_KEEP )

        surface.SetDrawColor(127, 127, 127, 1)
        draw.NoTexture()
    else
        surface.SetDrawColor(255, 0, 0, 200)
    end

    local pos, x, y

    pos = endpos + 16384*middledist*(dir:Right()) --right
    pos = pos:ToScreen()
    x,y = math.floor(pos.x+0.5),math.floor(pos.y+0.5)
    surface.DrawLine(x, y, x+xhairlen*10, y)

    pos = endpos - 16384*middledist*(dir:Right()) --left
    pos = pos:ToScreen()
    x, y = math.floor(pos.x+0.5),math.floor(pos.y+0.5)
    surface.DrawLine(x, y, x-xhairlen*10, y)

    pos = endpos + 16384*middledist*(dir:Up()) --up
    pos = pos:ToScreen()
    x, y = math.floor(pos.x+0.5),math.floor(pos.y+0.5)
    surface.DrawLine(x, y, x, y-xhairlen*10)

    pos = endpos - 16384*middledist*(dir:Up()) --down
    pos = pos:ToScreen()
    x, y = math.floor(pos.x+0.5),math.floor(pos.y+0.5)
    surface.DrawLine(x, y, x, y+xhairlen*10)

    surface.SetDrawColor(127, 127, 127, 127)
    pos = endpos:ToScreen()
    x, y = math.floor(pos.x+0.5),math.floor(pos.y+0.5)
    surface.DrawRect(x - 1, y - 1, 3, 3)

    if invertColors then

        render.SetStencilCompareFunction( STENCIL_EQUAL )
        render.SetStencilFailOperation( STENCIL_KEEP )

        if (invertColors == 1 or invertColors == 3) then
            DrawColorModify(invertTab1)
        end
        if (invertColors == 2 or invertColors == 3) then
            DrawColorModify(invertTab2)
        end

        render.SetStencilEnable( false )
    end
end


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
        local distAdjust = math.max(0,dist/(math.min(hx, hy)/5))
        local realAlpha = Lerp(distAdjust, 10, alpha)

        surface.SetMaterial(icon)
        surface.SetDrawColor(255,255,255,realAlpha)
        surface.DrawTexturedRect(x-32, y-32, 64, 64)

        surface.SetFont( "TS_HUD_Full" )

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

local function alivewep()
    return LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon().DoesStuff
end

local instructables = {
    {"Hold !KEY! to wallrun", "+speed", function() return alivewep() and not LocalPlayer():IsOnGround() end},
    {"Hold !KEY! to reel in the rope", "+speed", function() return alivewep() and LocalPlayer():GetActiveWeapon():GetRoping() end},
    {"Press !KEY! to attach rope", "+attack2", function() return alivewep() and not LocalPlayer():GetActiveWeapon():GetRoping() end},
    {"Press !KEY! to deattach rope", "+attack2", function() return alivewep() and LocalPlayer():GetActiveWeapon():GetRoping() end},
    {"Press !KEY! to double jump", "+jump", function() return alivewep() and not LocalPlayer():IsOnGround() and not LocalPlayer():GetActiveWeapon():GetDoubleJumped() end},
    {"Hold !KEY! to crouchslide", "+duck", function() return alivewep() and not LocalPlayer():IsOnGround() and LocalPlayer():GetVelocity():Length() > 300 end},
    {"Press !KEY! to reload (stops adv movement)", "+reload", function() return alivewep() and LocalPlayer():GetActiveWeapon():Clip1() > -1 end},
    {"Press !KEY! to open the menu", "gm_showspare1", function() return true end}
}

local function replaceKey(line)
    local result = line[1]
    if string.match(result, "!KEY!") then
        local key = input.LookupBinding(line[2])
        if key then
            result = string.gsub(result, "!KEY!", key)
        end
    end
    return result
end


function GM:HUDPaint()

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

    surface.SetFont( "TS_HUD_Full" )
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

    local y = ScrH() - 5
    surface.SetFont( "TargetID" )

    for k,v in pairs(instructables) do
        if v[3]() then
            local text = replaceKey(v)
            local w, h = surface.GetTextSize( text )
            local x = ScrW()/2 - w/2
            y = y - h

            surface.SetTextPos( x + 1, y + 1 )
            surface.SetTextColor(0,0,0,255)
            surface.DrawText(text)
            surface.SetTextPos( x, y )
            surface.SetTextColor(255,255,255,255)
            surface.DrawText(text)

        end
    end

    surface.SetFont( "TS_HUD_Full" )

    local text
    local dt = LocalPlayer():GetInvulnTimer() - CurTime()
    if dt > 0 then
        text = "INVULN: " .. math.floor(dt) .. "s"
    else
        text = "HP: " .. LocalPlayer():Health()
    end
    local x,y = ScrW()/2, ScrH()*0.75
    local w,h = surface.GetTextSize(text)
    surface.SetTextColor(0,0,0,255)
    surface.SetTextPos(x+1 - w/2,y + 1)
    surface.DrawText(text)
    surface.SetTextColor(255,255,255,255)
    surface.SetTextPos(x - w/2,y)
    surface.DrawText(text)

    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():Clip1() > -1 then
        y = y + h
        text = "MAG: " .. LocalPlayer():GetActiveWeapon():Clip1()
        local w,h = surface.GetTextSize(text)
        surface.SetTextColor(0,0,0,255)
        surface.SetTextPos(x+1 - w/2,y + 1)
        surface.DrawText(text)
        surface.SetTextColor(255,255,255,255)
        surface.SetTextPos(x - w/2,y)
        surface.DrawText(text)
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

    drawCrosshair(LocalPlayer())

    drawTarget(self)

    local text =  math.floor(LocalPlayer():GetVelocity():Length()/52.5 + 0.5) .. "m/s"
    local w,h = surface.GetTextSize(text)
    local x,y = 5, ScrH() - 5 - h
    surface.SetTextColor(0,0,0,255)
    surface.SetTextPos(x+1,y + 1)
    surface.DrawText(text)
    surface.SetTextColor(255,255,255,255)
    surface.SetTextPos(x,y)
    surface.DrawText(text)
end


function GM:PostDrawViewModel( vm, ply, weapon )

    if ( weapon.UseHands || !weapon:IsScripted() ) then

        local hands = LocalPlayer():GetHands()
        if ( IsValid( hands ) ) then hands:DrawModel() end

    end

end
