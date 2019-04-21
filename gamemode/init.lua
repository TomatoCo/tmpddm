resource.AddFile("materials/pickup.png")
resource.AddFile("materials/dropoff.png")
resource.AddFile("materials/pizza.png")
resource.AddFile("sound/pizzatime.mp3")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function GM:InitPostEntity()
    print("init post entity")
    self:SpawnPizza()
end

local PizzaPositions = {
    Vector(12817.874023438, -12499.059570313, -10867.107421875),
    Vector(11555.044921875, -12870.357421875, -10495.96875),
    Vector(10804.35546875, -11820.840820313, -10388.458984375),
    Vector(12671.4765625, -11585.50390625, -10832.34375),
    Vector(12600.836914063, -10099.290039063, -10751.96875),
    Vector(10020.83984375, -10054.436523438, -10367.96875),
    Vector(10159.97265625, -8973.609375, -10751.96875),
    Vector(12205.857421875, -8088.1372070313, -10770.986328125),
    Vector(12290.759765625, -6285.9267578125, -10531.44921875),
    Vector(12626.127929688, -4993.337890625, -10239.96875),
    Vector(9967.224609375, -4949.8388671875, -10719.232421875),
    Vector(10137.783203125, -2855.6604003906, -10369.276367188),
    Vector(12340.05859375, -3975.3005371094, -10751.96875),
    Vector(12196.913085938, -3146.9501953125, -11135.96875),
    Vector(12222.137695313, -911.78161621094, -10567.85546875),
    Vector(10389.971679688, -1015.1999511719, -10239.96875),
    Vector(12941.196289063, 977.67687988281, -10760.23828125),
    Vector(11054.705078125, 1469.4803466797, -10640.537109375),
    Vector(9243.5791015625, 1858.7528076172, -10760.3125),
    Vector(13223.205078125, 4937.7978515625, -10678.93359375),
    Vector(11117.633789063, 5975.494140625, -10781.6953125),
    Vector(9171.94921875, 10070.904296875, -10895.96875),
    Vector(9218.431640625, 10323.9453125, -11007.96875),
    Vector(1969.5618896484, 7648.0512695313, -9727.96875),
    Vector(1370.4016113281, 7834.4438476563, -9215.96875),
    Vector(544.36920166016, 8373.2001953125, -9087.96875),
    Vector(-730.86761474609, 7432.3110351563, -9231.96875),
    Vector(656.54724121094, 7523.8251953125, -11135.96875),
    Vector(-2776.4951171875, 7447.0053710938, -9855.96875),
    Vector(-968.03948974609, 5479.5844726563, -9087.96875),
    Vector(-1450.8131103516, 4800.1577148438, -11135.96875),
    Vector(395.52752685547, 4960.873046875, -10111.96875),
    Vector(-3453.7592773438, 4828.3701171875, -10111.96875),
    Vector(-5452.0126953125, 7350.6831054688, -9599.96875),
    Vector(-5775.2905273438, 5074.3051757813, -9471.96875),
    Vector(-6992.9365234375, 4361.3994140625, -9215.96875),
    Vector(-6780.076171875, 6974.2583007813, -8831.96875),
    Vector(-8201.591796875, 7816.26953125, -8831.96875),
    Vector(-7473.4375, 7489.1323242188, -10879.96875),
    Vector(-7216.8603515625, 9219.1923828125, -8831.96875),
    Vector(-9958.916015625, 7517.5263671875, -8575.96875),
    Vector(-11717.984375, 7776.2338867188, -9343.96875),
    Vector(-12544.075195313, 6089.0092773438, -10239.96875),
    Vector(-10829.3671875, 5846.345703125, -9087.96875),
    Vector(-9877.6044921875, 5282.3984375, -11135.96875),
    Vector(-12292.974609375, 4800.310546875, -9727.96875),
    Vector(-12432.118164063, 2931.8134765625, -9983.96875),
    Vector(-11593.047851563, 802.26940917969, -9727.96875),
    Vector(-10712.178710938, 3261.5126953125, -10639.96875),
    Vector(-8291.4638671875, 3738.802734375, -10639.96875),
    Vector(-8700.3671875, 5157.62890625, -10383.96875),
    Vector(-7062.2099609375, 2113.3161621094, -9967.96875),
    Vector(-7605.24609375, 1333.9044189453, -10623.96875),
    Vector(-6216.017578125, 3870.8413085938, -9983.96875),
    Vector(-4643.3251953125, 2067.9052734375, -9215.96875),
    Vector(-4831.2783203125, -844.70642089844, -9087.96875),
    Vector(-6820.6513671875, 1321.5991210938, -8959.96875),
    Vector(-7132.8564453125, -1639.8564453125, -9919.96875),
    Vector(-9156.7861328125, -1564.4693603516, -10239.96875),
    Vector(-10068.90625, -1773.1713867188, -9727.96875),
    Vector(-12123.241210938, -2020.0124511719, -9087.96875),
    Vector(-12331.987304688, -3800.2119140625, -8575.96875),
    Vector(-10127.948242188, -3256.8559570313, -7295.96875),
    Vector(-12286.71875, -5377.61328125, -7039.96875),
    Vector(-9946.9453125, -4941.4877929688, -9855.96875),
    Vector(-8995.623046875, -5470.5180664063, -8975.96875),
    Vector(-8621.365234375, -5024.919921875, -9999.96875),
    Vector(-9881.5556640625, -7285.5639648438, -9644.7431640625),
    Vector(-12128.016601563, -8001.2275390625, -8703.96875),
    Vector(-9071.078125, -9254.912109375, -9727.96875),
    Vector(-12264.609375, -9544.03515625, -7935.96875),
    Vector(-11607.672851563, -11049.643554688, -8575.96875),
    Vector(-11175.775390625, -12498.3046875, -8575.96875),
    Vector(-12901.311523438, -12605.259765625, -8463.96875),
    Vector(-9285.333984375, -12453.272460938, -7679.96875),
    Vector(-7431.0541992188, -12466.60546875, -8559.96875),
    Vector(-6383.3071289063, -11611.938476563, -9087.96875),
    Vector(-6259.6782226563, -12862.1796875, -8175.96875),
    Vector(-7742.4389648438, -11440.16015625, -9215.96875),
    Vector(-5104.0419921875, -11951.08984375, -7551.96875),
    Vector(-7485.0200195313, -10062.459960938, -8831.96875),
    Vector(-5498.9892578125, -7697.8901367188, -9984.369140625),
    Vector(-5987.201171875, -6836.0078125, -9600.369140625),
    Vector(-4842.03125, -6940.01171875, -10368.369140625),
    Vector(-3237.6125488281, -6592.0771484375, -8703.96875),
    Vector(-2945.6171875, -5957.2001953125, -9248.03125),
    Vector(-3134.0256347656, -8455.64453125, -9471.96875),
    Vector(-1335.5812988281, -9238.6484375, -9983.96875),
    Vector(-3176.3154296875, -9927.6708984375, -8959.96875),
    Vector(-4079.6362304688, -9971.2890625, -9792.03125),
    Vector(-3152.7763671875, -12103.838867188, -4927.96875),
    Vector(-1031.9561767578, -11548.1640625, -6271.96875),
    Vector(-1961.7719726563, -11389.740234375, -6639.96875),
    Vector(-1057.5775146484, -10241.888671875, -7935.96875),
    Vector(-1273.2965087891, -12630.737304688, -11135.96875),
    Vector(267.66381835938, -12355.4765625, -6639.96875),
    Vector(1917.8283691406, -10820.18359375, -7887.96875),
    Vector(1267.4291992188, -7405.140625, -8959.96875),
    Vector(2149.625, -6762.5288085938, -9343.96875),
    Vector(4444.4125976563, -9872.55859375, -8831.96875),
    Vector(3915.1293945313, -11528.240234375, -9439.96875),
    Vector(4027.4118652344, -12405.166015625, -9183.96875),
    Vector(5617.0209960938, -12598.4375, -8191.96875),
    Vector(6405.8383789063, -10028.166015625, -10623.96875),
    Vector(4723.7944335938, -7470.51171875, -5631.96875),
    Vector(4934.0927734375, -4636.9790039063, -7551.96875),
    Vector(4839.244140625, -2697.4587402344, -9231.96875),
    Vector(5268.2587890625, -1559.9226074219, -8447.96875),
    Vector(4167.65625, -1658.6857910156, -8831.96875),
    Vector(4721.0537109375, -98.024658203125, -8639.96875),
    Vector(4747.8247070313, 1669.6673583984, -9343.96875),
    Vector(2329.6267089844, 155.22979736328, -10095.96875),
    Vector(2510.0083007813, 3077.66796875, -8831.96875),
    Vector(2554.349609375, 1626.0483398438, -8831.96875),
    Vector(1040.5091552734, 2119.0686035156, -10367.96875),
    Vector(360.08685302734, 2232.7670898438, -9343.96875),
    Vector(-842.75830078125, 2472.0080566406, -9343.96875),
    Vector(-2864.1352539063, 1990.7686767578, -9983.96875),
    Vector(-3709.3137207031, 638.91052246094, -10239.96875),
    Vector(-3621.7314453125, -1144.2087402344, -9599.96875),
    Vector(-2340.3010253906, -2023.2436523438, -9087.96875),
    Vector(-3731.8161621094, -3047.4067382813, -9855.96875),
    Vector(-5384.681640625, -3009.8510742188, -9983.96875),
    Vector(-6896.3515625, -4805.8388671875, -8575.96875),
    Vector(-6823.060546875, -3902.7136230469, -8943.96875),
    Vector(-3187.0231933594, -4563.556640625, -8191.96875),
    Vector(-2301.3408203125, -4675.0971679688, -8575.96875),
    Vector(485.72647094727, -4749.8359375, -8319.96875),
    Vector(2104.1489257813, -4426.7661132813, -8831.96875),
    Vector(2313.150390625, -3008.6315917969, -10111.96875),
    Vector(1987.2602539063, -1585.8479003906, -10368.369140625),
    Vector(1882.6732177734, -434.83203125, -10095.96875),
    Vector(778.79498291016, -9.6077880859375, -10367.96875),
    Vector(-732.11901855469, -4782.8588867188, -9727.96875),
    Vector(-2241.1625976563, -3169.255859375, -10240.369140625),
    Vector(-1274.0454101563, 2664.2592773438, -10495.96875),
    Vector(-191.71980285645, 1641.5225830078, -11135.96875)
}

