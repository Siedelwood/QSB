--[[
Swift_3_WeatherManipulation/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleWeatherManipulation = {
    Properties = {
        Name = "ModuleWeatherManipulation",
    },

    Global = {
        EventQueue = {},
        ActiveEvent = nil,
    },
    Local = {
        ActiveEvent = nil,
    },
}

-- Global ------------------------------------------------------------------- --

function ModuleWeatherManipulation.Global:OnGameStart()
    API.StartHiResJob(function()
        ModuleWeatherManipulation.Global:EventController();
    end);
end

function ModuleWeatherManipulation.Global:OnEvent(_ID, _Event)
    if _ID == QSB.ScriptEvents.SaveGameLoaded then
        if self:IsEventActive() then
            Logic.ExecuteInLuaLocalState([[
                Display.StopAllEnvironmentSettingsSequences()
                ModuleWeatherManipulation.Local:DisplayEvent(]] ..self:GetEventRemainingTime().. [[)
            ]]);
        end
    end
end

function ModuleWeatherManipulation.Global:AddEvent(_Event, _Duration)
    local Event = table.copy(_Event);
    Event.Duration = _Duration;
    table.insert(self.EventQueue, Event);
end

function ModuleWeatherManipulation.Global:PurgeAllEvents()
    if #self.EventQueue > 0 then
        for i= #self.EventQueue, 1 -1 do
            self.EventQueue:remove(i);
        end
    end
end

function ModuleWeatherManipulation.Global:NextEvent()
    if not self:IsEventActive() then
        if #self.EventQueue > 0 then
            self:ActivateEvent();
        end
    end
end

function ModuleWeatherManipulation.Global:ActivateEvent()
    if #self.EventQueue == 0 then
        return;
    end

    local Event = table.remove(self.EventQueue, 1);
    self.ActiveEvent = Event;
    Logic.ExecuteInLuaLocalState([[
        ModuleWeatherManipulation.Local.ActiveEvent = ]] ..table.tostring(Event).. [[
        ModuleWeatherManipulation.Local:DisplayEvent()
    ]]);

    Logic.WeatherEventClearGoodTypesNotGrowing();
    for i= 1, #Event.NotGrowing, 1 do
        Logic.WeatherEventAddGoodTypeNotGrowing(Event.NotGrowing[i]);
    end
    if Event.Rain then
        Logic.WeatherEventSetPrecipitationFalling(true);
        Logic.WeatherEventSetPrecipitationHeaviness(1);
        Logic.WeatherEventSetWaterRegenerationFactor(1);
        if Event.Snow then
            Logic.WeatherEventSetPrecipitationIsSnow(true);
        end
    end
    if Event.Ice then
        Logic.WeatherEventSetWaterFreezes(true);
    end
    if Event.Monsoon then
        Logic.WeatherEventSetShallowWaterFloods(true);
    end
    Logic.WeatherEventSetTemperature(Event.Temperature);
    Logic.ActivateWeatherEvent();
end

function ModuleWeatherManipulation.Global:StopEvent()
    Logic.ExecuteInLuaLocalState("ModuleWeatherManipulation.Local.ActiveEvent = nil");
    self.ActiveEvent = nil;
    Logic.DeactivateWeatherEvent();
end

function ModuleWeatherManipulation.Global:GetEventRemainingTime()
    if not self:IsEventActive() then
        return 0;
    end
    return self.ActiveEvent.Duration;
end

function ModuleWeatherManipulation.Global:IsEventActive()
    return self.ActiveEvent ~= nil;
end

function ModuleWeatherManipulation.Global:EventController()
    if self:IsEventActive() then
        self.ActiveEvent.Duration = self.ActiveEvent.Duration -1;
        if self.ActiveEvent.Loop then
            self.ActiveEvent:Loop();
        end
        
        if self.ActiveEvent.Duration == 0 then
            self:StopEvent();
            self:NextEvent();
        end
    end
end

-- Local -------------------------------------------------------------------- --

function ModuleWeatherManipulation.Local:OnGameStart()
end

function ModuleWeatherManipulation.Local:DisplayEvent(_Duration)
    if self:IsEventActive() then
        local SequenceID = Display.AddEnvironmentSettingsSequence(self.ActiveEvent.GFX);
        Display.PlayEnvironmentSettingsSequence(SequenceID, _Duration or self.ActiveEvent.Duration);
    end
end

function ModuleWeatherManipulation.Local:IsEventActive()
    return self.ActiveEvent ~= nil;
end

-- -------------------------------------------------------------------------- --

WeatherEvent = {
    GFX = "ne_winter_sequence.xml",
    NotGrowing = {},
    Rain = false,
    Snow = false,
    Ice = false,
    Monsoon = false,
    Temperature = 10,
}

---
-- Erstellt ein neues Wetterevent.
--
-- Ein Wetterevent ist standardmäßig eingestellt. Es gibt keinen Niederschlag,
-- und keinen Monsun, alle Güter wachsen, die Temperatur ist 10°C und als
-- GFX wird ne_winter_sequence.xml verwendet.
--
-- Um Werte anzupassen muss auf die Felder in einem neuen Wetterevent
-- zugegriffen werden. Ein Beispiel:
-- <pre>MyEvent.GFX = "as_winter_sequence.xml"</pre>
--
-- Um Güter, die nicht nachwachsen sollen, hinzuzufügen, muss auf das Table
-- NotGrowing zugegriffen werden. Ein Beispiel:
-- <pre>MyEvent.NotGrowing:insert(Goods.G_Grain)</pre>
--
-- Ein einmal erstelltes Event kann immer wieder verwendet werden! Speichere
-- es also in einer globalen Variable.
--
-- Ein Event hat folgende Felder:
-- <table border="1">
-- <tr>
-- <td><b>Feld</b></td>
-- <td><b>Erklärung</b></td>
-- </tr>
-- <tr>
-- <td>GFX</td>
-- <td>String: Die verwendete Display-Animation. Hierbei muss es sich im eine
-- dynamische Display-Animation handeln.</td>
-- </tr>
-- <tr>
-- <td>NotGrowing</td>
-- <td>Table: Liste aller nicht nachwachsender Güter während des Events.</td>
-- </tr>
-- <tr>
-- <td>Rain</td>
-- <td>Boolean: Niederschlag fällt während des Events.</td>
-- </tr>
-- <tr>
-- <td>Snow</td>
-- <td>Boolean: Der Niederschlag fällt als Schnee.</td>
-- </tr>
-- <tr>
-- <td>Ice</td>
-- <td>Boolean: Wasser gefriert während des Events.</td>
-- </tr>
-- <tr>
-- <td>Monsoon</td>
-- <td>Boolean: Monsunwasser ist während des Events aktiv.</td>
-- </tr>
-- <tr>
-- <td>Temperature</td>
-- <td>Number: Die Temperatur während des Events in °C.</td>
-- </tr>
-- </table>
--
-- @within WeatherEvent
-- @local
--
function WeatherEvent:New()
    return table.copy(self);
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleWeatherManipulation);

