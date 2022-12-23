--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Eine Sammlung von nützlichen Hilfsfunktionen.
-- @set sort=true
-- @local
--

Revision.Utils = {}

QSB.RefillAmounts = {};
QSB.CustomVariable = {};

function Revision.Utils:Initalize()
    QSB.ScriptEvents.CustomValueChanged = Revision.Event:CreateScriptEvent("Event_CustomValueChanged");
    if Revision.Environment == QSB.Environment.GLOBAL then
        self:OverwriteGeologistRefill();
    end
end

function Revision.Utils:OnSaveGameLoaded()
end

function Revision.Utils:OverwriteGeologistRefill()
    if Framework.GetGameExtraNo() >= 1 then
        GameCallback_OnGeologistRefill_Orig_QSB_Kernel = GameCallback_OnGeologistRefill;
        GameCallback_OnGeologistRefill = function(_PlayerID, _TargetID, _GeologistID)
            GameCallback_OnGeologistRefill_Orig_QSB_Kernel(_PlayerID, _TargetID, _GeologistID);
            if QSB.RefillAmounts[_TargetID] then
                local RefillAmount = QSB.RefillAmounts[_TargetID];
                local RefillRandom = RefillAmount + math.random(1, math.floor((RefillAmount * 0.2) + 0.5));
                Logic.SetResourceDoodadGoodAmount(_TargetID, RefillRandom);
                if RefillRandom > 0 then
                    if Logic.GetResourceDoodadGoodType(_TargetID) == Goods.G_Iron then
                        Logic.SetModel(_TargetID, Models.Doodads_D_SE_ResourceIron);
                    else
                        Logic.SetModel(_TargetID, Models.R_ResorceStone_Scaffold);
                    end
                end
            end
        end
    end
end

function Revision.Utils:TriggerEntityKilledCallbacks(_Entity, _Attacker)
    local DefenderID = GetID(_Entity);
    local AttackerID = GetID(_Attacker or 0);
    if AttackerID == 0 or DefenderID == 0 or Logic.GetEntityHealth(DefenderID) > 0 then
        return;
    end
    local x, y, z     = Logic.EntityGetPos(DefenderID);
    local DefPlayerID = Logic.EntityGetPlayer(DefenderID);
    local DefType     = Logic.GetEntityType(DefenderID);
    local AttPlayerID = Logic.EntityGetPlayer(AttackerID);
    local AttType     = Logic.GetEntityType(AttackerID);

    GameCallback_EntityKilled(DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType);
    Logic.ExecuteInLuaLocalState(string.format(
        "GameCallback_Feedback_EntityKilled(%d, %d, %d, %d,%d, %d, %f, %f)",
        DefenderID, DefPlayerID, AttackerID, AttPlayerID, DefType, AttType, x, y
    ));
end

function Revision.Utils:GetCustomVariable(_Name)
    return QSB.CustomVariable[_Name];
end

function Revision.Utils:SetCustomVariable(_Name, _Value)
    Revision.Utils:UpdateCustomVariable(_Name, _Value);
    local Value = tostring(_Value);
    if type(_Value) ~= "number" then
        Value = [["]] ..Value.. [["]];
    end
    if GUI then
        Revision.Event:DispatchScriptCommand(QSB.ScriptCommands.UpdateCustomVariable, 0, _Name, Value);
    else
        Logic.ExecuteInLuaLocalState(string.format(
            [[Revision.Utils:UpdateCustomVariable("%s", %s)]],
            _Name,
            Value
        ));
    end
end

function Revision.Utils:UpdateCustomVariable(_Name, _Value)
    if QSB.CustomVariable[_Name] then
        local Old = QSB.CustomVariable[_Name];
        QSB.CustomVariable[_Name] = _Value;
        Revision.Event:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            Old,
            _Value
        );
    else
        QSB.CustomVariable[_Name] = _Value;
        Revision.Event:DispatchScriptEvent(
            QSB.ScriptEvents.CustomValueChanged,
            _Name,
            nil,
            _Value
        );
    end
end

