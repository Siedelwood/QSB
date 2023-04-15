-- -------------------------------------------------------------------------- --

---
-- Ein Behavior für das Addon
-- @set sort=true
-- @local
--

-- -------------------------------------------------------------------------- --
-- REWARDS

---
-- Nutzloses Behavior
--
-- @param _PlayerID   ID des Spielers
-- @param _Lock       Sperren/Entsperren
-- @param _Technology Name des Rechts
--
-- @within Reprisal
--
function Reprisal_Useless(...)
    return B_Reprisal_Useless:new(...);
end

B_Reprisal_Useless = {
    Name = "Reprisal_Useless",
    Description = {
        en = "Reprisal: Does nothing usefull",
        de = "Vergeltung: Macht nichts sinnvolles",
        fr = "Rétribution: Ne fait rien d'utile",
    },
    Parameter = {
        { ParameterType.PlayerID, en = "PlayerID", de = "SpielerID", fr = "PlayerID", },
        { ParameterType.Custom,   en = "Param1",   de = "Param1",    fr = "Param1", },
        { ParameterType.Custom,   en = "Param2",   de = "Param2",    fr = "Param2" },
    },
}

function B_Reprisal_Useless:GetReprisalTable()
    return { Reprisal.Custom, {self, self.CustomFunction} }
end

function B_Reprisal_Useless:AddParameter(_Index, _Parameter)
    if (_Index ==0) then
        -- Holt sich den Wert des ersten Editor Parameters
        self.PlayerID = _Parameter * 1
    elseif (_Index == 1) then
        -- Holt sich den Wert des zweiten Editor Parameters
        self.IsEins = _Parameter == "Eins"
    elseif (_Index == 2) then
        -- Holt sich den Wert des dritten Editor Parameters
        self.MyString = _Parameter
    end
end

function B_Reprisal_Useless:CustomFunction(_Quest)
    -- Aufruf der Logik, die von diesem Behavior ausgelöst werden soll
end

function B_Reprisal_Useless:GetCustomData(_Index)
    local Data = {}
    if (_Index == 1) then
        -- füllt die Vorschlagswertdaten im Editor für den ersten Parameter
        Data[1] = "Eins"
        Data[2] = "Zwei"
    elseif (_Index == 2) then
        -- füllt die Vorschlagswertdaten im Editor für den zweiten Parameter
    end
    return Data
end

function B_Reprisal_Useless:Debug(_Quest)
    -- Wirf einen error() und setzte return true falls es ein Problem gibt
    return false
end

Swift:RegisterBehavior(B_Reprisal_Useless)