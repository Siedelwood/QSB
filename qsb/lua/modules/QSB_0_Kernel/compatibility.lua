
---
-- Die Kompatibilitätsfunktionen dienen dazu, dass die alte Schnittstelle der früheren QSB möglichst abgedeckt wird.
-- <b>Hinweis</b>: Diese Funktionen sind derzeit nur in der qsb_comp.lua bzw qsb_comp.luac enthalten.
--
-- @within Modulbeschreibung
-- @set sort=true
-- @author Jelumar
--


---
-- Registriert eine Funktion, die nach dem laden ausgeführt wird.
--
-- <b>Alias</b>: AddOnSaveGameLoadedAction
--
-- @param[type=function] _Function Funktion, die ausgeführt werden soll
-- @within QSB-Kern
--
-- @usage
-- SaveGame = function()
--     API.Note("foo")
-- end
-- API.AddSaveGameAction(SaveGame)
--
function API.AddSaveGameAction(_Function)
    API.AddScriptEventListener(QSB.ScriptEvents.SaveGameLoaded, _Function)
end
AddOnSaveGameLoadedAction = API.AddSaveGameAction

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Tables können
-- nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
-- Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv.
-- 
-- <b>QSB:</b> table.copy(_Source, _Dest)
-- <b>Alias:</b> CopyTableRecursive
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest   (optional) Zieltabelle
-- @return[type=table] Kopie der Tabelle
-- @within QSB-Kern
--
-- @usage
-- Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    return table.copy(_Source, _Dest)
end
CopyTableRecursive = API.InstanceTable

---
-- Sucht in einer eindimensionalen Table nach einem Wert. Das erste Auftreten des Suchwerts wird als Erfolg gewertet. Es können praktisch alle Lua-Werte gesucht werden.
-- 
-- <b>QSB:</b> table.contains(_Data, _Table)
-- <b>Alias:</b> Inside
--
-- @param             _Data Gesuchter Eintrag (multible Datentypen)
-- @param[type=table] _Table Tabelle, die durchquert wird
-- @return[type=boolean] Wert gefunden
-- @within QSB-Kern
--
-- @usage
-- Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    return table.contains(_Data, _Table)
end
Inside = API.TraverseTable

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
--
-- <b>QSB:</b> API.CreateEntityName(_EntityID)
-- <b>Alias:</b> GiveEntityName
--
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within QSB-Kern
--
-- @usage
-- Skriptname = API.EnsureScriptName(_EntityID)
--
function API.EnsureScriptName(_EntityID)
    return API.CreateEntityName(_EntityID)
end
GiveEntityName = API.EnsureScriptName

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within QSB-Kern
--
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt)
    API.LookAt(_entityToLookAt, _entity)
end

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- <b>QSB:</b> API.GetPosition(_Entity)
-- <p><b>Alias:</b> GetPosition</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within QSB-Kern
--
-- @usage
-- local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    return API.GetPosition(_Entity)
end
GetPosition = API.LocateEntity

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus. Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- Hinweis: Einmal gestartet, kann wait nicht beendet werden.
--
-- <b>QSB:</b> API.StartRealTimeDelay(_Waittime, _Function, ...)
--
-- @param[type=number]   _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] Vergangene reale Zeit
-- @within QSB-Kern
--
function API.RealTimeWait(_Waittime, _Action, ...)
    API.StartRealTimeDelay(_Waittime, _Action, ...)
end

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
-- History Edition zu umgehen.
--
-- <p><b>Alias:</b> Round</p>
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within QSB-Kern
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        local Overhead = nil;
        if Value:len() > e + _DecimalDigits then
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value)
end

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- <b>QSB:</b> API.IsValidPosition(_Pos)
-- <p><b>Alias:</b> IsValidPosition</p>
--
-- @param[type=table] _Pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within QSB-Kern
--
function API.ValidatePosition(_Pos)
    return API.IsValidPosition(_Pos)
end
IsValidPosition = API.ValidatePosition

---
-- Erzeugt einen neuen Event-Job.
--
-- <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
-- können ResumeJob und YieldJob auf den Job angewendet werden.
--
-- <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!
--
-- <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
-- Kopie angeleigt um Speicherprobleme zu verhindern. Es handelt sich also um
-- eine neue Table und keine Referenz!
--
-- <b>QSB:</b> API.StartJobByEventType (_EventType, _Function, ...)
--
-- @param[type=number]   _EventType Event-Typ
-- @param                _Function  Funktion (Funktionsreferenz oder String)
-- @param ...            Optionale Argumente des Job
-- @return[type=number] ID des Jobs
-- @within QSB-Kern
--
function API.StartEventJob(_EventType, _Function, ...)
    return API.StartJobByEventType (_EventType, _Function, ...)
end
