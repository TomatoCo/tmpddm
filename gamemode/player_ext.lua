local meta = FindMetaTable( "Player" )

hook.Add("OnEntityCreated", "SetupPlayerDataTables", function(ent)
    if ent:IsPlayer() then
        ent:InstallDataTable()
        ent:SetupDataTables()
    end
end)

function meta:SetupDataTables()
    
    self:NetworkVar( "Bool", 0, "HasPizza")
    self:NetworkVar( "Int", 0, "Score")
    self:NetworkVar( "Float", 0, "InvulnTimer")

    self:NetworkVar( "Int", 1, "RopeIndex") --TODO is this necessary?

    
    if SERVER then
        self:SetHasPizza(false)
        self:SetScore(0)
        self:SetInvulnTimer(0)
        self:SetRopeIndex(0)
    end
end