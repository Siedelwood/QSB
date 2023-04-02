-- -------------------------------------------------------------------------- --

---
-- Die Optionen für selektierte Einheiten können individualisiert werden.
--
-- Es wird ein Button zum Entlassen von Einheiten hinzugefügt.
-- 
-- <table border="1">
-- <tr><td><b>Einheitentyp</b></td><td><b>Vorsteinstellung</b></td></tr>
-- <tr><td>Soldaten</td><td>aktiv</td></tr>
-- <tr><td>Kriegsmaschinen</td><td>aktiv</td></tr>
-- <tr><td>Diebe</td><td>deaktiviert</td></tr>
-- </table>
--
-- Trebuchets haben nun das gleiche Menü, wie die anderen Kriegsmaschinen. Sie
-- können jedoch nicht abgebaut werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- </ul>
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
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.DisableReleaseThieves(%s)]],
            tostring(_Flag)
        ));
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
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.DisableReleaseSiegeEngines(%s)]],
            tostring(_Flag)
        ));
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
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.DisableReleaseSoldiers(%s)]],
            tostring(_Flag)
        ));
        return;
    end
    ModuleSelection.Local.MilitaryRelease = not _Flag;
end

---
-- Prüft ob das Entity selektiert ist.
--
-- @param _Entity                Entity das selektiert sein soll (Skriptname oder ID)
-- @param[type=number] _PlayerID ID des selektierenden Spielers
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

