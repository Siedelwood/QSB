
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
-- @within Anwenderfunktionen
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
-- <b>Alias:</b> CopyTableRecursive
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest   (optional) Zieltabelle
-- @return[type=table] Kopie der Tabelle
-- @within Anwenderfunktionen
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
-- <b>Alias:</b> Inside
--
-- @param             _Data Gesuchter Eintrag (multible Datentypen)
-- @param[type=table] _Table Tabelle, die durchquert wird
-- @return[type=booelan] Wert gefunden
-- @within Anwenderfunktionen
--
-- @usage
-- Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    return table.contains(_Data, _Table)
end
Inside = API.TraverseTable;
