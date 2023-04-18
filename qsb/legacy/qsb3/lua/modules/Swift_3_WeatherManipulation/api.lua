--[[
Swift_3_WeatherManipulation/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Dieses Modul ermöglicht das Ändern des Wetters.
--
-- Es können nun relativ einfach Wetterevents und Wetteranimationen kombiniert
-- gestartet werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Erzeugt ein neues Wetterevent und gibt es zurück.
--
-- Ein Event alleine ändert noch nicht das Wetter! Hier wird ein Event
-- definiert, welches an anderer Stelle benutzt werden kann. Das definierte
-- Event kann jedoch in einer Variable gespeichert und immer wieder neu
-- verwendet werden.
--
-- <b>Hinweis</b>: Es handelt sich um eine dynamische Wettersequenz. Dies muss
-- beachtet werden! Eine statische Sequenz wird nicht funktionieren!
--
-- @param[type=string]  _GFX        Verwendetes Display Set
-- @param[type=boolean] _Rain       Niederschlag aktivieren
-- @param[type=boolean] _Snow       Niederschlag ist Schnee
-- @param[type=boolean] _Ice        Wasser gefriert
-- @param[type=boolean] _Monsoon    Blockendes Monsunwasser aktivieren
-- @param[type=number]  _Temp       Temperatur während des Events
-- @param[type=table]   _NotGrowing Liste der nicht nachwachsenden Güter
-- @return[type=table]              Neues Wetterevent
-- @within WeatherEvent
--
-- @see API.WeatherEventRegister
-- @see API.WeatherEventRegisterLoop
--
-- @usage
-- -- Erzeugt ein Winterevent
-- MyEvent = API.WeatherEventCreate(
--     "ne_winter_sequence.xml", false, true, true, false, -15,
--     {Goods.G_Grain, Goods.G_RawFish, Goods.G_Honeycomb}
-- )
--
function API.WeatherEventCreate(_GFX, _Rain, _Snow, _Ice, _Monsoon, _Temp, _NotGrowing)
    if GUI then
        return;
    end
    
    local Event = WeatherEvent:New();
    Event.GFX = _GFX or Event.GFX;
    Event.Rain = _Rain or Event.Rain;
    Event.Snow = _Snow or Event.Snow;
    Event.Ice = _Ice or Event.Ice;
    Event.Monsoon = _Monsoon or Event.Monsoon;
    Event.Temperature = _Temp or Event.Temperature;
    Event.NotGrowing = _NotGrowing or Event.NotGrowing;
    return Event;
end

---
-- Registiert ein Event für eine bestimmte Dauer. Das Event wird auf der
-- "Wartebank" eingereiht.
--
-- <b>Hinweis</b>: Ein wartendes Event wird gestartet, sobald kein anderes
-- Event mehr aktiv ist.
-- 
-- @param[type=table]  _Event     Event-Instanz
-- @param[type=number] _Duration  Name des Events
-- @within WeatherEvent
-- @see API.WeatherEventNext
-- @see API.WeatherEventAbort
-- @see API.WeatherEventRegisterLoop
--
-- @usage
-- API.WeatherEventRegister(MyEvent, 300);
--
function API.WeatherEventRegister(_Event, _Duration)
    if GUI then
        return;
    end
    if type(_Event) ~= "table" or not _Event.GFX then
        error("API.WeatherEventStart: Invalid weather event!");
        return;
    end
    ModuleWeatherManipulation.Global:AddEvent(_Event, _Duration);
end

---
-- Registiert ein Event als Endlosschleife. Das Event wird immer wieder neu
-- starten, kurz bevor es eigentlich endet. Es darf keine anderen Events auf
-- der "Wartebank" geben.
-- @param[type=table]  _Event Event-Instanz
-- @within WeatherEvent
-- @see API.WeatherEventNext
-- @see API.WeatherEventAbort
-- @see API.WeatherEventRegister
--
-- @usage
-- API.WeatherEventRegister(MyEvent);
--
function API.WeatherEventRegisterLoop(_Event)
    if GUI then
        return;
    end
    if type(_Event) ~= "table" or not _Event.GFX then
        error("API.WeatherEventStartLoop: Invalid weather event!");
        return;
    end
    
    _Event.Loop = function(_Data)
        if _Data.Duration <= 36 then
            ModuleWeatherManipulation.Global:AddEvent(_Event, 120);
            ModuleWeatherManipulation.Global:StopEvent();
            ModuleWeatherManipulation.Global:ActivateEvent();
        end
    end
    ModuleWeatherManipulation.Global:AddEvent(_Event, 120);
end

---
-- Startet das nächste Wetterevent auf der "Wartebank". Wenn bereits ein Event
-- aktiv ist, wird dieses gestoppt. Es erfolgt ein Übergang zum nächsten Event,
-- sofern möglich.
--
-- @within WeatherEvent
--
function API.WeatherEventNext()
    ModuleWeatherManipulation.Global:StopEvent();
    ModuleWeatherManipulation.Global:ActivateEvent();
end

---
-- Bricht das aktuelle Event inklusive der Animation sofort ab.
-- @within WeatherEvent
--
function API.WeatherEventAbort()
    if GUI then
        return;
    end
    Logic.ExecuteInLuaLocalState("Display.StopAllEnvironmentSettingsSequences()");
    ModuleWeatherManipulation.Global:StopEvent();
end

---
-- Bricht das aktuelle Event ab und löscht alle eingereihten Events.
--
-- Mit dieser Funktion wird die komplette Warteschlange für Wettervents geleert.
-- Dies betrifft sowohl einzelne Events als auch sich wiederholende Events.
--
-- @within WeatherEvent
--
function API.WeatherEventPurge()
    if GUI then
        return;
    end
    ModuleWeatherManipulation.Global:PurgeAllEvents();
    Logic.ExecuteInLuaLocalState("Display.StopAllEnvironmentSettingsSequences()");
    ModuleWeatherManipulation.Global:StopEvent();
end

