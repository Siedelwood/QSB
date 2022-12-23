--[[
Swift_2_Typewriter/API

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

---
-- Ermöglicht die Anzeige eines fortlaufend getippten Text auf dem Bildschirm.
--
-- Der Text kann mit oder ohne schwarzem Hintergrund angezeigt werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_1_InputOutputCore.api.html">(1) Input/Output Core</a></li>
-- <li><a href="Swift_1_DisplayCore.api.html">(1) Display Core</a></li>
-- <li><a href="Swift_1_JobsCore.api.html">(1) Jobs Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field TypewriterStarted Ein Schreibmaschineneffekt beginnt (Parameter: PlayerID, DataTable)
-- @field TypewriterEnded   Ein Schreibmaschineneffekt endet (Parameter: PlayerID, DataTable)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Blendet einen Text Zeichen für Zeichen ein.
--
-- Der Effekt startet erst, nachdem die Map geladen ist. Wenn ein anderes
-- Cinematic Event läuft, wird gewartet, bis es beendet ist. Wärhend der Effekt
-- läuft, können wiederrum keine Cinematic Events starten.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der anzuzeigene Text</td>
-- </tr>
-- <tr>
-- <td>PlayerID</td>
-- <td>number</td>
-- <td>(Optional) Spieler, dem der Effekt angezeigt wird (Default: Menschlicher Spieler)</td>
-- </tr>
-- <tr>
-- <td>Callback</td>
-- <td>function</td>
-- <td>(Optional) Funktion nach Abschluss der Textanzeige (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>TargetEntity</td>
-- <td>string|number</td>
-- <td>(Optional) TargetEntity der Kamera (Default: nil)</td>
-- </tr>
-- <tr>
-- <td>CharSpeed</td>
-- <td>number</td>
-- <td>(Optional) Die Schreibgeschwindigkeit (Default: 1.0)</td>
-- </tr>
-- <tr>
-- <td>Waittime</td>
-- <td>number</td>
-- <td>(Optional) Initiale Wartezeigt bevor der Effekt startet</td>
-- </tr>
-- <tr>
-- <td>Opacity</td>
-- <td>number</td>
-- <td>(Optional) Durchsichtigkeit des Hintergrund (Default: 1)</td>
-- </tr>
-- <tr>
-- <td>Color</td>
-- <td>table</td>
-- <td>(Optional) Farbe des Hintergrund (Default: {R= 0, G= 0, B= 0}}</td>
-- </tr>
-- <tr>
-- <td>Image</td>
-- <td>string</td>
-- <td>(Optional) Pfad zur anzuzeigenden Grafik</td>
-- </tr>
-- </table>
--
-- <b>Hinweis</b>: Steuerzeichen wie {cr} oder {@color} werden als ein Token
-- gewertet und immer sofort eingeblendet. Steht z.B. {cr}{cr} im Text, werden
-- die Zeichen atomar behandelt, als seien sie ein einzelnes Zeichen.
-- Gibt es mehr als 1 Leerzeichen hintereinander, werden alle zusammenhängenden
-- Leerzeichen (vom Spiel) auf ein Leerzeichen reduziert!
--
-- @param[type=table] _Data Konfiguration
-- @return[type=string] Name des zugeordneten Event
--
-- @usage
-- local EventName = API.StartTypewriter {
--     PlayerID = 1,
--     Text     = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, "..
--                "sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
--                "magna aliquyam erat, sed diam voluptua. At vero eos et"..
--                " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
--                " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
--                " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
--                " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
--                " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
--                " et accusam et justo duo dolores et ea rebum. Stet clita"..
--                " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
--                " dolor sit amet.",
--     Callback = function(_Data)
--         -- Hier kann was passieren
--     end
-- };
-- @within Anwenderfunktionen
--
function API.StartTypewriter(_Data)
    if Framework.IsNetworkGame() ~= true then
        _Data.PlayerID = _Data.PlayerID or QSB.HumanPlayerID;
    end
    if _Data.PlayerID == nil or (_Data.PlayerID < 1 or _Data.PlayerID > 8) then
        return;
    end
    _Data.Text = API.Localize(_Data.Text or "");
    _Data.Callback = _Data.Callback or function() end;
    _Data.CharSpeed = _Data.CharSpeed or 1;
    _Data.Waittime = (_Data.Waittime or 8) * 10;
    _Data.TargetEntity = GetID(_Data.TargetEntity or 0);
    _Data.Image = _Data.Image or "";
    _Data.Color = _Data.Color or {
        R = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        G = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        B = (_Data.Image and _Data.Image ~= "" and 255) or 0,
        A = 255
    };
    if _Data.Opacity and _Data.Opacity >= 0 and _Data.Opacity then
        _Data.Color.A = math.floor((255 * _Data.Opacity) + 0.5);
    end
    _Data.Delay = 15;
    _Data.Index = 0;
    return ModuleTypewriter.Global:StartTypewriter(_Data);
end
API.SimpleTypewriter = API.StartTypewriter;

