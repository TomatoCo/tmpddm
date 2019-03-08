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

    
    if SERVER then
        self:SetHasPizza(false)
        self:SetScore(0)
    end
end