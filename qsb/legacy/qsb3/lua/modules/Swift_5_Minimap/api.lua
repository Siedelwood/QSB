--[[
Swift_5_Minimap/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht das Anlegen von Markierungen auf der Minimap.
--
-- Mit diesem Mittel können Positionen und Ereignisse auf der Karte markiert
-- werden. Dies kann z.B. dafür benutzt werden, einen bestimmten Suchbereich
-- auf der Karte anzuzeigen.
--
-- Mögliche Typen von Markierungen:
-- <ul>
-- <li>Signal: Eine flüchtige Markierung, die nach wenigen Sekunden wieder
-- verschwindet.</li>
-- <li>Marker: Eine statische Markierung, die dauerhaft verbleibt.</li>
-- <li>Pulse: Eine pulsierende Markierung, die dauerhaft verbleibt.</li>
-- </ul>
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InterfaceCore.api.html">(1) Interface Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Vordefinierte Farben für Minimap Marker.
-- @field Blue Königsblau
-- @field Red Blutrot
-- @field Yellow Sonnengelb
-- @field Green Blattgrün
--
MarkerColor = {
    Blue    = { 17,   7, 216},
    Red     = {216,   7,   7},
    Yellow  = { 25, 185,   8},
    Green   = { 16, 194, 220},
}

---
-- Erstellt eine flüchtige Markierung auf der Minimap.
--
-- Die Farbe kann auf 3 verschiedene Arten bestimmt werden.
-- <ol>
-- <li>Anhand der ID eines Spielers<br/>(→ Beispiel #1)</li>
-- <li>Anhand einer vordefinierten Farbe<br/>(→ Beispiel #2)</li>
-- <li>Anhand einer benutzerdefinierten Farbe<br/>(→ Beispiel #3)</li>
-- </ol>
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
-- @see MarkerColor
--
-- @usage
-- -- Beispiel #1: Farbe anhand des Spielers
-- -- Es wird die Spielerfarbe eines Spielers verwendet.
-- API.CreateMinimapSignal(1, 1, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #2: Farbe aus Vorgabentabelle
-- -- Es wird eine der vorgegebenen Farben verwendet.
-- API.CreateMinimapSignal(1, MarkerColor.Red, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #3: Farbe Frei bestimmen
-- -- Es wird eine Farbe in Table-Form übergeben.
-- API.CreateMinimapSignal(1, {88, 111, 144}, GetPosition("pos"));
--
function API.CreateMinimapSignal(_PlayerID, _PlayerIDOrColorTable, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapSignal: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 7);
end

---
-- Erstellt eine statische Markierung auf der Minimap.
--
-- Die Farbe kann auf 3 verschiedene Arten bestimmt werden.
-- <ol>
-- <li>Anhand der ID eines Spielers<br/>(→ Beispiel #1)</li>
-- <li>Anhand einer vordefinierten Farbe<br/>(→ Beispiel #2)</li>
-- <li>Anhand einer benutzerdefinierten Farbe<br/>(→ Beispiel #3)</li>
-- </ol>
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
-- @see MarkerColor
--
-- @usage
-- -- Beispiel #1: Farbe anhand des Spielers
-- -- Es wird die Spielerfarbe eines Spielers verwendet.
-- API.CreateMinimapMarker(1, 1, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #2: Farbe aus Vorgabentabelle
-- -- Es wird eine der vorgegebenen Farben verwendet.
-- API.CreateMinimapMarker(1, MarkerColor.Red, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #3: Farbe Frei bestimmen
-- -- Es wird eine Farbe in Table-Form übergeben.
-- API.CreateMinimapMarker(1, {88, 111, 144}, GetPosition("pos"));
--
function API.CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, _Position)
    -- API.CreateMinimapMarker(1, 2, Logic.GetMarketplace(1))
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapMarker: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 6);
end

---
-- Erstellt eine pulsierende Markierung auf der Minimap.
--
-- Die Farbe kann auf 3 verschiedene Arten bestimmt werden.
-- <ol>
-- <li>Anhand der ID eines Spielers<br/>(→ Beispiel #1)</li>
-- <li>Anhand einer vordefinierten Farbe<br/>(→ Beispiel #2)</li>
-- <li>Anhand einer benutzerdefinierten Farbe<br/>(→ Beispiel #3)</li>
-- </ol>
--
-- @param[type=number] _PlayerID             Anzeige für Spieler
-- @param              _PlayerIDOrColorTable PlayerID oder Farbtabelle
-- @param              _Position             Position des Markers (Skriptname, ID oder Position)
-- @return[type=number] ID des Markers
-- @within Anwenderfunktionen
-- @see MarkerColor
--
-- @usage
-- -- Beispiel #1: Farbe anhand des Spielers
-- -- Es wird die Spielerfarbe eines Spielers verwendet.
-- API.CreateMinimapPulse(1, 1, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #2: Farbe aus Vorgabentabelle
-- -- Es wird eine der vorgegebenen Farben verwendet.
-- API.CreateMinimapPulse(1, MarkerColor.Red, GetPosition("pos"));
--
-- @usage
-- -- Beispiel #3: Farbe Frei bestimmen
-- -- Es wird eine Farbe in Table-Form übergeben.
-- API.CreateMinimapPulse(1, {88, 111, 144}, GetPosition("pos"));
--
function API.CreateMinimapPulse(_PlayerID, _PlayerIDOrColorTable, _Position)
    if GUI then
        return;
    end

    local Position = _Position;
    if type(_Position) ~= "table" then
        Position = GetPosition(_Position);
    end
    if type(Position) ~= "table" or (not Position.X or not Position.X) then
        error("API.CreateMinimapPulse: Position is invalid!");
        return;
    end
    return ModuleMinimap.Global:CreateMinimapMarker(_PlayerID, _PlayerIDOrColorTable, Position.X, Position.Y, 1);
end

---
-- Zerstört eine Markierung auf der Minimap.
--
-- @param[type=number] _ID ID des Markers
-- @within Anwenderfunktionen
--
-- @usage
-- API.DestroyMinimapSignal(SomeMarkerID);
--
function API.DestroyMinimapSignal(_ID)
    if GUI then
        return;
    end
    if type(_ID) ~= "number" then
        error("API.DestroyMinimapSignal: _ID must be a number!");
        return;
    end
    ModuleMinimap.Global:DestroyMinimapMarker(_ID);
end