---
-- Speichert den Wert der Custom Variable im globalen und lokalen Skript.
--
-- Des weiteren wird in beiden Umgebungen ein Event ausgelöst, wenn der Wert
-- gesetzt wird. Das Event bekommt den Namen der Variable, den alten Wert und
-- den neuen Wert übergeben.
--
-- @param[type=boolean] _Name  Name der Custom Variable
-- @param               _Value Neuer Wert
-- @within System
-- @local
--
-- @usage
-- local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.SaveCustomVariable(_Name, _Value)
    Revision.Utils:SetCustomVariable(_Name, _Value);
end

---
-- Gibt den aktuellen Wert der Custom Variable zurück oder den Default-Wert.
-- @param[type=boolean] _Name    Name der Custom Variable
-- @param               _Default (Optional) Defaultwert falls leer
-- @return Wert
-- @within System
-- @local
--
-- @usage
-- local Value = API.ObtainCustomVariable("MyVariable", 0);
--
function API.ObtainCustomVariable(_Name, _Default)
    local Value = QSB.CustomVariable[_Name];
    if not Value and _Default then
        Value = _Default;
    end
    return Value;
end

-- -------------------------------------------------------------------------- --
-- Entity

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- Für Siedler wird automatisch die Tasklist TL_NPC_IDLE gesetzt, damit
-- sie nicht versteinert in der Landschaft rumstehen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Entity
-- @usage
-- API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local ID1 = GetID(_Entity);
    if ID1 == 0 then
        return;
    end
    local pos = GetPosition(ID1);
    local player = _NewOwner or Logic.EntityGetPlayer(ID1);
    local orientation = Logic.GetEntityOrientation(ID1);
    local name = Logic.GetEntityName(ID1);
    DestroyEntity(ID1);
    local ID2 = Logic.CreateEntity(_Type, pos.X, pos.Y, orientation, player);
    Logic.SetEntityName(ID2, name);
    if Logic.IsSettler(ID2) == 1 then
        Logic.SetTaskList(ID2, TaskLists.TL_NPC_IDLE);
    end
    return ID2;
end
ReplaceEntity = API.ReplaceEntity;

---
-- Setzt das Entity oder das Battalion verwundbar oder unverwundbar.
--
-- @param               _Entity Entity (Scriptname oder ID)
-- @param[type=boolean] _Flag Verwundbar
-- @within Entity
-- @local
--
function API.SetEntityVulnerableFlag(_Entity, _Flag)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    local VulnerabilityFlag = (_Flag and 1) or 0;
    if EntityID > 0 then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if SoldierTable[1] and SoldierTable[1] > 0 then
            for i= 2, SoldierTable[1]+1 do
                Logic.SetEntityInvulnerabilityFlag(SoldierTable[i], VulnerabilityFlag);
            end
        end
        Logic.SetEntityInvulnerabilityFlag(EntityID, VulnerabilityFlag);
    end
end

MakeVulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, false);
end
MakeInvulnerable = function(_Entity)
    API.SetEntityVulnerableFlag(_Entity, true);
