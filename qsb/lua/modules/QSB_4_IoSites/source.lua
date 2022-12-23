--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

ModuleInteractiveSites = {
    Properties = {
        Name = "ModuleInteractiveSites",
    },

    Global = {
        CreatedSites = {},
    };
    Local  = {};

    Shared = {
        Text = {
            Description = {
                Title = {
                    de = "Gebäude bauen",
                    en = "Create building",
                    fr = "Construire le bâtiment",
                },
                Text = {
                    de = "Beauftragt den Bau eines Gebäudes. Ein Siedler wird aus"..
                        " dem Lagerhaus kommen und mit dem Bau beginnen.",
                    en = "Order a building. A worker will come out of the"..
                        " storehouse and erect it.",
                    fr = "Commande la construction d'un bâtiment. Un Settler sortira de"..
                        " l'entrepôt et commencera la construction.",
                },
            }
        }
    };
};

QSB.NonPlayerCharacterObjects = {};

-- Global Script ------------------------------------------------------------ --

function ModuleInteractiveSites.Global:OnGameStart()
    QSB.ScriptEvents.InteractiveSiteBuilt = API.RegisterScriptEvent("Event_InteractiveSiteBuilt");

    self:OverrideConstructionCompleteCallback();
end

function ModuleInteractiveSites.Global:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    elseif _ID == QSB.ScriptEvents.ObjectReset then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveSite then
            -- Nothing to do?
        end
    elseif _ID == QSB.ScriptEvents.ObjectDelete then
        if IO[arg[1]] and IO[arg[1]].IsInteractiveSite then
            -- Nothing to do?
        end
    end
end

function ModuleInteractiveSites.Global:OverrideConstructionCompleteCallback()
    GameCallback_OnBuildingConstructionComplete_Orig_QSB_InteractiveSites = GameCallback_OnBuildingConstructionComplete;
    GameCallback_OnBuildingConstructionComplete = function(_PlayerID, _EntityID)
        GameCallback_OnBuildingConstructionComplete_Orig_QSB_InteractiveSites(_PlayerID, _EntityID);

        if ModuleInteractiveSites.Global.CreatedSites[_EntityID] then
            local Object = ModuleInteractiveSites.Global.CreatedSites[_EntityID];
            if Object then
                API.SendScriptEvent(QSB.ScriptEvents.InteractiveSiteBuilt, Object.Name, _PlayerID, _EntityID);
                Logic.ExecuteInLuaLocalState(string.format(
                    [[API.SendScriptEvent(QSB.ScriptEvents.InteractiveSiteBuilt, "%s", %d, %d)]],
                    Object.Name,
                    _PlayerID,
                    _EntityID
                ));
            end
        end
    end
end

function ModuleInteractiveSites.Global:CreateIOBuildingSite(_Data)
    local Costs = _Data.Costs or {Logic.GetEntityTypeFullCost(_Data.Type)};
    local Title = _Data.Title or ModuleInteractiveSites.Shared.Text.Description.Title;
    local Text = _Data.Text or ModuleInteractiveSites.Shared.Text.Description.Text;

    local EntityID = GetID(_Data.Name);
    Logic.SetModel(EntityID, Models.Buildings_B_BuildingPlot_10x10);
    Logic.SetVisible(EntityID, true);

    _Data.Title = Title;
    _Data.Text = Text;
    _Data.Costs = Costs;
    _Data.ConditionOrigSite = _Data.Condition;
    _Data.ActionOrigSite = _Data.Action;
    API.SetupObject(_Data);

    IO[_Data.Name].Condition = function(_Data)
        if _Data.ConditionOrigSite then
            _Data.ConditionOrigSite(_Data);
        end
        return self:ConditionIOConstructionSite(_Data);
    end
    IO[_Data.Name].Action = function(_Data, _KnightID, _PlayerID)
        self:CallbackIOConstructionSite(_Data, _KnightID, _PlayerID);
        if _Data.ActionOrigSite then
            _Data.ActionOrigSite(_Data, _KnightID, _PlayerID);
        end
    end
end

function ModuleInteractiveSites.Global:CallbackIOConstructionSite(_Data, _KnightID, _PlayerID)
    local Position = GetPosition(_Data.Name);
    local EntityID = GetID(_Data.Name);
    local Orientation = Logic.GetEntityOrientation(EntityID);
    local SiteID = Logic.CreateConstructionSite(Position.X, Position.Y, Orientation, _Data.Type, _Data.PlayerID);
    Logic.SetVisible(EntityID, false);

    if (SiteID == nil) then
        warn("For object '" .._Data.Name.. "' building placement failed! Building created instead");
        SiteID = Logic.CreateEntity(_Data.Type, Position.X, Position.Y, Orientation, _Data.PlayerID);
    end
    self.CreatedSites[SiteID] = _Data;
end

function ModuleInteractiveSites.Global:ConditionIOConstructionSite(_Data)
    local EntityID = GetID(_Data.Name);
    local TerritoryID = GetTerritoryUnderEntity(EntityID);
    local PlayerID = Logic.GetTerritoryPlayerID(TerritoryID);

    if Logic.GetStoreHouse(_Data.PlayerID) == 0 then
        return false;
    end
    if _Data.PlayerID ~= PlayerID then
        return false;
    end
    return true;
end

-- Local Script ------------------------------------------------------------- --

function ModuleInteractiveSites.Local:OnGameStart()
end

function ModuleInteractiveSites.Local:OnEvent(_ID, ...)
    if _ID == QSB.ScriptEvents.LoadscreenClosed then
        self.LoadscreenClosed = true;
    end
end

-- -------------------------------------------------------------------------- --

Revision:RegisterModule(ModuleInteractiveSites);

