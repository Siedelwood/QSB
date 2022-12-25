--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Erweitert die Möglichkeiten für die interaktiven Objekte.
--
-- <b>Befehle:</b><br>
-- <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
-- der Debug Mode aktiviert ist.</i><br>
-- <table border="1">
-- <tr>
-- <td><b>Befehl</b></td>
-- <td><b>Parameter</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>enableobject</td>
-- <td>ScriptName</td>
-- <td>Aktiviert das interaktive Objekt.</td>
-- </tr>
-- <tr>
-- <td>disableobject</td>
-- <td>ScriptName</td>
-- <td>Deaktiviert das interactive Objekt</td>
-- </tr>
-- <tr>
-- <td>initobject</td>
-- <td>ScriptName</td>
-- <td>Initialisiert ein interaktives Objekt grundlegend, sodass es benutzt werden kann.</td>
-- </tr>
-- </table>
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
-- @field ObjectClicked     Der Spieler klickt auf den Button des IO (Parameter: ScriptName, KnightID, PlayerID)
-- @field ObjectInteraction Es wird mit einem interaktiven Objekt interagiert (Parameter: ScriptName, KnightID, PlayerID)
-- @field ObjectDelete      Eine Interaktion wird von einem Objekt entfernt (Parameter: ScriptName)
-- @field ObjectReset       Der Zustand eines interaktiven Objekt wird zurückgesetzt (Parameter: ScriptName)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erzeugt ein einfaches interaktives Objekt.
--
-- Dabei können alle Entities als interaktive Objekte behandelt werden, nicht
-- nur die, die eigentlich dafür vorgesehen sind.
--
-- Die Parameter des interaktiven Objektes werden durch seine Beschreibung
-- festgelegt. Die Beschreibung ist eine Table, die bestimmte Werte für das
-- Objekt beinhaltet. Dabei müssen nicht immer alle Werte angegeben werden.
--
-- <b>Achtung</b>: Wird eine Straße über einem Objekt platziert, während die
-- Kosten bereits bezahlt und auf dem Weg sind, läuft die Aktivierung ins Leere.
-- Zwar wird das Objekt zurückgesetzt, doch die bereits geschickten Waren sind
-- dann futsch.
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
-- <td>Name</td>
-- <td>string</td>
-- <td>Der Skriptname des Entity, das zum interaktiven Objekt wird.</td>
-- <td>nein</td>
-- </tr>
-- <tr>
-- <td>Texture</td>
-- <td>table</td>
-- <td>Angezeigtes Icon des Buttons. Die Icons können auf die Icons des Spiels
-- oder auf eigene Icons zugreifen.
-- <br>- Spiel-Icons: {x, y, Spielversion}
-- <br>- Benutzerdefinierte Icons: {x, y, Dateinamenpräfix}</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string</td>
-- <td>Angezeigter Titel des Objekt</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>Angezeigte Beschreibung des Objekt</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>number</td>
-- <td>Die minimale Entfernung zum Objekt, die ein Held benötigt um das
-- objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Player</td>
-- <td>number|table</td>
-- <td>Spieler, der/die das Objekt aktivieren kann/können.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>number</td>
-- <td>Die Zeit, die ein Held benötigt, um das Objekt zu aktivieren.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Replacement</td>
-- <td>number</td>
-- <td>Entity, mit der das Objekt nach Aktivierung ersetzt wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Costs</td>
-- <td></td>
-- <td>Eine Table mit dem Typ und der Menge der Kosten. (Format: {Typ, Menge, Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Reward</td>
-- <td>table</td>
-- <td>Der Warentyp und die Menge der gefundenen Waren im Objekt. (Format: {Typ, Menge})</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>State</td>
-- <td>number</td>
-- <td>Bestimmt, wie sich der Button des interaktiven Objektes verhält.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>function</td>
-- <td>Eine zusätzliche Aktivierungsbedinung als Funktion.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>ConditionInfo</td>
-- <td>string</td>
-- <td>Nachricht, die angezeigt wird, wenn die Bedinung nicht erfüllt ist.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>Eine Funktion, die nach der Aktivierung aufgerufen wird.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RewardResourceCartType</td>
-- <td>number</td>
-- <td>Erlaubt, einen anderern Karren für Rohstoffkosten einstellen.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>RewardGoldCartType</td>
-- <td>number</td>
-- <td>Erlaubt, einen anderern Karren für Goldkosten einstellen.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>CostResourceCartType</td>
-- <td>number</td>
-- <td>Erlaubt, einen anderern Karren für Rohstoffbelohnungen einstellen.</td>
-- <td>ja</td>
-- </tr>
-- <tr>
-- <td>CostGoldCartType</td>
-- <td>number</td>
-- <td>Erlaubt, einen anderern Karren für Goldbelohnung einstellen.</td>
-- <td>ja</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Description Beschreibung
-- @within Anwenderfunktionen
-- @see API.ResetObject
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
--
-- @usage
-- API.SetupObject {
--     Name     = "hut",
--     Distance = 1500,
--     Reward   = {Goods.G_Gold, 1000},
-- };
--
function API.SetupObject(_Description)
    if GUI then
        return;
    end
    return ModuleObjectInteraction.Global:CreateObject(_Description);
end
API.CreateObject = API.SetupObject;

---
-- Zerstört die Interation mit dem Objekt.
--
-- <b>Hinweis</b>: Das Entity selbst wird nicht zerstört.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @see API.SetupObject
-- @see API.ResetObject
-- @usage
-- API.DisposeObject("MyObject");
--
function API.DisposeObject(_ScriptName)
    if GUI or not IO[_ScriptName] then
        return;
    end
    ModuleObjectInteraction.Global:DestroyObject(_ScriptName);
end

---
-- Setzt das interaktive Objekt zurück. Dadurch verhält es sich, wie vor der
-- Aktivierung durch den Spieler.
--
-- <b>Hinweis</b>: Das Objekt muss wieder per Skript aktiviert werden, damit es
-- im Spiel ausgelöst werden.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @within Anwenderfunktionen
-- @see API.SetupObject
-- @see API.InteractiveObjectActivate
-- @see API.InteractiveObjectDeactivate
-- @usage
-- API.ResetObject("MyObject");
--
function API.ResetObject(_ScriptName)
    if GUI or not IO[_ScriptName] then
        return;
    end
    ModuleObjectInteraction.Global:ResetObject(_ScriptName);
    API.InteractiveObjectDeactivate(_ScriptName);
end

---
-- Aktiviert ein Interaktives Objekt, sodass es von den Spielern
-- aktiviert werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler aktiviert werden.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- @param[type=string] _ScriptName Skriptname des Objektes
-- @param[type=number] _State      State des Objektes
-- @param[type=number] ...         (Optional) Liste mit PlayerIDs
-- @within Anwenderfunktionen
--
function API.InteractiveObjectActivate(_ScriptName, _State, ...)
    arg = arg or {1};
    if GUI then
        return;
    end
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].Slave or _ScriptName);
        if IO[_ScriptName].Slave then
            IO_SlaveState[SlaveName] = 1;
            Logic.ExecuteInLuaLocalState(string.format(
                [[IO_SlaveState["%s"] = 1]],
                SlaveName
            ));
        end
        ModuleObjectInteraction.Global:SetObjectState(SlaveName, _State, unpack(arg));
        IO[_ScriptName].IsActive = true;
        Logic.ExecuteInLuaLocalState(string.format(
            [[IO["%s"].IsActive = true]],
            _ScriptName
        ));
    else
        ModuleObjectInteraction.Global:SetObjectState(_ScriptName, _State, unpack(arg));
    end
