-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Verwendung von echten Kameraflügen.
--
-- Cutscenes sind Kameraflüge, die zur szenerischen Untermalung gedacht sind.
-- Texte sind kurz zu halten oder ganz wegzulassen, da der Spieler die Animation
-- genießen soll und bestimmt nicht die ganze Zeit mit den Augen am
-- Bildschirmrand festkleben will. Ebensowenig sind breite Bars oder der
-- stetige Wechsel zwischen schmal und breit zu empfehlen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_1_GuiEffects.QSB_1_GuiEffects.html">(1) Anzeigeeffekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field CutsceneStarted           Eine Cutscene beginnt (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneEnded             Eine Cutscene endet (Parameter: PlayerID, CutsceneTable)
-- @field CutsceneSkipButtonPressed Der Spieler beschleunigt die Wiedergabegeschwindigkeit (Parameter: PlayerID)
-- @field CutsceneFlightStarted     Ein Flight wird gestartet (Parameter: PlayerID, PageIndex, Duration)
-- @field CutsceneFlightEnded       Ein Flight ist beendet (Parameter: PlayerID, PageIndex)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet eine Cutscene.
--
-- Die Funktion bekommt ein Table mit der Definition der Cutscene, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- <h5>Einstellungen</h5>
-- Für eine Cutscene können verschiedene spezielle Einstellungen vorgenommen
-- werden.
--
-- Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start der Cutscene ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.CutsceneStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung der Cutscene ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.CutsceneEnded aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange die Cutscene aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während der Cutscene angezeigt. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird während der Cutscene angezeigt. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden während der Cutscene angezeigt. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Cutscene Definition der Cutscene
-- @param[type=string] _Name     Name der Cutscene
-- @param[type=number] _PlayerID Empfänger der Cutscene
-- @within Anwenderfunktionen
--
-- @usage
-- 
-- function Cutscene1(_Name, _PlayerID)
--     local Cutscene = {};
--     local AP = API.AddCutscenePages(Cutscene);
--
--     -- Aufrufe von AP um Seiten zu erstellen
--
--     Cutscene.Starting = function(_Data)
--         -- Mach was tolles hier wenn es anfängt.
--     end
--     Cutscene.Finished = function(_Data)
--         -- Mach was tolles hier wenn es endet.
--     end
--     API.StartCutscene(Cutscene, _Name, _PlayerID);
-- end
--
function API.StartCutscene(_Cutscene, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = 1;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Cutscene) ~= "table" then
        error("API.StartCutscene (" .._Name.. "): _Cutscene must be a table!");
        return;
    end
    if #_Cutscene == 0 then
        error("API.StartCutscene (" .._Name.. "): _Cutscene does not contain pages!");
        return;
    end
    for i=1, #_Cutscene do
        if not _Cutscene[i].__Legit then
            error("API.StartCutscene (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Cutscene.EnableSky == nil then
        _Cutscene.EnableSky = true;
    end
    if _Cutscene.EnableFoW == nil then
        _Cutscene.EnableFoW = false;
    end
    if _Cutscene.EnableGlobalImmortality == nil then
        _Cutscene.EnableGlobalImmortality = true;
    end
    if _Cutscene.EnableBorderPins == nil then
        _Cutscene.EnableBorderPins = false;
    end
    ModuleCutsceneSystem.Global:StartCutscene(_Name, PlayerID, _Cutscene);
end

---
-- Prüft ob für den Spieler gerade eine Cutscene aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Cutscene ist aktiv
-- @within Anwenderfunktionen
--
function API.IsCutsceneActive(_PlayerID)
    if API.GetScriptEnvironment() == QSB.Environment.GLOBAL then
        return ModuleCutsceneSystem.Global:GetCurrentCutscene(_PlayerID) ~= nil;
    end
    return ModuleCutsceneSystem.Local:GetCurrentCutscene(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktion zur Erstellung von Flights in einer Cutscene. Diese
-- Funktion muss vor dem Start einer Cutscene aufgerufen werden, damit Seiten
-- gebunden werden können.
--
-- @param[type=table] _Cutscene Cutscene Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @within Anwenderfunktionen
--
-- @usage
-- local AP = API.AddCutscenePages(Cutscene);
--
function API.AddCutscenePages(_Cutscene)
    ModuleCutsceneSystem.Global:CreateCutsceneGetPage(_Cutscene);
    ModuleCutsceneSystem.Global:CreateCutsceneAddPage(_Cutscene);

    local AP = function(_Page)
        return _Cutscene:AddPage(_Page);
    end
    return AP;
end

---
-- Erzeugt einen neuen Flight für die Cutscene.
--
-- <p>(→ Beispiel #1)</p>
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddCutscenePages">API.AddCutscenePages</a> erzeugt und an
-- die Cutscene gebunden.
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Flight</td>
-- <td>string</td>
-- <td>Name der CS-Datei ohne Dateiendung</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der Titel, der oben angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der Text, der unten angezeigt wird. Es ist möglich eine Table mit
-- deutschen und englischen Texten anzugeben.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die ausgeführt wird, sobald der Flight
-- angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>FarClipPlane</td>
-- <td>number</td>
-- <td>(Optional) Renderdistanz für die Seite (Default 35000).
-- wird.</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn des Flight.</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Abblendens zu Schwarz am Ende des Flight.</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>number</td>
-- <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
-- wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
-- der nächsten mit Fade In muss immer eine Seite mit FaderAlpha sein!</b></td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Die Fast Forward Aktion wird unterbunden. Außerdem wird die Beschleunigung automatisch aufgehoben.</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</td>
-- </tr>
-- <tr>
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- </table>
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AP {
--     -- Dateiname der Cutscene ohne .cs
--     Flight       = "c02",
--     -- Maximale Renderdistanz
--     FarClipPlane = 45000,
--     -- Text
--     Title        = "Title",
--     Text         = "Text of the flight.",
-- };
--
-- @within Cutscene
--
function AP(_Data)
    assert(false);
end

