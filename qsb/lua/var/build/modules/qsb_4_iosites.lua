--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht mit interaktiven Objekten Baustellen zu setzen.
--
-- Die Baustelle muss durch den Helden aktiviert werden. Ein Siedler wird aus
-- dem Lagerhaus kommen und das Gebäude bauen.
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
-- @field InteractiveSiteBuilt (Parameter: ScriptName, PlayerID, BuildingID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erzeugt eine Baustelle eines beliebigen Gebäudetyps an der Position.
--
-- Diese Baustelle kann durch einen Helden aktiviert werden. Dann wird ein
-- Siedler zur Baustelle eilen und das Gebäude aufbauen. Es ist egal, ob es
-- sich um ein Territorium des Spielers oder einer KI handelt.
--
-- Es ist dabei zu beachten, dass der Spieler, dem die Baustelle zugeordnet
-- wird, das Territorium besitzt, auf dem er bauen soll. Des weiteren muss
-- er über ein Lagerhaus/Hauptzelt verfügen.
--
-- <p><b>Hinweis:</b> Es kann vorkommen, dass das Model der Baustelle nicht
-- geladen wird. Dann ist der Boden der Baustelle schwarz. Sobald wenigstens
-- ein reguläres Gebäude gebaut wurde, sollte die Textur jedoch vorhanden sein.
-- </p>
--
-- Mögliche Angaben für die Konfiguration:
-- <table border="1">
-- <tr><td><b>Feldname</b></td><td><b>Typ</b></td><td><b>Beschreibung</b></td></tr>
-- <tr><td>Name</td><td>string</td><td>Position für die Baustelle</td></tr>
-- <tr><td>PlayerID</td><td>number</td><td>Besitzer des Gebäudes</td></tr>
-- <tr><td>Type</td><td>number</td><td>Typ des Gebäudes</td></tr>
-- <tr><td>Costs</td><td>table</td><td>(optional) Eigene Gebäudekosten</td></tr>
-- <tr><td>Distance</td><td>number</td><td>(optional) Aktivierungsentfernung</td></tr>
-- <tr><td>Icon</td><td>table</td><td>(optional) Icon des Schalters</td></tr>
-- <tr><td>Title</td><td>string</td><td>(optional) Titel der Beschreibung</td></tr>
-- <tr><td>Text</td><td>string</td><td>(optional) Text der Beschreibung</td></tr>
-- <tr><td>Condition</td><td>function</td><td>(optional) Optionale Aktivierungsbedingung</td></tr>
-- <tr><td>Action</td><td>function</td><td>(optional) Optionale Funktion bei Aktivierung</td></tr>
-- </table>
--
-- @param[type=table] _Data Konfiguration des Objektes
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Eine einfache Baustelle erzeugen
-- API.CreateIOBuildingSite {
--     Name     = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery
-- };
--
-- @usage
-- -- Beispiel #2: Baustelle mit Kosten erzeugen
-- API.CreateIOBuildingSite {
--     Name     = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery,
--     Costs    = {Goods.G_Wood, 4},
--     Distance = 1000
-- };
--
function API.CreateIOBuildingSite(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.CreateIOBuildingSite: Position (" ..tostring(_Data.Name).. ") does not exist!");
        return;
    end
    if type(_Data.PlayerID) ~= "number" or _Data.PlayerID < 1 or _Data.PlayerID > 8 then
        error("API.CreateIOBuildingSite: PlayerID is wrong!");
        return;
    end
    if GetNameOfKeyInTable(Entities, _Data.Type) == nil then
        error("API.CreateIOBuildingSite: Type (" ..tostring(_Data.Type).. ") is wrong!");
        return;
    end
    if _Data.Costs and (type(_Data.Costs) ~= "table" or #_Data.Costs %2 ~= 0) then
        error("API.CreateIOBuildingSite: Costs has the wrong format!");
        return;
    end
    if _Data.Distance and (type(_Data.Distance) ~= "number" or _Data.Distance < 100) then
        error("API.CreateIOBuildingSite: Distance (" ..tostring(_Data.Distance).. ") is wrong or too small!");
        return;
    end
    if _Data.Condition and type(_Data.Condition) ~= "function" then
        error("API.CreateIOBuildingSite: Condition must be a function!");
        return;
    end
    if _Data.Action and type(_Data.Action) ~= "function" then
        error("API.CreateIOBuildingSite: Action must be a function!");
        return;
    end
    ModuleInteractiveSites.Global:CreateIOBuildingSite(_Data);
end

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
        Version = "3.0.0 (BETA 2.0.0)",
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

Swift:RegisterModule(ModuleInteractiveSites);

