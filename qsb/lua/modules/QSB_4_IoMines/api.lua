--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Der Mapper kann eine Stein- oder Eisenmine restaurieren, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann die Mine einstürzen, wenn sie ausgebeutet wurde.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field InteractiveMineDepleted  Eine ehemals interaktive Mine wurde ausgebeutet (Parameter: ScriptName)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erstelle eine verschüttete Eisenmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- Die Parameter der interaktiven Mine werden durch ihre Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Text der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>table</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ResourceAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen nach der Aktivierung</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RefillAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionCondition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionAction</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data Datentabelle der Mine
-- @within Anwenderfunktionen
-- @see API.CreateIOStoneMine
--
-- @usage
-- -- Beispiel #1: Eine einfache Mine
-- API.CreateIOIronMine{
--     Position = "mine"
-- };
--
-- @usage
-- -- Beispiel #2: Mine mit geänderten Kosten
-- API.CreateIOIronMine{
--     Position = "mine",
--     Costs    = {Goods.G_Wood, 15}
-- };
--
-- @usage
-- -- Beispiel #3: Mine mit Aktivierungsbedingung
-- API.CreateIOIronMine{
--     Position              = "mine",
--     Costs                 = {Goods.G_Wood, 15},
--     ConstructionCondition = function(_Data)
--         return HeroHasShovel == true;
--     end
-- };
--
function API.CreateIOIronMine(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Position) then
        error("API.CreateIOIronMine: Position (" ..tostring(_Data.Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Data.Costs then
        if _Data.Costs[1] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[1]) == nil then
                error("API.CreateIOIronMine: First cost type (" ..tostring(_Data.Costs[1]).. ") is wrong!");
                return;
            end
            if _Data.Costs[2] and (type(_Data.Costs[2]) ~= "number" or _Data.Costs[2] < 1) then
                error("API.CreateIOIronMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Data.Costs[3] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[3]) == nil then
                error("API.CreateIOIronMine: Second cost type (" ..tostring(_Data.Costs[3]).. ") is wrong!");
                return;
            end
            if _Data.Costs[4] and (type(_Data.Costs[4]) ~= "number" or _Data.Costs[4] < 1) then
                error("API.CreateIOIronMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Data.Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Data.Position,
        Entities.R_IronMine,
        _Data.Title,
        _Data.Text,
        Costs,
        _Data.ResourceAmount,
        _Data.RefillAmount,
        _Data.ConstructionCondition,
        _Data.ConditionInfo,
        _Data.ConstructionAction
    );
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- Werden keine Materialkosten bestimmt, benötigt der Bau der Mine 500 Gold und
-- 20 Holz.
--
-- Die Parameter der interaktiven Mine werden durch ihre Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- Mögliche Angaben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- <td><b>Optional</b></td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Text der Beschreibung für die Mine</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td>table</td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <tr>
-- <td>ResourceAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen nach der Aktivierung</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RefillAmount</td>
-- <td>number</td>
-- <td>Menge an Rohstoffen, die ein Geologe auffüllt (0 == nicht nachfüllbar)</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionCondition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConstructionAction</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktion nach der Aktivierung.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data Datentabelle der Mine
-- @within Anwenderfunktionen
-- @see API.CreateIOIronMine
--
-- @usage
-- -- Beispiel #1: Eine einfache Mine
-- API.CreateIOStoneMine{
--     Position = "mine"
-- };
--
-- @usage
-- -- Beispiel #2: Mine mit geänderten Kosten
-- API.CreateIOStoneMine{
--     Position = "mine",
--     Costs    = {Goods.G_Wood, 15}
-- };
--
-- @usage
-- -- Beispiel #3: Mine mit Aktivierungsbedingung
-- API.CreateIOStoneMine{
--     Position              = "mine",
--     Costs                 = {Goods.G_Wood, 15},
--     ConstructionCondition = function(_Data)
--         return HeroHasPickaxe == true;
--     end
-- };
--
function API.CreateIOStoneMine(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Position) then
        error("API.CreateIOStoneMine: Position (" ..tostring(_Data.Position).. ") does not exist!");
        return;
    end

    local Costs = {Goods.G_Gold, 500, Goods.G_Wood, 20};
    if _Data.Costs then
        if _Data.Costs[1] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[1]) == nil then
                error("API.CreateIOStoneMine: First cost type (" ..tostring(_Data.Costs[1]).. ") is wrong!");
                return;
            end
            if _Data.Costs[2] and (type(_Data.Costs[2]) ~= "number" or _Data.Costs[2] < 1) then
                error("API.CreateIOStoneMine: First cost amount must be above 0!");
                return;
            end
        end
        if _Data.Costs[3] then
            if GetNameOfKeyInTable(Goods, _Data.Costs[3]) == nil then
                error("API.CreateIOStoneMine: Second cost type (" ..tostring(_Data.Costs[3]).. ") is wrong!");
                return;
            end
            if _Data.Costs[4] and (type(_Data.Costs[4]) ~= "number" or _Data.Costs[4] < 1) then
                error("API.CreateIOStoneMine: Second cost amount must be above 0!");
                return;
            end
        end
        Costs = _Data.Costs;
    end

    ModuleInteractiveMines.Global:CreateIOMine(
        _Data.Position,
        Entities.R_StoneMine,
        _Data.Title,
        _Data.Text,
        Costs,
        _Data.ResourceAmount,
        _Data.RefillAmount,
        _Data.ConstructionCondition,
        _Data.ConditionInfo,
        _Data.ConstructionAction
    );
end

