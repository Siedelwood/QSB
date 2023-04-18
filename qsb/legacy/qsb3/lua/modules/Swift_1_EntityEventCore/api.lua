--[[
Swift_1_EntityEventCore/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht das einfache Reagieren auf Ereignisse die Entities betreffen.
--
-- <h5>Entity Created</h5>
-- Das Modul bringt eine eigene Implementierung des Entity Created Event mit
-- sich, da das originale Event des Spiels nicht funktioniert.
--
-- <h5>Diebstahleffekte</h5>
-- Die Effekte von Diebstählen können deaktiviert und mittels Event neu
-- geschrieben werden.
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
-- Events, auf die reagiert werden kann.
--
-- @field BuildingPlaced Ein Gebäude wurde in Auftrag gegeben. (Parameter: EntityID, PlayerID)
-- @field EntitySpawned Ein Entity wurde aus einem Spawner erzeugt. (Parameter: EntityID, PlayerID, SpawnerID)
-- @field SettlerAttracted Ein Siedler kommt in die Siedlung. (Parameter: EntityID, PlayerID)
-- @field EntityDestroyed Ein Entity wurde zerstört. Wird auch durch Spieler ändern ausgelöst! (Parameter: EntityID, PlayerID)
-- @field EntityHurt Ein Entity wurde angegriffen. (Parameter: AttackedEntityID, AttackedPlayerID, AttackingEntityID, AttackingPlayerID)
-- @field EntityKilled Ein Entity wurde getötet. (Parameter: KilledEntityID, KilledPlayerID, KillerEntityID, KillerPlayerID)
-- @field EntityOwnerChanged Ein Entity wechselt den Besitzer. (Parameter: OldIDList, OldPlayer, NewIDList, OldPlayer)
-- @field EntityResourceChanged Resourcen im Entity verändern sich. (Parameter: EntityID, GoodType, OldAmount, NewAmount)
-- @field BuildingConstructed Ein Gebäude wurde fertiggestellt. (Parameter: BuildingID, PlayerID)
-- @field BuildingUpgraded Ein Gebäude wurde aufgewertet. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field BuildingUpgradeCollapsed Eine Ausbaustufe eines Gebäudes wurde zerstört. (Parameter: BuildingID, PlayerID, NewUpgradeLevel)
-- @field ThiefInfiltratedBuilding Ein Dieb hat ein Gebäude infiltriert. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID)
-- @field ThiefDeliverEarnings Ein Dieb liefert seine Beute ab. (Parameter: ThiefID, PlayerID, BuildingID, BuildingPlayerID, GoldAmount)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Deaktiviert die Standardaktion wenn ein Dieb in ein Lagerhaus eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableStorehouseEffect(true);
-- -- Aktivieren
-- API.ThiefDisableStorehouseEffect(false);
--
function API.ThiefDisableStorehouseEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefStorehouseHeist = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb in eine Kirche eindringt.
--
-- <b>Hinweis</b>: Wird die Standardaktion deaktiviert, stielt der Dieb
-- stattdessen Informationen.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCathedralEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCathedralEffect(false);
--
function API.ThiefDisableCathedralEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefCathedralSabotage = _Flag == true;
end

---
-- Deaktiviert die Standardaktion wenn ein Dieb einen Brunnen sabotiert.
--
-- <b>Hinweis</b>: Brunnen können nur im Addon gebaut und sabotiert werden.
--
-- @param[type=boolean] _Flag Standardeffekt deaktiviert
-- @within Anwenderfunktionen
--
-- @usage
-- -- Deaktivieren
-- API.ThiefDisableCisternEffect(true);
-- -- Aktivieren
-- API.ThiefDisableCisternEffect(false);
--
function API.ThiefDisableCisternEffect(_Flag)
    ModuleEntityEventCore.Global.DisableThiefCisternSabotage = _Flag == true;
end