end

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- @param _Position                        Position (Skriptname oder Entity-ID)
-- @param[type=number] _PlayerID           Zielspieler
-- @param[type=number] _GoodType           Warentyp
-- @param[type=number] _Amount             Warenmenge
-- @param[type=number] _CartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _IgnoreReservation (optional) Marktplatzreservation ignorieren
-- @param[type=boolean] _Overtake          (optional) Mit Position austauschen
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within System
-- @usage
-- -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
--
function API.SendCart(_Position, _PlayerID, _GoodType, _Amount, _CartOverlay, _IgnoreReservation, _Overtake)
    local OriginalID = GetID(_Position);
    if not IsExisting(OriginalID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(OriginalID);
    local ResourceCategory = Logic.GetGoodCategoryForGoodType(_GoodType);
    local Orientation = Logic.GetEntityOrientation(OriginalID);
    local ScriptName = Logic.GetEntityName(OriginalID);
    if Logic.IsBuilding(OriginalID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(OriginalID);
        Orientation = Logic.GetEntityOrientation(OriginalID)-90;
    end

    -- Macht Waren lagerbar im Lagerhaus
    if ResourceCategory == GoodCategories.GC_Resource or _GoodType == Goods.G_None then
        local TypeName = Logic.GetGoodTypeName(_GoodType);
        local SHID = Logic.GetStoreHouse(_PlayerID);
        local HQID = Logic.GetHeadquarters(_PlayerID);
        if SHID ~= 0 and Logic.GetIndexOnInStockByGoodType(SHID, _GoodType) == -1 then
            if _GoodType ~= Goods.G_Gold or (_GoodType == Goods.G_Gold and HQID == 0) then
                info(
                    "API.SendCart: creating stock for " ..TypeName.. " in" ..
                    "storehouse of player " .._PlayerID.. "."
                );
                Logic.AddGoodToStock(SHID, _GoodType, 0, true, true);
            end
        end
    end

    info("API.SendCart: Creating cart ("..
        tostring(_Position) ..","..
        tostring(_PlayerID) ..","..
        Logic.GetGoodTypeName(_GoodType) ..","..
        tostring(_Amount) ..","..
        tostring(_CartOverlay) ..","..
        tostring(_IgnoreReservation) ..
    ")");

    if ResourceCategory == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y, Orientation, _PlayerID);
    elseif _GoodType == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y, Orientation,_PlayerID);
    elseif _GoodType == Goods.G_Gold or _GoodType == Goods.G_None or _GoodType == Goods.G_Information then
        if _CartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_CartOverlay, x, y, Orientation, _PlayerID);
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y, Orientation, _PlayerID);
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y, Orientation, _PlayerID);
    end
    info("API.SendCart: Executing hire merchant...");
    Logic.HireMerchant(ID, _PlayerID, _GoodType, _Amount, _PlayerID, _IgnoreReservation);
    if _Overtake and Logic.IsBuilding(OriginalID) == 0 then
        info("API.SendCart: Cart replaced original.");
        Logic.SetEntityName(ID, ScriptName);
        DestroyEntity(OriginalID);
    end
    info("API.SendCart: Cart has been send successfully.");
    return ID
end

