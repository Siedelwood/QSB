--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

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
-- @param[type=number] _Condition (Optional) Bedingung zur Aktivierung
-- @param[type=number] _Action    (Optional) Aktion nach Aktivierung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Bepspiel #1: Normale Truhe
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300);
--
-- @usage
-- -- Bepspiel #2: Truhe mit Aktion
-- -- Wird die Bedingung weggelassen, tritt die Aktion an ihre Stelle
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300, MyActionFunction);
--
-- @usage
-- -- Bepspiel #3: Truhe mit Bedingung
-- -- Wenn eine Bedingung gebraucht wird, muss eine Aktion angegeben werden.
-- API.CreateRandomChest("well1", Goods.G_Gems, 100, 300, MyConditionFunction, MyActionFunction);
--
function API.CreateRandomChest(_Name, _Good, _Min, _Max, _Condition, _Action)
    if GUI then
        return;
    end
    if not _Action then
        _Action = _Condition;
        _Condition = nil;
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

--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleTreasure = {
    Properties = {
        Name = "ModuleTreasure",
        Version = "3.0.0 (BETA 2.0.0)",
    },

    Global = {
        Chests = {},
    };
    Local  = {};

    Shared = {
        Text = {
            Chest = {
                Title = {
                    de = "Schatztruhe",
                    en = "Treasure Chest",
                    fr = "Coffre au trésor",
                },
                Text = {
                    de = "Diese Truhe enthält einen geheimen Schatz. Öffnet sie, um den Schatz zu bergen.",
                    en = "This chest contains a secred treasure. Open it to salvage the treasure.",
                    fr = "Ce coffre contient un trésor secret. Ouvrez-le pour récupérer le trésor.",
                },
            },
            Treasure = {
                Title = {
                    de = "Versteckter Schatz",
                    en = "Hidden treasure",
                    fr = "Trésor caché",
                },
                Text = {
                    de = "Ihr habt einen geheimen Schatz entdeckt. Beeilt Euch und beansprucht ihn für Euch!",
                    en = "You have discovered a secred treasure. Be quick to claim it before it is to late!",
                    fr = "Vous avez découvert un trésor secret. Dépêchez-vous de le revendiquer!",
                },
            }
        }
    };
};

QSB.NonPlayerCharacterObjects = {};

-- Global Script ------------------------------------------------------------ --

function ModuleTreasure.Global:OnGameStart()
end

function ModuleTreasure.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ObjectReset then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveChest then
            self:ResetIOChest(arg[1]);
        end
    elseif _ID == QSB.ScriptEvents.ObjectDelete then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveChest then
            -- Nothing to do?
        end
    end
end

function ModuleTreasure.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _DirectPay, _NoModelChange, _Condition, _Action)
    _Min = math.floor((_Min ~= nil and _Min > 0 and _Min) or 1);
    _Max = math.floor((_Max ~= nil and _Max > 1 and _Max) or 2);
    assert(_Good ~= nil, "CreateRandomChest: Good does not exist!");
    assert(_Min <= _Max, "CreateRandomChest: min amount must be smaller or equal than max amount!");

    -- Debug Informationen schreiben
    debug(string.format(
        "ModuleTreasure: Creating chest (%s, %s, %d, %d, %s, %s)",
        _Name,
        Logic.GetGoodTypeName(_Good),
        _Min,
        _Max,
        tostring(_DirectPay == true),
        tostring(_NoModelChange == true)
    ))

    -- Texte und Model setzen
    local Title = ModuleTreasure.Shared.Text.Treasure.Title;
    local Text  = ModuleTreasure.Shared.Text.Treasure.Text;
    if not _NoModelChange then
        Title = ModuleTreasure.Shared.Text.Chest.Title;
        Text  = ModuleTreasure.Shared.Text.Chest.Text;

        local eID = ReplaceEntity(_Name, Entities.XD_ScriptEntity, 0);
        Logic.SetModel(eID, Models.Doodads_D_X_ChestClose);
        Logic.SetVisible(eID, true);
    end

    -- Menge an Gütern ermitteln
    local GoodAmount = _Min;
    if _Min < _Max then
        GoodAmount = math.random(_Min, _Max);
    end

    -- Rewards
    local DirectReward;
    local IOReward;
    if not _DirectPay then
        IOReward = {_Good, GoodAmount};
    else
        DirectReward = {_Good, GoodAmount};
    end

    API.SetupObject {
        Name                    = _Name,
        IsInteractiveChest      = true,
        Title                   = Title,
        Text                    = Text,
        Reward                  = IOReward,
        DirectReward            = DirectReward,
        Texture                 = {1, 6},
        Distance                = (_NoModelChange and 1200) or 650,
        Waittime                = 0,
        State                   = 0,
        DoNotChangeModel        = _NoModelChange == true,
        ActivationCondition     = _Condition,
        ActivationAction        = _Action,
        Condition               = function(_Data)
            if _Data.ActivationCondition then
                return _Data.ActivationCondition(_Data);
            end
            return true;
        end,
        Action                  = function(_Data, _KnightID, _PlayerID)
            if not _Data.DoNotChangeModel then
                Logic.SetModel(GetID(_Data.Name), Models.Doodads_D_X_ChestOpenEmpty);
            end
            if _Data.DirectReward then
                AddGood(_Data.DirectReward[1], _Data.DirectReward[2], _PlayerID);
            end
            if _Data.ActivationAction then
                _Data.ActivationAction(_Data, _KnightID, _PlayerID);
            end
        end,
    };
end

function ModuleTreasure.Global:ResetIOChest(_ScriptName)
    if not IO[_ScriptName].DoNotChangeModel then
        local EntityID = ReplaceEntity(_ScriptName, Entities.XD_ScriptEntity, 0);
        Logic.SetModel(EntityID, Models.Doodads_D_X_ChestClose);
        Logic.SetVisible(EntityID, true);
    end
end

function ModuleTreasure.Global:CreateRandomGoldChest(_Name)
    self:CreateRandomChest(_Name, Goods.G_Gold, 300, 600, false);
end

function ModuleTreasure.Global:CreateRandomResourceChest(_Name)
    local PossibleGoods = {
        Goods.G_Iron, Goods.G_Stone, Goods.G_Wood, Goods.G_Wool,
        Goods.G_Carcass, Goods.G_Herb, Goods.G_Honeycomb,
        Goods.G_Milk, Goods.G_RawFish, Goods.G_Grain
    };
    local Good = PossibleGoods[math.random(1, #PossibleGoods)];
    self:CreateRandomChest(_Name, Good, 30, 60, false);
end

function ModuleTreasure.Global:CreateRandomLuxuryChest(_Name)
    local Luxury = {Goods.G_Salt, Goods.G_Dye};
    if g_GameExtraNo >= 1 then
        table.insert(Luxury, Goods.G_Gems);
        table.insert(Luxury, Goods.G_MusicalInstrument);
        table.insert(Luxury, Goods.G_Olibanum);
    end
    local Good = Luxury[math.random(1, #Luxury)];
    self:CreateRandomChest(_Name, Good, 50, 100, false);
end

-- Local Script ------------------------------------------------------------- --

function ModuleTreasure.Local:OnGameStart()
end

function ModuleTreasure.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleTreasure);

