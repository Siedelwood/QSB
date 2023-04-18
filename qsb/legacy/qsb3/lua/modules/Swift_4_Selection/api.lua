--[[
Swift_4_Selection/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Die Optionen für selektierte Einheiten kann individualisiert werden.
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field SelectionChanged Die Selektion hat sich geändert (Parameter: PlayerID, OldIdList, NewIdList)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Deaktiviert oder aktiviert das Entlassen von Dieben.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseThieves(false);
--
function API.DisableReleaseThieves(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseThieves(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelection.Local.ThiefRelease = not _Flag;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Kriegsmaschinen.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSiegeEngines(true);
--
function API.DisableReleaseSiegeEngines(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseSiegeEngines(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelection.Local.SiegeEngineRelease = not _Flag;
end

---
-- Deaktiviert oder aktiviert das Entlassen von Soldaten.
-- @param[type=boolean] _Flag Deaktiviert (false) / Aktiviert (true)
-- @within Anwenderfunktionen
--
-- @usage
-- API.DisableReleaseSoldiers(false);
--
function API.DisableReleaseSoldiers(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState("API.DisableReleaseSoldiers(" ..tostring(_Flag).. ")");
        return;
    end
    ModuleSelection.Local.MilitaryRelease = not _Flag;
end

---
-- Prüpft ob das Entity selektiert ist.
--
-- @param _Entity Entity das selektiert sein soll (Skriptname oder ID)
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Entity ist selektiert
-- @within Anwenderfunktionen
--
-- @usage
-- if API.IsEntityInSelection("hakim", 1) then
--     -- Do something
-- end
--
function API.IsEntityInSelection(_Entity, _PlayerID)
    if IsExisting(_Entity) then
        local EntityID = GetID(_Entity);
        local SelectedEntities;
        if not GUI then
            SelectedEntities = ModuleSelection.Global.SelectedEntities[_PlayerID];
        else
            SelectedEntities = {GUI.GetSelectedEntities()};
        end
        for i= 1, #SelectedEntities, 1 do
            if SelectedEntities[i] == EntityID then
                return true;
            end
        end
    end
    return false;
end

---
-- Gibt die ID des selektierten Entity zurück.
--
-- Wenn mehr als ein Entity selektiert sind, wird das erste Entity
-- zurückgegeben. Sind keine Entities selektiert, wird 0 zurückgegeben.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local SelectedEntity = API.GetSelectedEntity(1);
--
function API.GetSelectedEntity(_PlayerID)
    local SelectedEntity;
    if not GUI then
        SelectedEntity = ModuleSelection.Global.SelectedEntities[_PlayerID][1];
    else
        SelectedEntity = GUI.GetSelectedEntity();
    end
    return SelectedEntity or 0;
end

---
-- Gibt alle selektierten Entities zurück.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=table] ID des selektierten Entities
-- @within Anwenderfunktionen
--
-- @usage
-- local Selection = API.GetSelectedEntities(1);
--
function API.GetSelectedEntities(_PlayerID)
    local SelectedEntities;
    if not GUI then
        SelectedEntities = ModuleSelection.Global.SelectedEntities[_PlayerID];
    else
        SelectedEntities = {GUI.GetSelectedEntities()};
    end
    return SelectedEntities;
end

-- Local callbacks

function SCP.Selection.DestroyEntity(_Entity)
    DestroyEntity(_Entity);
end

function SCP.Selection.SetTaskList(_Entity)
    Logic.SetTaskList(_Entity, TaskLists.TL_NPC_IDLE);
end

function SCP.Selection.ErectTrebuchet(_Entity)
    ModuleSelection.Global:MilitaryErectTrebuchet(_Entity);
end

function SCP.Selection.DisambleTrebuchet(_Entity)
    ModuleSelection.Global:MilitaryDisambleTrebuchet(_Entity);
end