---
-- Gibt die relative Gesundheit des Entity zurück.
--
-- <b>Hinweis</b>: Der Wert wird als Prozentwert zurückgegeben. Das bedeutet,
-- der Wert liegt zwischen 0 und 100.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Aktuelle Gesundheit
-- @within Entity
--
function API.GetEntityHealth(_Entity)
    local EntityID = GetID(_Entity);
    if IsExisting(EntityID) then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        local Health    = Logic.GetEntityHealth(EntityID);
        return (Health/MaxHealth) * 100;
    end
    error("API.GetEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return 0;
end

---
-- Setzt die Gesundheit des Entity. Optional kann die Gesundheit relativ zur
-- maximalen Gesundheit geändert werden.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Health   Neue aktuelle Gesundheit
-- @param[type=boolean] _Relative (Optional) Relativ zur maximalen Gesundheit
-- @within Entity
--
function API.ChangeEntityHealth(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
            for i= 2, SoldierTable[1]+1 do
                API.ChangeEntityHealth(SoldierTable[i], _Health, _Relative);
            end
        else
            local OldHealth = Logic.GetEntityHealth(EntityID);
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            if NewHealth > OldHealth then
                Logic.HealEntity(EntityID, NewHealth - OldHealth);
            elseif NewHealth < OldHealth then
                Logic.HurtEntity(EntityID, OldHealth - NewHealth);
            end
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end

---
-- Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
-- in einer Mine.
--
-- @param              _Entity       Rohstoffvorkommen (Skriptname oder ID)
-- @param[type=number] _StartAmount  Menge an Rohstoffen
-- @param[type=number] _RefillAmount Minimale Nachfüllmenge (> 0)
-- @within Entity
--
-- @usage
-- API.SetResourceAmount("mine1", 250, 150);
--
function API.SetResourceAmount(_Entity, _StartAmount, _RefillAmount)
    if GUI or not IsExisting(_Entity) then
        return;
    end
    assert(type(_StartAmount) == "number");
    assert(type(_RefillAmount) == "number");

    local EntityID = GetID(_Entity);
    if not IsExisting(EntityID) or Logic.GetResourceDoodadGoodType(EntityID) == 0 then
        return;
    end
    if Logic.GetResourceDoodadGoodAmount(EntityID) == 0 then
        EntityID = API.ReplaceEntity(EntityID, Logic.GetEntityType(EntityID));
    end
    Logic.SetResourceDoodadGoodAmount(EntityID, _StartAmount);
    if _RefillAmount then
        QSB.RefillAmounts[EntityID] = _RefillAmount;
    end
end

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within System
--
function API.CreateEntityName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "AutomaticScriptName_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end

-- Mögliche (zufällige) Siedler, getrennt in männlich und weiblich.
QSB.PossibleSettlerTypes = {
    Male = {
        Entities.U_BannerMaker,
        Entities.U_Baker,
        Entities.U_Barkeeper,
        Entities.U_Blacksmith,
        Entities.U_Butcher,
        Entities.U_BowArmourer,
        Entities.U_BowMaker,
        Entities.U_CandleMaker,
        Entities.U_Carpenter,
        Entities.U_DairyWorker,
        Entities.U_Pharmacist,
        Entities.U_Tanner,
        Entities.U_SmokeHouseWorker,
        Entities.U_Soapmaker,
        Entities.U_SwordSmith,
        Entities.U_Weaver,
    },
    Female = {
        Entities.U_BathWorker,
        Entities.U_SpouseS01,
        Entities.U_SpouseS02,
        Entities.U_SpouseS03,
        Entities.U_SpouseF01,
        Entities.U_SpouseF02,
        Entities.U_SpouseF03,
    }
}

---
-- Wählt aus einer festen Liste von Typen einen zufälligen Siedler-Typ aus.
-- Es werden nur Stadtsiedler zurückgegeben. Sie können männlich oder
-- weiblich sein.
--
-- @return[type=number] Zufälliger Typ
-- @within Entity
-- @local
--
function API.GetRandomSettlerType()
    local Gender = (math.random(1, 2) == 1 and "Male") or "Female";
    local Type   = math.random(1, #QSB.PossibleSettlerTypes[Gender]);
    return QSB.PossibleSettlerTypes[Gender][Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen männlichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Entity
-- @local
--
function API.GetRandomMaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Male);
    return QSB.PossibleSettlerTypes.Male[Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen weiblichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Entity
-- @local
--
function API.GetRandomFemaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Female);
    return QSB.PossibleSettlerTypes.Female[Type];
end

---
-- Gibt das Entity aus der Liste zurück, welches dem Ziel am nähsten ist.
--
-- @param             _Target Entity oder Position
-- @param[type=table] _List   Liste von Entities oder Positionen
-- @return Nähste Entity oder Position
-- @within Position
-- @usage
-- local Clostest = API.GetClosestToTarget("HQ1", {"Marcus", "Alandra", "Hakim"});
--
function API.GetClosestToTarget(_Target, _List)
    local ClosestToTarget = 0;
    local ClosestToTargetDistance = Logic.WorldGetSize();
    for i= 1, #_List, 1 do
        local DistanceBetween = API.GetDistance(_List[i], _Target);
        if DistanceBetween < ClosestToTargetDistance then
            ClosestToTargetDistance = DistanceBetween;
            ClosestToTarget = _List[i];
        end
    end
    return ClosestToTarget;
end

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Position
-- @usage
-- local Position = API.GetPosition("Hans");
--
function API.GetPosition(_Entity)
    if _Entity == nil then
        return {X= 0, Y= 0, Z= 0};
    end
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        warn("API.GetPosition: Entity (" ..tostring(_Entity).. ") does not exist!");
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= x, Y= y, Z= y};
end
API.LocateEntity = API.GetPosition;
GetPosition = API.GetPosition;

---
-- Setzt ein Entity auf eine neue Position
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param _Target Ziel (Skriptname, ID oder Position)
-- @within Position
-- @usage
-- API.SetPosition("Hans", "Horst");
--
function API.SetPosition(_Entity, _Target)
    local ID = GetID(_Entity);
    if not ID then
        return;
    end

    local Target;
    if type(_Target) ~= "table" then
        local ID2 = GetID(_Target);
        local x,y,z = Logic.EntityGetPos(ID2);
        Target = {X= x, Y= y};
    else
        Target = _Target;
    end

    if Logic.IsLeader(ID) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
        for i= 2, Soldiers[1]+1 do
            Logic.DEBUG_SetSettlerPosition(Soldiers[i], Target.X, Target.Y);
        end
    end
    Logic.DEBUG_SetSettlerPosition(ID, Target.X, Target.Y);
end
API.RelocateEntity = API.SetPosition;
SetPosition = API.SetPosition;

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Position
--
function API.IsValidPosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()};
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X < world[1] and _pos.X > 0 and _pos.Y < world[2] and _pos.Y > 0 then
                return true;
            end
        end
    end
    return false;
end

-- -------------------------------------------------------------------------- --
-- Math

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Math
-- @usage
-- local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = API.GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = API.GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        warn("API.GetDistance: Distance could not be calculated!");
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param _Target      Ziel (Skriptname, ID oder Position)
-- @param[type=number] _Offset Winkel Offset
-- @within Math
-- @usage
-- API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_Entity, _Target, _Offset)
    _Offset = _Offset or 0;
    local ID1 = GetID(_Entity);
    if ID1 == 0 then
        return;
    end
    local x1,y1,z1 = Logic.EntityGetPos(ID1);
    local ID2;
    local x2, y2, z2;
    if type(_Target) == "table" then
        x2 = _Target.X;
        y2 = _Target.Y;
        z2 = _Target.Z;
    else
        ID2 = GetID(_Target);
        if ID2 == 0 then
            return;
        end
        x2,y2,z2 = Logic.EntityGetPos(ID2);
    end

    if not API.IsValidPosition({X= x1, Y= y1, Z= z1}) then
        return;
    end
    if not API.IsValidPosition({X= x2, Y= y2, Z= z2}) then
        return;
    end
    Angle = math.deg(math.atan2((y2 - y1), (x2 - x1))) + _Offset;
    if Angle < 0 then
        Angle = Angle + 360;
    end

    if Logic.IsLeader(ID1) == 1 then
        local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID1)};
        for i= 2, Soldiers[1]+1 do
            Logic.SetOrientation(Soldiers[i], Angle);
        end
    end
    Logic.SetOrientation(ID1, Angle);