end
InteractiveObjectActivate = API.InteractiveObjectActivate;

---
-- Deaktiviert ein interaktives Objekt, sodass es nicht mehr von den Spielern
-- benutzt werden kann.
--
-- Optional kann das Objekt nur für einen bestimmten Spieler deaktiviert werden.
--
-- @param[type=string] _ScriptName Scriptname des Objektes
-- @param[type=number] ...         (Optional) Liste mit PlayerIDs
-- @within Anwenderfunktionen
--
function API.InteractiveObjectDeactivate(_ScriptName, ...)
    arg = arg or {1};
    if GUI then
        return;
    end
    if IO[_ScriptName] then
        local SlaveName = (IO[_ScriptName].Slave or _ScriptName);
        if IO[_ScriptName].Slave then
            IO_SlaveState[SlaveName] = 0;
            Logic.ExecuteInLuaLocalState(string.format(
                [[IO_SlaveState["%s"] = 0]],
                SlaveName
            ));
        end
        ModuleObjectInteraction.Global:SetObjectState(SlaveName, 2, unpack(arg));
        IO[_ScriptName].IsActive = false;
        Logic.ExecuteInLuaLocalState(string.format(
            [[IO["%s"].IsActive = false]],
            _ScriptName
        ));
    else
        ModuleObjectInteraction.Global:SetObjectState(_ScriptName, 2, unpack(arg));
    end
end
InteractiveObjectDeactivate = API.InteractiveObjectDeactivate;

---
-- Erzeugt eine Beschriftung für Custom Objects.
--
-- Im Questfenster werden die Namen von Custom Objects als ungesetzt angezeigt.
-- Mit dieser Funktion kann ein Name angelegt werden.
--
-- @param[type=string] _Key  Typname des Entity
-- @param              _Text Text der Beschriftung
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Einfache Beschriftung
-- API.InteractiveObjectSetQuestName("D_X_ChestOpenEmpty", "Leere Schatztruhe");
--
-- @usage
-- -- Beispiel #1: Multilinguale Beschriftung
-- API.InteractiveObjectSetQuestName("D_X_ChestClosed", {de = "Schatztruhe", en = "Treasure"});
--
function API.InteractiveObjectSetQuestName(_Key, _Text)
    if GUI then
        return;
    end
    IO_UserDefindedNames[_Key] = _Text;
    Logic.ExecuteInLuaLocalState(string.format(
        [[IO_UserDefindedNames["%s"] = %s]],
        _Key,
        table.tostring(IO_UserDefindedNames)
    ));
end

