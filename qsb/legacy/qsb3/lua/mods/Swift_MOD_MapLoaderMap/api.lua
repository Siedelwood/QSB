--[[
Swift_MOD_CampaignMap/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- CURRENTLY, THIS WON'T JUST WORK!
--
-- Stellt Hilfsfunktionen bereit, um Maps zu verwalten, welche mit dem
-- Maploader gestartet wurden.
--
-- Es werden außerdem die Fähigkeiten der bösen Helden Crimsin Sabatt und
-- des Roten Prinzen wiederhergestellt.
--
-- Dieses Bundle sollte zusammen mit dem Maploader verwendet werden!
--
-- @see ExternalMapLoader
-- @set sort=true
--

---
-- Fügt eine Profilvariable zum Laden hinzu.
--
-- @param[type=string] _Key Name der Variable
-- @within Anwenderfunktionen
--
function API.Map_AddValueToLoad(_Key)
	if not GUI then
		Logic.ExecuteInLuaLocalState(string.format([[API.Map_AddValueToLoad("%s")]], tostring(_Key)));
		return;
	end
	table.insert(QSB.CampaignMapValues, _Key);
end

---
-- Läd die zuvor vorgemerkten Werte aus dem Profil.
--
-- Die geladenen Werte werden in gvMission.Campaign gespeichert.
--
-- @within Anwenderfunktionen
--
function API.Map_LoadValues()
	if not GUI then
		Logic.ExecuteInLuaLocalState("API.Map_LoadValues()");
		return;
	end
	local MapName = Framework.GetCurrentMapName();
	GUI.SendScriptCommand("gvMission.Campaign = {}");
	for k, v in pairs(QSB.CampaignMapValues) do
		local Value = Profile.GetString(MapName, v);
		GUI.SendScriptCommand(string.format([[gvMission.Campaign.%s = "%s"]], v, Value));
	end
end

---
-- Ersetzt den Helden mit dem zuvor im Maploader ausgewählten Helden.
--
-- Das Portrait und der Select-Button werden automatisch ausgetauscht. Falls
-- vorhanden, wird Mission_MapReady aufgerufen.
--
-- @within Anwenderfunktionen
--
function API.Map_ReplacePrimaryKnight()
	if not GUI then
		Logic.ExecuteInLuaLocalState("API.Map_ReplacePrimaryKnight()");
		return;
	end
	StartSimpleJobEx(function()
		local MapName = Framework.GetCurrentMapName();
		local PlayerID = GUI.GetPlayerID();
		local KnightTypeName = Profile.GetString(MapName, "SelectedKnight") or "U_KnightChivalry";
		if Logic.GetKnightID(PlayerID) ~= 0 then
			GUI.SendScriptCommand(string.format(
                [[
                    ReplaceEntity(Logic.GetKnightID(%d), Entities["%s"])
                    API.InterfaceSetPlayerPortrait(%d)
                    Logic.ExecuteInLuaLocalState("LocalSetKnightPicture()")
                    Logic.ExecuteInLuaLocalState("if Mission_LocalMapReady then Mission_LocalMapReady() end")
                    if Mission_MapReady then
                        Mission_MapReady()
                    end
                ]],
                PlayerID,
                KnightTypeName,
                PlayerID
            ));
			return true;
		end
	end);
end

---
-- Markiert die Map im Profil des Spielers als abgeschlossen.
--
-- Diese Funktion sollte aufgerufen werden, wenn der Spieler die Siegmeldung
-- erhält.
--
-- @within Anwenderfunktionen
--
function API.Map_SetFinished()
	if not GUI then
		Logic.ExecuteInLuaLocalState("API.Map_SetFinished()");
		return;
	end
	local MapName = Framework.GetCurrentMapName();
	local MapCode = ModMapLoaderMap.Local.MapData.MapCode or "";
	API.Map_SaveValue("SuccessfullyFinished", MapCode);
end

---
-- Speichert einen Wert im Profil des Spielers.
--
-- @param[type=string] _Key   Name der Variable
-- @param[type=string] _Value Zu speichernder Wert
-- @within Anwenderfunktionen
--
function API.Map_SaveValue(_Key, _Value)
	if not GUI then
		Logic.ExecuteInLuaLocalState(string.format([[API.Map_SaveValue("%s", "%s")]], tostring(_Key), tostring(_Value)));
		return;
	end
	local MapName = Framework.GetCurrentMapName();
	Profile.SetString(MapName, _Key, _Value);
end

---
-- Ändert die Texturposition der Heldenfähigkeit des bösen Helden.
--
-- Mögliche Helden sind:
-- <ul>
-- <li>CrimsonSabatt</li>
-- <li>RedPrince</li>
-- </ul>
--
-- @param[type=string] _Key   Name der Variable
-- @param[type=string] _Value Zu speichernder Wert
-- @within Anwenderfunktionen
-- @usage API.Map_SetHeroAbilityTextureSource("CrimsonSabatt", {1, 1, "myicons"});
--
function API.Map_SetHeroAbilityTextureSource(_Hero, _Data)
	if not GUI then
		Logic.ExecuteInLuaLocalState(string.format(
            [[API.Map_SetHeroAbilityTextureSource("%s", %s)]],
            tostring(_Hero),
            API.ConvertTableToString(_Data)
        ));
		return;
	end
    if ModMapLoaderMap.Local[_Hero] then
        ModMapLoaderMap.Local[_Hero].AbilityIcon = _Data;
    end
end

