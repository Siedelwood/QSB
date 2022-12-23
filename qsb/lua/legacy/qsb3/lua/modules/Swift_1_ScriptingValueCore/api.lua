--[[
Swift_1_ScriptingValueCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Das Modul stellt grundlegende Funktionen zur Manipulation von Scripting
-- Values bereit.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Konstanten aller bekannten Index von Scripting Values.
--
-- @field Destination   XY-Koordinate Bewegungsziel
-- @field Health        Gesundheit
-- @field Player        Besitzer
-- @field Size          Skalierungsfaktor
-- @field Visible       Sichtbar
-- @within Konstanten
QSB.ScriptingValue = {}

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within Anwenderfunktionen
--
-- @usage
-- local PlayerID = API.GetInteger("HansWurst", QSB.ScriptingValue.Player);
--
function API.GetInteger(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    return Logic.GetEntityScriptingValue(ID, _SV);
end

---
-- Gibt den Wert auf dem übergebenen Index für das Entity zurück.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @return[type=number] Ermittelter Wert
-- @within Anwenderfunktionen
--
-- @usage
-- local Size = API.GetFloat("HansWurst", QSB.ScriptingValue.Size);
--
function API.GetFloat(_Entity, _SV)
    local ID = GetID(_Entity);
    if not IsExisting(ID) then
        return;
    end
    local Value = Logic.GetEntityScriptingValue(ID, _SV);
    return API.ConvertIntegerToFloat(Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
-- 
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetInteger("HansWurst", QSB.ScriptingValue.Player, 2);
--
function API.SetInteger(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, _Value);
end

---
-- Setzt den Wert auf dem übergebenen Index für das Entity.
--
-- @param[type=number] _Entity Entity
-- @param[type=number] _SV     Typ der Scripting Value
-- @param[type=number] _Value  Zu setzender Wert
-- @within Anwenderfunktionen
--
-- @usage
-- API.SetFloat("HansWurst", QSB.ScriptingValue.Size, 1.5);
--
function API.SetFloat(_Entity, _SV, _Value)
    local ID = GetID(_Entity);
    if GUI or not IsExisting(ID) then
        return;
    end
    Logic.SetEntityScriptingValue(ID, _SV, API.ConvertFloatToInteger(_Value));
end

---
-- Konvertirert den Wert in eine Ganzzahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within Anwenderfunktionen
--
-- @usage
-- local Converted = API.ConvertIntegerToFloat(Value)
--
function API.ConvertIntegerToFloat(_Value)
    return ModuleScriptingValue.Shared:ScriptingValueIntegerToFloat(_Value);
end

---
-- Konvertirert den Wert in eine Gleitkommazahl.
--
-- @param[type=number] _Value Gleitkommazahl
-- @return[type=number] Konvertierte Ganzzahl
-- @within Anwenderfunktionen
--
-- @usage
-- local Converted = API.ConvertFloatToInteger(Value)
--
function API.ConvertFloatToInteger(_Value)
    return ModuleScriptingValue.Shared:ScriptingValueFloatToInteger(_Value);
end

---
-- Gibt den Größenfaktor des Entity zurück.
--
-- Der Faktor gibt an, um wie viel die Größe des Entity verändert wurde, im
-- Vergleich zur normalen Größe. Faktor 1 entspricht der normalen Größe.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=number] Größenfaktor des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityScale(_Entity)
    if not IsExisting(_Entity) then
        error("API.EntityGetScale: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    return API.GetFloat(_Entity, QSB.ScriptingValue.Size);
end

---
-- Setzt die Größe des Entity. Wenn es sich um einen Siedler handelt, wird
-- versucht einen neuen Speed Factor zu setzen.
--
-- @param              _Entity Entity (Scriptname oder ID)
-- @param[type=number] _Scale Neuer Größenfaktor
-- @within Anwenderfunktionen
--
function API.SetEntityScale(_Entity, _Scale)
    if GUI then
        return;
    end
    if not IsExisting(_Entity) then
        error("API.SetEntityScale: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_Scale) ~= "number" or _Scale <= 0 then
        error("API.SetEntityScale: _Scale (" ..tostring(_Scale).. ") must be a number above zero!");
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        API.SetFloat(EntityID, QSB.ScriptingValue.Size, _Scale);
        if Logic.IsSettler(EntityID) == 1 then
            Logic.SetSpeedFactor(EntityID, _Scale);
        end
    end
end

---
-- Gibt den Besitzer des Entity zurück.
--
-- @param[type=string] _Entity Scriptname des Entity
-- @return[type=number] Besitzer des Entity
-- @within Anwenderfunktionen
--
function API.GetEntityPlayer(_Entity)
    if not IsExisting(_Entity) then
        error("API.GetEntityPlayer: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return 0;
    end
    return API.GetInteger(_Entity, QSB.ScriptingValue.Player);
end

---
-- Setzt den Besitzer des Entity.
--
-- @param               _Entity  Entity (Scriptname oder ID)
-- @param[type=number] _PlayerID ID des Besitzers
-- @return[type=number] Neue Entity ID
-- @within Anwenderfunktionen
--
function API.SetEntityPlayer(_Entity, _PlayerID)
    if GUI then
        return;
    end
    if not IsExisting(_Entity) then
        error("API.SetEntityPlayer: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    if type(_PlayerID) ~= "number" or _PlayerID < 0 or _PlayerID > 8 then
        error("API.SetEntityPlayer: _PlayerID (" ..tostring(_PlayerID).. ") must be a number between 0 and 8!");
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        if API.IsEntityInAtLeastOneCategory (
            EntityID,
            EntityCategories.Leader,
            EntityCategories.CattlePasture,
            EntityCategories.SheepPasture
        ) then
            EntityID = Logic.ChangeSettlerPlayerID(EntityID, _PlayerID);
        else
            API.SetInteger(EntityID, QSB.ScriptingValue.Player, _PlayerID);
        end
    end
    return EntityID;
end

---
-- Gibt zurück, ob das Entity sichtbar ist.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist sichtbar
-- @within Anwenderfunktionen
--
function API.IsEntityVisible(_Entity)
    if not IsExisting(_Entity) then
        error("API.IsEntityVisible: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return false;
    end
    return API.GetInteger(_Entity, QSB.ScriptingValue.Visible) == 801280;
end

---
-- Ändert die Sichtbarkeit des Entity.
--
-- @param               _Entity   Entity (Scriptname oder ID)
-- @param[type=boolean] _Visible (Optional) Sichtbarkeit ändern
-- @within Anwenderfunktionen
--
function API.SetEntityVisible(_Entity, _Visible)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID == 0 then
        error("API.SetEntityVisible: _Entity (" ..tostring(_Entity).. ") does not exist!");
        return;
    end
    Logic.SetVisible(EntityID, _Visible == true);
end

---
-- Gibt zurück, ob eine NPC-Interaktion mit dem Siedler möglich ist.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=boolean] Ist NPC
-- @within Anwenderfunktionen
--
function API.IsEntityActiveNpc(_Entity)
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return API.GetInteger(EntityID, 6) > 0;
    end
    error("API.IsEntityActiveNpc: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return false;
end

---
-- Gibt das Bewegungsziel des Entity zurück.
--
-- @param _Entity Entity (Scriptname oder ID)
-- @return[type=table] Positionstabelle
-- @within Anwenderfunktionen
--
function API.GetEntityMovementTarget(_Entity)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        return {
            X= API.GetFloat(EntityID, QSB.ScriptingValue.Destination.X),
            Y= API.GetFloat(EntityID, QSB.ScriptingValue.Destination.Y),
            Z= 0
        };
    end
    error("API.GetEntityMovementTarget: _Entity (" ..tostring(_Entity).. ") does not exist!");
    return {X= 0, Y= 0, Z= 0};
end

-- Override

API.ChangeEntityHealth = function(_Entity, _Health, _Relative)
    if GUI then
        return;
    end
    local EntityID = GetID(_Entity);
    if EntityID > 0 then
        local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
        if type(_Health) ~= "number" or _Health < 0 then
            error("API.ChangeEntityHealth: _Health " ..tostring(_Health).. "must be 0 or greater!");
            return;
        end
        _Health = (_Health > MaxHealth and MaxHealth) or _Health;
        if Logic.IsLeader(EntityID) == 1 then
            for k, v in pairs(API.GetGroupSoldiers(EntityID)) do
                API.ChangeEntityHealth(v, _Health, _Relative);
            end
        else
            local OldHealth = Logic.GetEntityHealth(EntityID);
            local NewHealth = _Health;
            if _Relative then
                _Health = (_Health < 0 and 0) or _Health;
                _Health = (_Health > 100 and 100) or _Health;
                NewHealth = math.ceil((MaxHealth) * (_Health/100));
            end
            if NewHealth <= 0 then
                Logic.HurtEntity(EntityID, OldHealth);
            else
                API.SetInteger(EntityID, QSB.ScriptingValue.Health, NewHealth);
            end
        end
        return;
    end
    error("API.ChangeEntityHealth: _Entity (" ..tostring(_Entity).. ") does not exist!");
end
SetHealth = API.ChangeEntityHealth;