end
LookAt = API.LookAt;

---
-- Bestimmt den Winkel zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- @param _Pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _Pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Winkel zwischen den Punkten
-- @within Math
-- @usage
-- local Angle = API.GetAngleBetween("HQ1", Logic.GetKnightID(1))
--
function API.GetAngleBetween(_Pos1, _Pos2)
	local delta_X = 0;
	local delta_Y = 0;
	local alpha   = 0;
	if type (_Pos1) == "string" or type (_Pos1) == "number" then
		_Pos1 = API.GetPosition(GetID(_Pos1));
	end
	if type (_Pos2) == "string" or type (_Pos2) == "number" then
		_Pos2 = API.GetPosition(GetID(_Pos2));
	end
	delta_X = _Pos1.X - _Pos2.X;
	delta_Y = _Pos1.Y - _Pos2.Y;
	if delta_X == 0 and delta_Y == 0 then
		return 0;
	end
	alpha = math.deg(math.asin(math.abs(delta_X)/(math.sqrt((delta_X ^ 2)+delta_Y ^ 2))));
	if delta_X >= 0 and delta_Y > 0 then
		alpha = 270 - alpha ;
	elseif delta_X < 0 and delta_Y > 0 then
		alpha = 270 + alpha;
	elseif delta_X < 0 and delta_Y <= 0 then
		alpha = 90  - alpha;
	elseif delta_X >= 0 and delta_Y <= 0 then
		alpha = 90  + alpha;
	end
	return alpha;
end

