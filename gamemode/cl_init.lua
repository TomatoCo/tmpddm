include( "shared.lua" )

local pickupIcon = Material("materials/pickup.png")
local dropoffIcon = Material("materials/dropoff.png")
local carrierIcon = Material("materials/pizza.png")

local tr = {}
local trace = {start = Vector(0,0,0), endpos = Vector(0,0,0), filter = LocalPlayer(), output = tr}

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
        print(w1)
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

    local destText = "Dropoff"
    local dist
    if IsValid(holder) then
        if holder ~= LocalPlayer() then
            dist = math.floor(holder:GetPos():Distance(LocalPlayer():GetPos()) / 52.5 + 0.5)
            destText = "Guard"
            drawIcon(holder, carrierIcon, "KILL", dist .. "m")
        else
            destText = "GOAL"
            --TODO draw shit on the screen.
        end
    end

    if IsValid(pickup) then
        dist = math.floor(pickup:GetPos():Distance(LocalPlayer():GetPos()) / 52.5 + 0.5)
        drawIcon(pickup, pickupIcon, "Pickup", dist .. "m")
    end
    if IsValid(dropoff) then
        dist = math.floor(dropoff:GetPos():Distance(LocalPlayer():GetPos()) / 52.5 + 0.5)
        drawIcon(dropoff, dropoffIcon, destText, dist .. "m")
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
Double jump resets whenever you stand on the ground or begin wall running.
Rightclick to deploy your rope. And undeploy it. The rope CAN break from excessive tension.
Look up or down to control your vertical direction while wall running. Forward increases your speed
Remember, angular momentum is conserved. Reel in rope to go faster.
You always exit a swing perpendicular to the rope. Always try to enter perpendicular.

speedrun of objectives:
Pick up pizza from the Pickup points, deliver it to the Dropoff points.
Intercept pizza carriers to stop them from scoring.

Ignore how rough the gamemode is. I made it in like 2 hours. Fuck off.
Join our discord. Leave feedback. https://discord.gg/xUWv7pH
]]

function TMPDDM_MOTD()

    IntroFrame = vgui.Create( "DFrame" )
    IntroFrame:SetPos( 25,25 )
    IntroFrame:SetSize( 1230, 670 )
    IntroFrame:SetTitle( "-( ͡° ͜ʖ ͡°)╯╲___卐卐卐卐 don't mind me just walking my devs" ) --TODO really
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
    InstructionsLabel:SetPos( 0, 0 )
    InstructionsLabel:SetText( instructions )
    InstructionsLabel:SetFont("Trebuchet18")
    InstructionsLabel:SetSize( 1210, 580)
    InstructionsLabel:SetDark(true)

    local DoneButton = vgui.Create( "DButton", IntroFrame )
    DoneButton:SetText( "LET ME DELIVER PIZZA" )
    DoneButton:SetPos( 490, 590 )
    DoneButton:SetSize( 230, 30 )
    DoneButton.DoClick = function()
        IntroFrame:Close()
    end

end