function GM:SpawnPizza(suppressDropoff)

    local firstPos = PizzaPositions[math.random(#PizzaPositions)]
    print("Spawning pickup " .. tostring(firstPos))

    local structure = ents.Create("tmpddm_pickup")
    structure:SetPos(firstPos)
    structure:Spawn()

    if not suppressDropoff then

        local candidates = {}

        for i=1,5 do
            candidates[i] = PizzaPositions[math.random(#PizzaPositions)]
        end

        table.sort(candidates, function(a,b) return a:DistToSqr(firstPos) < b:DistToSqr(firstPos) end)

        local secondPos = candidates[3]
        print("Spawning dropoff " .. tostring(secondPos))

        structure = ents.Create("tmpddm_dropoff")
        structure:SetPos(secondPos)
        structure:Spawn()

    end

end

function GM:PlayerLoadout(ply)

    local desiredWeapon = tonumber(ply:GetInfo("tmpddm_weaponindex")) or 1
    local weapon = WEAPON_LIST[desiredWeapon] or WEAPON_LIST[1]
    ply:Give(weapon[2])
    
    ply:SetInvulnTimer(CurTime() + 10)

    ply:Flashlight(true)
    ply:AllowFlashlight(true)
   
    return true
end

function GM:PlayerSetModel(ply)
    local models = player_manager.AllValidModels()
    local desiredModel = tostring(ply:GetInfo("tmpddm_playermodel")) or ""

    --TODO Improve logic to lock out some models
    local actualModel = models[desiredModel] or models["kleiner"]
    ply:SetModel(actualModel)
end

function GM:PlayerInitialSpawn(ply)
    ply:SendLua("TMPDDM_MOTD()")
end
function GM:ShowSpare1(ply)
    ply:SendLua("TMPDDM_MOTD()")
end

hook.Add("PlayerSay", "MOTDSAY", function(ply, text)
    if text == "!motd" then
        ply:SendLua("TMPDDM_MOTD()")
    end
end)

function GM:PlayerSpawn( ply )
    -- Your code
    ply:SetupHands() -- Create the hands and call GM:PlayerSetHandsModel

    ply:SetObserverMode(OBS_MODE_NONE) 
    ply:UnSpectate()

    local ropeIndex = tonumber(ply:GetInfo("tmpddm_ropeindex")) or 1
    ply:SetRopeIndex(ropeIndex)

    hook.Call( "PlayerLoadout", GAMEMODE, ply )
    hook.Call( "PlayerSetModel", GAMEMODE, ply )
end

local function dropPizza(ply)
    print("Spawning dead drop")
    if IsValid(ply) then
        if IsValid(ent.smoketrail) then
            ent.smoketrail:Remove()
        end

        ply:SetHasPizza(false)

        local structure = ents.Create("tmpddm_pickup")
        structure:SetPos(ply:GetPos())
        structure:Spawn()
        structure:StartDrop()
    end
end

function GM:PlayerDeath(ply, wep, attacker)
    if ply:GetHasPizza() then
        dropPizza(ply)
    end
    return true
end

function GM:PlayerDisconnected( ply ) 
    if ply:GetHasPizza() then
        dropPizza(ply)
    end
end


-- Choose the model for hands according to their player model.
function GM:PlayerSetHandsModel( ply, ent )

    local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
    local info = player_manager.TranslatePlayerHands( simplemodel )
    if ( info ) then
        ent:SetModel( info.model )
        ent:SetSkin( info.skin )
        ent:SetBodyGroups( info.body )
    end

end