---
-- Bestimmt die Durchschnittsposition mehrerer Entities.
--
-- @param ... Positionen mit Komma getrennt
-- @return[type=table] Durchschnittsposition aller Positionen
-- @within Math
-- @usage
-- local Center = API.GetGeometricFocus("Hakim", "Marcus", "Alandra");
--
function API.GetGeometricFocus(...)
    local PositionData = {X= 0, Y= 0, Z= 0};
    local ValidEntryCount = 0;
    for i= 1, #arg do
        local Position = API.GetPosition(arg[i]);
        if API.IsValidPosition(Position) then
            PositionData.X = PositionData.X + Position.X;
            PositionData.Y = PositionData.Y + Position.Y;
            PositionData.Z = PositionData.Z + (Position.Z or 0);
            ValidEntryCount = ValidEntryCount +1;
        end
    end
    return {
        X= PositionData.X * (1/ValidEntryCount);
        Y= PositionData.Y * (1/ValidEntryCount);
        Z= PositionData.Z * (1/ValidEntryCount);
    }
end

---
-- Gib eine Position auf einer Linie im relativen Abstand zur ersten Position
-- zurück.
--
-- @param               _Pos1       Erste Position
-- @param               _Pos2       Zweite Position
-- @param[type=number]  _Percentage Entfernung zu Erster Position
-- @return[type=table] Position auf Linie
-- @within Math
-- @usage
-- local Position = API.GetLinePosition("HQ1", "HQ2", 0.75);
--
function API.GetLinePosition(_Pos1, _Pos2, _Percentage)
    if _Percentage > 1 then
        _Percentage = _Percentage / 100;
    end

    if not API.IsValidPosition(_Pos1) and not IsExisting(_Pos1) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos1 = _Pos1;
    if type(Pos1) ~= "table" then
        Pos1 = API.GetPosition(Pos1);
    end

    if not API.IsValidPosition(_Pos2) and not IsExisting(_Pos2) then
        error("API.GetLinePosition: _Pos1 does not exist or is invalid position!");
        return;
    end
    local Pos2 = _Pos2;
    if type(Pos2) ~= "table" then
        Pos2 = API.GetPosition(Pos2);
    end

	local dx = Pos2.X - Pos1.X;
	local dy = Pos2.Y - Pos1.Y;
    return {X= Pos1.X+(dx*_Percentage), Y= Pos1.Y+(dy*_Percentage)};
end

