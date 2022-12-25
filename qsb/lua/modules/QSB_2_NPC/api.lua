--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Interaktion mit NPC-Charakteren.
--
-- Ein NPC ist ein Charakter, der durch den Helden eines Spielers angesprochen
-- werden kann. Auf das Ansprechen kann eine beliebige Aktion folgen. Mittels
-- einer Bedingung kann festgelegt werden, wer mit dem NPC sprechen kann und
-- unter welchen Umständen es nicht möglich ist.
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
-- @field NpcInteraction  (Parameter: NpcEntityID, HeroEntityID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erstellt einen neuen NPC für den angegebenen Siedler.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
-- </tr>
-- <tr>
-- <td>Type</td>
-- <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
-- vorhanden, den Anzeigemodus des NPC Icon.</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Player</td>
-- <td>(number|table) Spieler, der/die mit dem NPC sprechen kann/können.</td>
-- </tr>
-- <tr>
-- <td>WrongPlayerAction</td>
-- <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroAction</td>
-- <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Data Definition des NPC
-- @return[type=table] NPC Table
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Einfachen NPC erstellen
-- MyNpc = API.NpcCompose {
--     Name     = "HansWurst",
--     Callback = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
-- @usage
-- -- Beispiel #2: NPC mit Bedingung erstellen
-- MyNpc = API.NpcCompose {
--     Name      = "HansWurst",
--     Condition = function(_Data)
--         local NpcID = GetID(_Data.Name);
--         -- prüfe irgend was
--         return MyConditon == true;
--     end
--     Callback  = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
-- @usage
-- -- Beispiel #3: NPC auf Spieler beschränken
-- MyNpc = API.NpcCompose {
--     Name              = "HansWurst",
--     Player            = {1, 2},
--     WrongPlayerAction = function(_Data)
--         API.Note("Ich rede nicht mit Euch!");
--     end,
--     Callback          = function(_Data)
--         local HeroID = QSB.LastHeroEntityID;
--         local NpcID = GetID(_Data.Name);
--         -- mach was tolles
--     end
-- }
--
function API.NpcCompose(_Data)
    if GUI or not type(_Data) == "table" or not _Data.Name then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcCompose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    local Npc = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    if Npc ~= nil and Npc.Active then
        error("API.NpcCompose: '" .._Data.Name.. "' is already composed as NPC!");
        return;
    end
    if _Data.Type and (not type(_Data.Type) == "number" or (_Data.Type < 1 or _Data.Type > 4)) then
        error("API.NpcCompose: Type must be a value between 1 and 4!");
        return;
    end
    return ModuleNpcInteraction.Global:CreateNpc(_Data);
end

---
-- Entfernt den NPC komplett vom Entity. Das Entity bleibt dabei erhalten.
--
-- @param[type=table] _Data NPC Table
-- @within Anwenderfunktionen
-- @usage
-- API.NpcDispose(MyNpc);
--
function API.NpcDispose(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) ~= nil then
        error("API.NpcDispose: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleNpcInteraction.Global:DestroyNpc(_Data);
end

---
-- Aktualisiert die Daten des NPC.
--
-- Mögliche Einstellungen für den NPC:
-- <table border="1">
-- <tr>
-- <th><b>Eigenschaft</b></th>
-- <th><b>Beschreibung</b></th>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
-- </tr>
-- <tr>
-- <td>Type</td>
-- <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
-- vorhanden, den Anzeigemodus des NPC Icon.</td>
-- </tr>
-- <tr>
-- <td>Condition</td>
-- <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Player</td>
-- <td>(number) Spieler, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongPlayerAction</td>
-- <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Hero</td>
-- <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
-- </tr>
-- <tr>
-- <td>WrongHeroAction</td>
-- <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
-- </tr>
-- <tr>
-- <td>Active</td>
-- <td>(boolean) Steuert, ob der NPC aktiv ist.</td>
-- </tr>
-- </table>
--
-- @param[type=table] _Data NPC Table
-- @within Anwenderfunktionen
-- @usage
-- -- Einen NPC wieder aktivieren
-- MyNpc.Active = true;
-- MyNpc.TalkedTo = 0;
-- -- Die Aktion ändern
-- MyNpc.Callback = function(_Data)
--     -- mach was hier
-- end;
-- API.NpcUpdate(MyNpc);
--
function API.NpcUpdate(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) == nil then
        error("API.NpcUpdate: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    ModuleNpcInteraction.Global:UpdateNpc(_Data);
end

---
-- Prüft, ob der NPC gerade aktiv ist.
--
-- @param[type=table] _Data NPC Table
-- @return[type=boolean] NPC ist aktiv
-- @within Anwenderfunktionen
-- @usage
-- if API.NpcIsActive(MyNpc) then
--
function API.NpcIsActive(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    local NPC = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    if NPC == nil then
        error("API.NpcIsActive: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    return NPC.Active == true and API.IsEntityActiveNpc(_Data.Name);
end

---
-- Prüft, ob ein NPC schon gesprochen hat und optional auch mit wem.
--
-- @param[type=table]  _Data     NPC Table
-- @param[type=string] _Hero     (Optional) Skriptname des Helden
-- @param[type=number] _PlayerID (Optional) Spieler ID
-- @within Anwenderfunktionen
-- 
-- @usage
-- -- Beispiel #1: Wurde mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc) then
-- 
-- @usage
-- -- Beispiel #2: Spieler hat mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc, nil, 1) then
-- 
-- @usage
-- -- Beispiel #3: Held des Spielers hat mit NPC gesprochen
-- if API.NpcTalkedTo(MyNpc, "Marcus", 1) then
--
function API.NpcTalkedTo(_Data, _Hero, _PlayerID)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.NpcTalkedTo: '" .._Data.Name.. "' NPC does not exist!");
        return;
    end
    if ModuleNpcInteraction.Global:GetNpc(_Data.Name) == nil then
        error("API.NpcTalkedTo: '" .._Data.Name.. "' NPC must first be composed!");
        return;
    end

    local NPC = ModuleNpcInteraction.Global:GetNpc(_Data.Name);
    local TalkedTo = NPC.TalkedTo ~= nil and NPC.TalkedTo ~= 0;
    if _Hero and TalkedTo then
        TalkedTo = NPC.TalkedTo == GetID(_Hero);
    end
    if _PlayerID and TalkedTo then
        TalkedTo = Logic.EntityGetPlayer(NPC.TalkedTo) == _PlayerID;
    end
    return TalkedTo;
end

