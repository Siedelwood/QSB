--[[
Swift_5_InteractiveChests/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleInteractiveChests = {
    Properties = {
        Name = "ModuleInteractiveChests",
    },

    Global = {
        Chests = {},
    };
    Local  = {};
    -- This is a shared structure but the values are asynchronous!
    Shared = {};

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

QSB.NonPlayerCharacterObjects = {};

-- Global Script ------------------------------------------------------------ --

function ModuleInteractiveChests.Global:OnGameStart()
    QSB.ScriptEvents.InteractiveTreasureActivated = API.RegisterScriptEvent("Event_InteractiveTreasureActivated");
end

function ModuleInteractiveChests.Global:OnEvent(_ID, _Event, ...)
    if _ID == QSB.ScriptEvents.ObjectReset then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveChest then
            self:ResetIOChest(arg[1]);
        end
    elseif _ID == QSB.ScriptEvents.ObjectDelete then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveChest then
            -- Nothing to do?
        end
    end
end

function ModuleInteractiveChests.Global:CreateRandomChest(_Name, _Good, _Min, _Max, _DirectPay, _NoModelChange, _Condition, _Action)
    _Min = math.floor((_Min ~= nil and _Min > 0 and _Min) or 1);
    _Max = math.floor((_Max ~= nil and _Max > 1 and _Max) or 2);
    assert(_Good ~= nil, "CreateRandomChest: Good does not exist!");
    assert(_Min <= _Max, "CreateRandomChest: min amount must be smaller or equal than max amount!");

    -- Debug Informationen schreiben
    debug(string.format(
        "ModuleInteractiveChests: Creating chest (%s, %s, %d, %d, %s, %s)",
        _Name,
        Logic.GetGoodTypeName(_Good),
        _Min,
        _Max,
        tostring(_DirectPay == true),
        tostring(_NoModelChange == true)
    ))

    -- Texte und Model setzen
    local Title = ModuleInteractiveChests.Text.Treasure.Title;
    local Text  = ModuleInteractiveChests.Text.Treasure.Text;
    if not _NoModelChange then
        Title = ModuleInteractiveChests.Text.Chest.Title;
        Text  = ModuleInteractiveChests.Text.Chest.Text;

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

            API.SendScriptEvent(QSB.ScriptEvents.InteractiveTreasureActivated, _Data.Name, _KnightID, _PlayerID);
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(%d, "%s", %d, %d)]],
                QSB.ScriptEvents.InteractiveTreasureActivated,
                _Data.Name,
                _KnightID,
                _PlayerID
            ));
        end,
    };
end

function ModuleInteractiveChests.Global:ResetIOChest(_ScriptName)
    if not IO[_ScriptName].DoNotChangeModel then
        local EntityID = ReplaceEntity(_ScriptName, Entities.XD_ScriptEntity, 0);
        Logic.SetModel(EntityID, Models.Doodads_D_X_ChestClose);
        Logic.SetVisible(EntityID, true);
    end
end

function ModuleInteractiveChests.Global:CreateRandomGoldChest(_Name)
    self:CreateRandomChest(_Name, Goods.G_Gold, 300, 600, false);
end

function ModuleInteractiveChests.Global:CreateRandomResourceChest(_Name)
    local PossibleGoods = {
        Goods.G_Iron, Goods.G_Stone, Goods.G_Wood, Goods.G_Wool,
        Goods.G_Carcass, Goods.G_Herb, Goods.G_Honeycomb,
        Goods.G_Milk, Goods.G_RawFish, Goods.G_Grain
    };
    local Good = PossibleGoods[math.random(1, #PossibleGoods)];
    self:CreateRandomChest(_Name, Good, 30, 60, false);
end

function ModuleInteractiveChests.Global:CreateRandomLuxuryChest(_Name)
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

function ModuleInteractiveChests.Local:OnGameStart()
    QSB.ScriptEvents.InteractiveTreasureActivated = API.RegisterScriptEvent("Event_InteractiveTreasureActivated");
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleInteractiveChests);