---
-- Gib Positionen im gleichen Abstand auf der Linie zurück.
--
-- @param               _Pos1    Erste Position
-- @param               _Pos2    Zweite Position
-- @param[type=number]  _Periode Anzahl an Positionen
-- @return[type=table] Positionen auf Linie
-- @within Math
-- @usage
-- local PositionList = API.GetLinePositions("HQ1", "HQ2", 6);
--
function API.GetLinePositions(_Pos1, _Pos2, _Periode)
    local PositionList = {};
    for i= 0, 100, (1/_Periode)*100 do
        local Section = API.GetLinePosition(_Pos1, _Pos2, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

---
-- Gibt eine Position auf einer Kreisbahn um einen Punkt zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Angle           Winkel auf dem Kreis
-- @return[type=table] Position auf Kreisbahn
-- @within Math
-- @usage
-- local Position = API.GetCirclePosition("HQ1", 3000, -45);
--
function API.GetCirclePosition(_Target, _Distance, _Angle)
    if not API.IsValidPosition(_Target) and not IsExisting(_Target) then
        error("API.GetCirclePosition: _Target does not exist or is invalid position!");
        return;
    end

    local Position = _Target;
    local Orientation = 0+ (_Angle or 0);
    if type(_Target) ~= "table" then
        local EntityID = GetID(_Target);
        Orientation = Logic.GetEntityOrientation(EntityID)+(_Angle or 0);
        Position = API.GetPosition(EntityID);
    end

    local Result = {
        X= Position.X+_Distance * math.cos(math.rad(Orientation)),
        Y= Position.Y+_Distance * math.sin(math.rad(Orientation)),
        Z= Position.Z
    };
    return Result;
end
API.GetRelatiePos = API.GetCirclePosition;

---
-- Gibt Positionen im gleichen Abstand auf der Kreisbahn zurück.
--
-- @param               _Target          Entity oder Position
-- @param[type=number]  _Distance        Entfernung um das Zentrum
-- @param[type=number]  _Periode         Anzahl an Positionen
-- @param[type=number]  _Offset          Start Offset
-- @return[type=table] Positionend auf Kreisbahn
-- @within Math
-- @usage
-- local PositionList = API.GetCirclePositions("Position", 3000, 6, 45);
--
function API.GetCirclePositions(_Target, _Distance, _Periode, _Offset)
    local Periode = math.floor((360 / _Periode) + 0.5);
    local PositionList = {};
    for i= (Periode + _Offset), (360 + _Offset) do
        local Section = API.GetCirclePosition(_Target, _Distance, i);
        table.insert(PositionList, Section);
    end
    return PositionList;
end

-- -------------------------------------------------------------------------- --
-- Group

---
-- Gibt den Leader des Soldaten zurück.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=number] Menge an Soldaten
-- @within Entity
--
function API.GetGroupLeader(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GetGroupLeader: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 0 then
        return 0;
    end
    return Logic.SoldierGetLeaderEntityID(EntityID);
end

---
-- Heilt das Entity um die angegebene Menge an Gesundheit.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number]  _Amount   Geheilte Gesundheit
-- @within Entity
--
function API.GroupHeal(_Entity, _Amount)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 or Logic.IsLeader(EntityID) == 1 then
        error("API.GroupHeal: _Entity (" ..tostring(_Entity).. ") must be an existing leader!");
        return;
    end
    if type(_Amount) ~= "number" or _Amount < 0 then
        error("API.GroupHeal: _Amount (" ..tostring(_Amount).. ") must greatier than 0!");
        return;
    end
    API.ChangeEntityHealth(EntityID, Logic.GetEntityHealth(EntityID) + _Amount);
end

---
-- Verwundet ein Entity oder ein Battallion um die angegebene
-- Menge an Schaden. Bei einem Battalion wird der Schaden solange
-- auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=number] _Damage   Schaden
-- @param[type=string] _Attacker Angreifer
-- @within Entity
--
function API.GroupHurt(_Entity, _Damage, _Attacker)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.GroupHurt: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if Logic.IsEntityInCategory(EntityID, EntityCategories.Soldier) == 1 then
        API.GroupHurt(API.GetGroupLeader(EntityID), _Damage);
        return;
    end

    local EntityToHurt = EntityID;
    local IsLeader = Logic.IsLeader(EntityToHurt) == 1;
    if IsLeader then
        local SoldierTable = {Logic.GetSoldiersAttachedToLeader(EntityID)};
        if SoldierTable[1] > 0 then
            EntityToHurt = SoldierTable[2];
        end
    end
    if type(_Damage) ~= "number" or _Damage < 0 then
        error("API.GroupHurt: _Damage (" ..tostring(_Damage).. ") must be greater than 0!");
        return;
    end

    if EntityToHurt then
        local Health = Logic.GetEntityHealth(EntityToHurt);
        if Health <= _Damage then
            _Damage = _Damage - Health;
            Logic.HurtEntity(EntityToHurt, Health);
            Revision.Utils:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
            if IsLeader and _Damage > 0 then
                API.GroupHurt(EntityToHurt, _Damage);
            end
        else
            Logic.HurtEntity(EntityToHurt, _Damage);
            Revision.Utils:TriggerEntityKilledCallbacks(EntityToHurt, _Attacker);
        end
    end
end

-- -------------------------------------------------------------------------- --
-- Object

---
-- Aktiviert ein Interaktives Objekt.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @within Entity
--
function API.InteractiveObjectActivate(_ScriptName, _State)
    _State = _State or 0;
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt.
--
-- @param[type=string] _ScriptName Scriptname des Objektes
-- @within Entity
--
function API.InteractiveObjectDeactivate(_ScriptName)
    if GUI or not IsExisting(_ScriptName) then
        return;
    end
    for i= 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

