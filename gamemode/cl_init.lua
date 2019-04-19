include( "shared.lua" )

local pickupIcon = Material("materials/pickup.png")
local dropoffIcon = Material("materials/dropoff.png")
local carrierIcon = Material("materials/pizza.png")

local tr = {}
local trace = {start = Vector(0,0,0), endpos = Vector(0,0,0), filter = LocalPlayer(), output = tr}

local HASPIZZA = "You have the PIZZA!"

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
        local x = ScrW()/2 - w/2
        local y = ScrH()/2 + ScrH()/10 - h/2
        surface.SetTextColor(0,0,0,255)
        surface.SetTextPos(x+1, y+1)
        surface.DrawText(HASPIZZA)
        surface.SetTextColor(255,255,255,255)
        surface.SetTextPos(x, y)
        surface.DrawText(HASPIZZA)

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

local instructions = [[
speedrun of instructions:
Shift to sprint, reel in rope, and wallrun.
Spacebar to jump off of a wall and double jump.
Wallrunning is pretty automatic but holding left/right towards the wall can hint the code to what you really want.
Look up or down to control your vertical direction while wall running. Forward increases your speed.
Double jump resets whenever you stand on the ground or begin wall running.
Rightclick to deploy your rope. And undeploy it. The rope CAN break from excessive tension.
You can also shoot a rope connection point to break it. Ignore the watermelon gibs. I just needed a breakable prop.
Remember, angular momentum is conserved. Reel in rope to go faster.
You always exit a swing perpendicular to the rope. Always try to enter perpendicular to keep your speed.

speedrun of objectives:
Pick up pizza from the Pickup points, deliver it to the Dropoff points.
Intercept pizza carriers to stop them from scoring.
Quote Raimi Spiderman as much as possible.
]]

local contact = "Join our discord. Ask for TomatoSoup. Leave feedback. https://discord.gg/xUWv7pH"

function TMPDDM_MOTD()

    IntroFrame = vgui.Create( "DFrame" )
    IntroFrame:SetPos( 25,25 )
    IntroFrame:SetSize( 1230, 670 )
    IntroFrame:SetTitle( "-( ͡° ͜ʖ ͡°)╯ hello there!" )
    IntroFrame:SetVisible( true )
    IntroFrame:SetDraggable( true )
    IntroFrame:ShowCloseButton( true )
    IntroFrame:MakePopup()
    IntroFrame.OnClose = function()
        surface.PlaySound("pizzatime.mp3")
    end

    local TopPanel = vgui.Create( "DPanel", IntroFrame )
    TopPanel:SetPos( 10, 30 )
    TopPanel:SetSize( 1210, 580)

    local InstructionsLabel = vgui.Create( "DLabel", TopPanel )
    InstructionsLabel:SetPos( 5, 5 )
    InstructionsLabel:SetText( instructions )
    InstructionsLabel:SetFont("Trebuchet18")
    InstructionsLabel:SetSize( 700, 285)
    InstructionsLabel:SetDark(true)

    local ContactLabel = vgui.Create( "DLabel", TopPanel )
    ContactLabel:SetPos( 5, 295 )
    ContactLabel:SetText( contact )
    ContactLabel:SetFont("Trebuchet18")
    ContactLabel:SetSize( 700, 280)
    ContactLabel:SetDark(true)

    local DoneButton = vgui.Create( "DButton", IntroFrame )
    DoneButton:SetText( "LET ME DELIVER PIZZA" )
    DoneButton:SetPos( 490, 590 )
    DoneButton:SetSize( 230, 30 )
    DoneButton.DoClick = function()
        IntroFrame:Close()
    end

end