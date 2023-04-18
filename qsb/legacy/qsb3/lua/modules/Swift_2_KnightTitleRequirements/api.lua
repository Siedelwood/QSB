--[[
Swift_2_KnightTitleRequirements/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Erlaubt es dem Mapper die vorgegebenen Aufstiegsbedingungen idividuell
-- an die eigenen Vorstellungen anzupassen.
--
-- Die Aufstiegsbedingungen werden in der Funktion InitKnightTitleTables
-- angegeben und bearbeitet.
--
-- <b>Achtung</b>: es können maximal 6 Bedingungen angezeigt werden!
--
-- <p>Mögliche Aufstiegsbedingungen:
-- <ul>
-- <li><b>Entitytyp besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Entities = {
--     {Entities.B_Bakery, 2},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Entitykategorie besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities einer Kategorie besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Category = {
--     {EntitiyCategories.CattlePasture, 10},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Gütertyp besitzen</b><br/>
-- Der Spieler muss Rohstoffe oder Güter eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Goods = {
--     {Goods.G_RawFish, 35},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Produkte erzeugen</b><br/>
-- Der Spieler muss Gebrauchsgegenstände für ein Bedürfnis bereitstellen. Hier
-- werden nicht die Warentypen sonderen deren Kategorie angegeben.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Products = {
--     {GoodCategories.GC_Clothes, 6},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Güter konsumieren</b><br/>
-- Die Siedler müssen eine Menge einer bestimmten Waren konsumieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Consume = {
--     {Goods.G_Bread, 30},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Buffs aktivieren</b><br/>
-- Der Spieler muss einen Buff aktivieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Buff = {
--     Buffs.Buff_FoodDiversity,
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Stadtruf erreichen</b><br/>
-- Der Ruf der Stadt muss einen bestimmten Wert erreichen oder überschreiten.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Reputation = 20
-- </code></pre>
--
-- <li><b>Anzahl an Dekorationen</b><br/>
-- Der Spieler muss mindestens die Anzahl der angegebenen Dekoration besitzen.
-- <code><pre>
-- KnightTitleRequirements[KnightTitles.Mayor].DecoratedBuildings = {
--     {Goods.G_Banner, 9 },
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl voll dekorierter Gebäude</b><br/>
-- Anzahl an Gebäuden, an die alle vier Dekorationen angebracht sein müssen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].FullDecoratedBuildings = 12
-- </code></pre>
-- </li>
--
-- <li><b>Spezialgebäude ausbauen</b><br/>
-- Ein Spezielgebäude muss ausgebaut werden.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Storehouse = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Cathedrals = 1
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl Siedler</b><br/>
-- Der Spieler benötigt eine Gesamtzahl an Siedlern.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Settlers = 40
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl reiche Stadtgebäude</b><br/>
-- Eine Anzahl an Gebäuden muss durch Einnahmen Reichtum erlangen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].RichBuildings = 30
-- </code></pre>
-- </li>
--
-- <li><b>Benutzerdefiniert</b><br/>
-- Eine benutzerdefinierte Funktion, die entweder als Schalter oder als Zähler
-- fungieren kann und true oder false zurückgeben muss. Soll ein Zähler
-- angezeigt werden, muss nach dem Wahrheitswert der minimale und der maximale
-- Wert des Zählers folgen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Custom = {
--     {SomeFunction, {1, 1}, "Überschrift", "Beschreibung"}
--     ...
-- }
--
-- -- Funktion prüft Schalter
-- function SomeFunction(_PlayerID, _NextTitle, _Index)
--     return gvMission.MySwitch == true;
-- end
-- -- Funktion prüft Zähler
-- function SomeFunction(_PlayerID, _NextTitle, _Index)
--     return gvMission.MyCounter == 6, gvMission.MyCounter, 6;
-- end
-- </code></pre>
-- </li>
-- </ul></p>
-- 
-- @within Beschreibung
-- @set sort=true
--



-- Spielinterna ------------------------------------------------------------- --

---
-- Prüft, ob genug Entities in einer bestimmten Kategorie existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Category == nil then
        return;
    end
    if _i then
        local EntityCategory = KnightTitleRequirements[_KnightTitle].Category[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Category[_i][2];

        local ReachedAmount = 0;
        if EntityCategory == EntityCategories.Spouse then
            ReachedAmount = Logic.GetNumberOfSpouses(_PlayerID);
        else
            local Buildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategory)};
            for i=1, #Buildings do
                if Logic.IsBuilding(Buildings[i]) == 1 then
                    if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                        ReachedAmount = ReachedAmount +1;
                    end
                else
                    ReachedAmount = ReachedAmount +1;
                end
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Category do
            bool, reach, need = DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Entities eines bestimmten Typs existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Entities == nil then
        return;
    end
    if _i then
        local EntityType = KnightTitleRequirements[_KnightTitle].Entities[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Entities[_i][2];
        local Buildings = GetPlayerEntities(_PlayerID, EntityType);

        local ReachedAmount = 0;
        for i=1, #Buildings do
            if Logic.IsBuilding(Buildings[i]) == 1 then
                if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                    ReachedAmount = ReachedAmount +1;
                end
            else
                ReachedAmount = ReachedAmount +1;
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Entities do
            bool, reach, need = DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob es genug Einheiten eines Warentyps gibt.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfGoodTypesForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Goods == nil then
        return;
    end
    if _i then
        local GoodType = KnightTitleRequirements[_KnightTitle].Goods[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Goods[_i][2];
        local ReachedAmount = GetPlayerGoodsInSettlement(GoodType, _PlayerID, true);

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Goods do
            bool, reach, need = DoesNeededNumberOfGoodTypesForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Siedler genug Einheiten einer Ware konsumiert haben.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfConsumedGoodsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Consume == nil then
        return;
    end
    if _i then
        QSB.ConsumedGoodsCounter[_PlayerID] = QSB.ConsumedGoodsCounter[_PlayerID] or {};

        local GoodType = KnightTitleRequirements[_KnightTitle].Consume[_i][1];
        local GoodAmount = QSB.ConsumedGoodsCounter[_PlayerID][GoodType] or 0;
        local NeededGoodAmount = KnightTitleRequirements[_KnightTitle].Consume[_i][2];
        if GoodAmount >= NeededGoodAmount then
            return true, GoodAmount, NeededGoodAmount;
        else
            return false, GoodAmount, NeededGoodAmount;
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Consume do
            bool, reach, need = DoNeededNumberOfConsumedGoodsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return false, reach, need
            end
        end
        return true, reach, need;
    end
end

---
-- Prüft, ob genug Waren der Kategorie hergestellt wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNumberOfProductsInCategoryExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Products == nil then
        return;
    end
    if _i then
        local GoodAmount = 0;
        local NeedAmount = KnightTitleRequirements[_KnightTitle].Products[_i][2];
        local GoodCategory = KnightTitleRequirements[_KnightTitle].Products[_i][1];
        local GoodsInCategory = {Logic.GetGoodTypesInGoodCategory(GoodCategory)};

        for i=1, #GoodsInCategory do
            GoodAmount = GoodAmount + GetPlayerGoodsInSettlement(GoodsInCategory[i], _PlayerID, true);
        end
        return (GoodAmount >= NeedAmount), GoodAmount, NeedAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Products do
            bool, reach, need = DoNumberOfProductsInCategoryExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob ein bestimmter Buff für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededDiversityBuffForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Buff == nil then
        return;
    end
    if _i then
        local buff = KnightTitleRequirements[_KnightTitle].Buff[_i];
        if Logic.GetBuff(_PlayerID,buff) and Logic.GetBuff(_PlayerID,buff) ~= 0 then
            return true;
        end
        return false;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Buff do
            bool, reach, need = DoNeededDiversityBuffForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Custom Function true vermeldet.
--
-- <b>Hinweis</b>: Die Funktion wird innerhalb eines GUI Update aufgerufen.
-- Schreibe daher effizienten Lua Code!
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoCustomFunctionForKnightTitleSucceed = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Custom == nil then
        return;
    end
    if _i then
        return KnightTitleRequirements[_KnightTitle].Custom[_i][1](_PlayerID, _KnightTitle, _i);
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Custom do
            bool, reach, need = DoCustomFunctionForKnightTitleSucceed(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Dekoration eines Typs angebracht wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].DecoratedBuildings == nil then
        return
    end

    if _i then
        local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
        local DecorationGoodType = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][1]
        local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][2]
        local BuildingsWithDecoration = 0

        for i=1, #CityBuildings do
            local BuildingID = CityBuildings[i]
            local GoodState = Logic.GetBuildingWealthGoodState(BuildingID, DecorationGoodType)
            if GoodState > 0 then
                BuildingsWithDecoration = BuildingsWithDecoration + 1
            end
        end

        if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
            return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
        else
            return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].DecoratedBuildings do
            bool, reach, need = DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Spezialgebäude weit genug ausgebaut sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _EntityCategory Entity Category
-- @within Originalfunktionen
-- @local
--
DoNeededSpecialBuildingUpgradeForKnightTitleExist = function( _PlayerID, _KnightTitle, _EntityCategory)
    local SpecialBuilding
    local SpecialBuildingName
    if _EntityCategory == EntityCategories.Headquarters then
        SpecialBuilding = Logic.GetHeadquarters(_PlayerID)
        SpecialBuildingName = "Headquarters"
    elseif _EntityCategory == EntityCategories.Storehouse then
        SpecialBuilding = Logic.GetStoreHouse(_PlayerID)
        SpecialBuildingName = "Storehouse"
    elseif _EntityCategory == EntityCategories.Cathedrals then
        SpecialBuilding = Logic.GetCathedral(_PlayerID)
        SpecialBuildingName = "Cathedrals"
    else
        return
    end
    if KnightTitleRequirements[_KnightTitle][SpecialBuildingName] == nil then
        return
    end
    local NeededUpgradeLevel = KnightTitleRequirements[_KnightTitle][SpecialBuildingName]
    if SpecialBuilding ~= nil then
        local SpecialBuildingUpgradeLevel = Logic.GetUpgradeLevel(SpecialBuilding)
        if SpecialBuildingUpgradeLevel >= NeededUpgradeLevel then
            return true, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        else
            return false, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        end
    else
        return false, 0, NeededUpgradeLevel
    end
end

---
-- Prüft, ob der Ruf der Stadt hoch genug ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoesNeededCityReputationForKnightTitleExist = function(_PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].Reputation == nil then
        return;
    end
    local NeededAmount = KnightTitleRequirements[_KnightTitle].Reputation;
    if not NeededAmount then
        return;
    end
    local ReachedAmount = math.floor((Logic.GetCityReputation(_PlayerID) * 100) + 0.5);
    if ReachedAmount >= NeededAmount then
        return true, ReachedAmount, NeededAmount;
    end
    return false, ReachedAmount, NeededAmount;
end

---
-- Prüft, ob genug Gebäude vollständig dekoriert sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings == nil then
        return
    end
    local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
    local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings
    local BuildingsWithDecoration = 0

    for i=1, #CityBuildings do
        local BuildingID = CityBuildings[i]
        local AmountOfWealthGoodsAtBuilding = 0

        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Banner ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Sign  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Candle) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Ornament  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if AmountOfWealthGoodsAtBuilding >= 4 then
            BuildingsWithDecoration = BuildingsWithDecoration + 1
        end
    end

    if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
        return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
    else
        return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
    end
end

---
-- Prüft, ob der Spieler befördert werden kann.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
CanKnightBePromoted = function(_PlayerID, _KnightTitle)
    if _KnightTitle == nil then
        _KnightTitle = Logic.GetKnightTitle(_PlayerID) + 1;
    end

    if Logic.CanStartFestival(_PlayerID, 1) == true then
        if  KnightTitleRequirements[_KnightTitle] ~= nil
        and DoesNeededNumberOfSettlersForKnightTitleExist(_PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfGoodsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Headquarters) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Storehouse) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Cathedrals)  ~= false
        and DoNeededNumberOfRichBuildingsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededCityReputationForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfGoodTypesForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededDiversityBuffForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoCustomFunctionForKnightTitleSucceed( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfConsumedGoodsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNumberOfProductsInCategoryExist( _PlayerID, _KnightTitle) ~= false then
            return true;
        end
    end
    return false;
end

---
-- Der Spieler gewinnt das Spiel
-- @within Originalfunktionen
-- @local
--
VictroryBecauseOfTitle = function()
    QuestTemplate:TerminateEventsAndStuff();
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
end

