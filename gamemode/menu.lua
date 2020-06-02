WEAPON_LIST = {
    {"models/weapons/w_shot_xm1014.mdl", "shotgun", "Shotgun", "Semi shotgun. No reloading."},
    {"models/weapons/w_smg_p90.mdl", "smg", "Submachine Gun", "High capacity SMG. Can't maneuver when reloading."},
    {"models/weapons/w_rif_sg552.mdl", "rifle", "Rifle", "Semi rifle. Hold to charge and zoom. No reloading."},
    {"models/weapons/w_rocket_launcher.mdl", "boomstick", "Rocket Launcher", "Rocket Launcher. Can't maneuver when reloading."},
    {"models/weapons/w_pist_deagle.mdl", "deagle", "Deagle", "High power handgun. Run faster. Can't maneuver when reloading."}
}

ROPE_LIST = {
    {"Rope", "cable/rope"},
    {"Cable", "cable/cable2"},
    {"XBeam", "cable/xbeam"},
    {"Laser", "cable/redlaser"},
    {"Electric", "cable/blue_elec"},
    {"Physbeam", "cable/physbeam"},
    {"Hydra", "cable/hydra"}
}

MODEL_CONTROLS = {}
MODEL_CONTROLS["breen"] = {"TomatoSoup"}



if CLIENT then
    CreateConVar( "tmpddm_playermodel", "NOTSET", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The player model to use" )
    CreateConVar( "tmpddm_ropeindex", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The player model to use" )
    CreateConVar( "tmpddm_weaponindex", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The player model to use" )

    local instructions = [[
    speedrun of instructions:
    Shift to sprint, reel in rope, and wallrun.
    Spacebar to jump off of a wall and double jump.
    Wallrunning is pretty automatic. Hold left/right if it gives you trouble.
    Look up or down to control your vertical direction while wall running. Forward increases your speed.
    Double jump resets whenever you stand on the ground or begin wall running.
    Rightclick to toggle your rope. The rope CAN break from excessive tension.
    You can also shoot a rope connection point to break it. Ignore the watermelon gibs
    Remember, angular momentum is conserved. Reel in rope to go faster.
    You always exit a swing perpendicular to the rope. Always try to enter perpendicular to keep your speed.

    speedrun of objectives:
    Pick up pizza from the Pickup points, deliver it to the Dropoff points.
    Intercept pizza carriers to stop them from scoring.
    Quote Raimi Spiderman as much as possible.
    ]]

    local contact = "Join our discord. Ask for TomatoSoup. Leave feedback. https://discord.gg/2zA2kxV"

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

        local InstructionPanel = vgui.Create( "DPanel", IntroFrame )
        InstructionPanel:SetPos( 10, 30 )
        InstructionPanel:SetSize( 800, 580)

        local InstructionsLabel = vgui.Create( "DLabel", InstructionPanel )
        InstructionsLabel:SetPos( 5, 5 )
        InstructionsLabel:SetText( instructions )
        InstructionsLabel:SetFont("Trebuchet18")
        InstructionsLabel:SetSize( 700, 285)
        InstructionsLabel:SetDark(true)

        local ContactLabel = vgui.Create( "DLabel", InstructionPanel )
        ContactLabel:SetPos( 5, 295 )
        ContactLabel:SetText( contact )
        ContactLabel:SetFont("Trebuchet18")
        ContactLabel:SetSize( 700, 280)
        ContactLabel:SetDark(true)

        local RopeHoldCheckbox = vgui.Create( "DCheckBoxLabel", InstructionPanel ) -- Create the checkbox
        RopeHoldCheckbox:SetPos( 5, 305+140 ) -- Set the position
        RopeHoldCheckbox:SetText("Hold to Rope?")
        RopeHoldCheckbox:SetValue( LocalPlayer():GetInfoNum("tf_ropehold", 0) == 1 ) -- Initial "ticked" value
        RopeHoldCheckbox:SetDark(true)
        RopeHoldCheckbox.OnChange = function(self, bool)
            RunConsoleCommand("tf_ropehold", bool and 1 or 0)
        end

        local HighContrastCheckbox = vgui.Create( "DCheckBoxLabel", InstructionPanel ) -- Create the checkbox
        HighContrastCheckbox:SetPos( 5, 320+140 ) -- Set the position
        HighContrastCheckbox:SetText("High Contrast Crosshair?")
        HighContrastCheckbox:SetValue( LocalPlayer():GetInfoNum("tf_highcontrastxhair", 0) == 3 ) -- Initial "ticked" value
        HighContrastCheckbox:SetDark(true)
        HighContrastCheckbox.OnChange = function(self, bool)
            RunConsoleCommand("tf_highcontrastxhair", bool and 3 or 0)
        end

        local SelectPanel = vgui.Create( "DPanel", IntroFrame )
        SelectPanel:SetPos( 815, 30 )
        SelectPanel:SetSize( 400, 580)


        local WeaponScroll = vgui.Create( "DScrollPanel", SelectPanel ) -- Create the Scroll panel
        WeaponScroll:SetPos( 5, 5 )
        WeaponScroll:SetSize( 390, 74 )

        local WeaponList = vgui.Create( "DIconLayout", WeaponScroll )
        WeaponList:Dock( FILL )
        WeaponList:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
        WeaponList:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

        local WeaponDescLabel = vgui.Create( "DLabel", SelectPanel)
        WeaponDescLabel:SetPos(5, 79)
        WeaponDescLabel:SetSize(390, 20)
        WeaponDescLabel:SetFont("Trebuchet18")
        WeaponDescLabel:SetText("Hover a weapon for a quick description")
        WeaponDescLabel:SetDark(true)

        for i,v in ipairs(WEAPON_LIST) do
            local icon = WeaponList:Add("SpawnIcon")
            icon:SetModel( v[1] )
            icon:SetSize( 64, 64 )
            icon:SetTooltip( v[3] )
            icon.OnCursorEntered = function()
                WeaponDescLabel:SetText(v[4])
                surface.PlaySound( "garrysmod/ui_hover.wav" )
            end
            icon.DoClick = function( self )
                RunConsoleCommand( "tmpddm_weaponindex", tostring(i) )
            end
        end

        local RopeScroll = vgui.Create( "DScrollPanel", SelectPanel ) -- Create the Scroll panel
        RopeScroll:SetPos( 5, 99 )
        RopeScroll:SetSize( 390, 74 ) --TODO

        local RopeList = vgui.Create( "DIconLayout", RopeScroll )
        RopeList:Dock( FILL )
        RopeList:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
        RopeList:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

        for i,v in ipairs(ROPE_LIST) do
            local icon = RopeList:Add("DImageButton")
            icon:SetMaterial( v[2] )
            icon:SetSize( 48, 64 )
            icon:SetTooltip( v[1] )
            icon.OnCursorEntered = function()
                surface.PlaySound( "garrysmod/ui_hover.wav" )
            end
            icon.DoClick = function( self )
                RunConsoleCommand( "tmpddm_ropeindex", tostring(i) )
            end
        end


        local ModelScroll = vgui.Create( "DScrollPanel", SelectPanel ) -- Create the Scroll panel
        ModelScroll:SetPos( 5, 183 )
        ModelScroll:SetSize( 390, 387 ) --TODO

        local ModelList = vgui.Create( "DIconLayout", ModelScroll )
        ModelList:Dock( FILL )
        ModelList:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
        ModelList:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

        for k,v in pairs(player_manager.AllValidModels()) do
            local icon = ModelList:Add("SpawnIcon")
            icon:SetModel( v )
            icon:SetSize( 64, 64 )
            icon:SetTooltip( k )
            icon.OnCursorEntered = function()
                surface.PlaySound( "garrysmod/ui_hover.wav" )
            end
            icon.DoClick = function( self )
                RunConsoleCommand( "tmpddm_playermodel", tostring(k) )
            end
        end


        local DoneButton = vgui.Create( "DButton", IntroFrame )
        DoneButton:SetText( "LET ME DELIVER PIZZA" )
        DoneButton:SetPos( 490, 590 )
        DoneButton:SetSize( 230, 30 )
        DoneButton.DoClick = function()
            IntroFrame:Close()
        end

    end
end