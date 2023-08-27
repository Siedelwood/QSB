-- -------------------------------------------------------------------------- --

---
-- Es können Schatztruhen und Ruinen mit Inhalten bestückt werden.
-- 
-- Der Schatz einer Kiste oder Ruine wird nach Aktivierung in einem Karren
-- abtransportiert.
--
-- Die erzeugten Truhen und Ruinen verhalten sich wie Interaktive Objekte.
-- Werden ihnen Aktionen und Bedingungen mitgegeben, gelten für diese Funktionen
-- die gleichen Regeln wie bei Interaktiven Objekten.
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
-- Erstellt eine Schatztruhe mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert.
--
-- @param[type=string] _Name      Name der zu ersetzenden Script Entity
-- @param[type=number] _Good      Warentyp
-- @param[type=number] _Min       Mindestmenge
-- @param[type=number] _Max       (Optional) Maximalmenge
-- @param[type=number] _Action    (Optional) Aktion nach Aktivierung
-- @param[type=number] _Condition (Optional) Bedingung zur Aktivierung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Bepspiel #1: Normale Truhe
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300);
--
-- @usage
-- -- Bepspiel #2: Truhe mit Aktion
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300, MyActionFunction);
--
-- @usage
-- -- Bepspiel #3: Truhe mit Bedingung
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300, MyActionFunction, MyConditionFunction);
--
function API.CreateRandomChest(_Name, _Good, _Min, _Max, _Action, _Condition)
    if GUI then
        return;
    end

    if not IsExisting(_Name) then
        error("API.CreateRandomChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomChest: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomChest: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end

    if type(_Max) ~= "number" then
        _Max = _Min;
    else
        if type(_Max) ~= "number" or _Max < 1 then
            error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") is wrong!");
            return;
        end
        if _Max < _Min then
            error("API.CreateRandomChest: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
            return;
        end
    end
    ModuleTreasure.Global:CreateRandomChest(_Name, _Good, _Min, _Max, false, false, _Condition, _Action);
end

---
-- Erstellt ein beliebiges IO mit einer zufälligen Menge an Waren
-- des angegebenen Typs.
--
-- Die Menge der Ware ist dabei zufällig und liegt zwischen dem Minimalwert
-- und dem Maximalwert.
--
-- @param[type=string] _Name      Name des Script Entity
-- @param[type=number] _Good      Warentyp
-- @param[type=number] _Min       Mindestmenge
-- @param[type=number] _Max       (Optional) Maximalmenge
-- @param[type=number] _Condition (Optional) Bedingung zur Aktivierung
-- @param[type=number] _Action    (Optional) Aktion nach Aktivierung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Bepspiel #1: Normale Ruine
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300);
--
-- @usage
-- -- Bepspiel #2: Ruine mit Aktion
-- -- Wird die Bedingung weggelassen, tritt die Aktion an ihre Stelle
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300, MyActionFunction);
--
-- @usage
-- -- Bepspiel #3: Ruine mit Bedingung
-- -- Wenn eine Bedingung gebraucht wird, muss eine Action angegeben werden.
-- API.CreateRandomTreasure("well1", Goods.G_Gems, 100, 300, MyConditionFunction, MyActionFunction);
--
function API.CreateRandomTreasure(_Name, _Good, _Min, _Max, _Condition, _Action)
    if GUI then
        return;
    end
    if not _Action then
        _Action = _Condition;
        _Condition = nil;
    end

    if not IsExisting(_Name) then
        error("API.CreateRandomTreasure: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Good) == nil then
        error("API.CreateRandomTreasure: _Good (" ..tostring(_Good).. ") is wrong!");
        return;
    end
    if type(_Min) ~= "number" or _Min < 1 then
        error("API.CreateRandomTreasure: _Min (" ..tostring(_Min).. ") is wrong!");
        return;
    end

    if type(_Max) ~= "number" then
        _Max = _Min;
    else
        if type(_Max) ~= "number" or _Max < 1 then
            error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") is wrong!");
            return;
        end
        if _Max < _Min then
            error("API.CreateRandomTreasure: _Max (" ..tostring(_Max).. ") must be greather then _Min (" ..tostring(_Min).. ")!");
            return;
        end
    end
    ModuleTreasure.Global:CreateRandomChest(_Name, _Good, _Min, _Max, false, true, _Condition, _Action);
end

---
-- Erstellt eine Schatztruhe mit einer zufälligen Menge Gold.
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomGoldChest("chest")
--
function API.CreateRandomGoldChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomGoldChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleTreasure.Global:CreateRandomGoldChest(_Name);
end

---
-- Erstellt eine Schatztruhe mit zufälligen Gütern.
--
-- Güter können seien: Eisen, Fisch, Fleisch, Getreide, Holz,
-- Honig, Kräuter, Milch, Stein, Wolle.
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomResourceChest("chest")
--
function API.CreateRandomResourceChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomResourceChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleTreasure.Global:CreateRandomResourceChest(_Name);
end

---
-- Erstellt eine Schatztruhe mit zufälligen Luxusgütern.
--
-- Luxusgüter können seien: Salz, Farben (, Edelsteine, Musikinstrumente
-- Weihrauch)
--
-- @param[type=string] _Name Name der zu ersetzenden Script Entity
-- @within Anwenderfunktionen
--
-- @usage
-- API.CreateRandomLuxuryChest("chest")
--
function API.CreateRandomLuxuryChest(_Name)
    if GUI then
        return;
    end
    if not IsExisting(_Name) then
        error("API.CreateRandomLuxuryChest: _Name (" ..tostring(_Name).. ") does not exist!");
        return;
    end
    ModuleTreasure.Global:CreateRandomLuxuryChest(_Name);
end

