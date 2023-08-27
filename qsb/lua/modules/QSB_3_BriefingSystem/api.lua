-- -------------------------------------------------------------------------- --

---
-- Ermöglicht Briefings für verschiedene Verwendungszwecke.
--
-- Briefings dienen zur Darstellung von Dialogen oder zur näheren Erleuterung
-- der aktuellen Spielsituation. Mit Multiple Choice können dem Spieler mehrere
-- Auswahlmöglichkeiten gegeben, multiple Handlungsstränge gestartet
-- oder Menüstrukturen abgebildet werden. Mittels Sprüngen und Leerseiten
-- kann innerhalb des Multiple Choice Briefings navigiert werden.
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
-- @field BriefingStarted           Ein Briefing beginnt (Parameter: PlayerID, BriefingTable)
-- @field BriefingEnded             Ein Briefing endet (Parameter: PlayerID, BriefingTable)
-- @field BriefingPageShown         Ein Briefing endet (Parameter: PlayerID, PageIndex)
-- @field BriefingSkipButtonPressed Der Spieler überspringt eine Seite (Parameter: PlayerID)
-- @field BriefingOptionSelected    Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
-- @field BriefingLeftClick         Left Mouse wurde während des Briefings gedrückt (Parameter: PlayerID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet ein Briefing.
--
-- Die Funktion bekommt ein Table mit der Briefingdefinition, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- <h5>Einstellungen</h5>
-- Für ein Briefing können verschiedene spezielle Einstellungen vorgenommen
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
-- <td>(Optional) Eine Funktion, die beim Start des Briefing ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.BriefingStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Briefing ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.BriefingEnded aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>RestoreCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Kameraposition am Ende des Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>RestoreGameSpeed</td>
-- <td>boolean</td>
-- <td>(Optional) Stellt die Geschwindigkeit von vor dem Dialog wieder her. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableGlobalImmortality</td>
-- <td>boolean</td>
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange das Briefing aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableSky</td>
-- <td>boolean</td>
-- <td>(Optional) Der Himmel wird während des Briefing angezeigt. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges wird während des Briefing angezeigt. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine werden während des Briefing angezeigt. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- <h5>Animationen</h5>
-- Kameraanimationen für Seiten eines Briefings können vom Text einer Page
-- entkoppelt werden. Das hat den Charme, dass Spielfiguren erzählen und
-- erzählen und die Kamera über die ganze Zeit die gleiche Animation zeigt,
-- was das Lesen angenehmer macht.
--
-- <b>Hinweis:</b> Animationen werden nur erzeugt, wenn die Page noch keine
-- Position hat! Andernfalls werden die Werte für Angle, Rotation und Zoom
-- aus der Page genommen und/oder Defaults verwendet.
--
-- Animationen können über eine Table angegeben werden. Diese wird direkt
-- in die Briefing Table geschrieben. Die Animation wird die Kamera dann von
-- Position 1 zu Position 2 bewegen. Dabei ist die zweite Position optional
-- und kann weggelassen werden.
-- 
-- <p>(→ Beispiel #2)</p>
-- <p>(→ Beispiel #3)</p>
-- <p>(→ Beispiel #4)</p>
--
-- <h5>Parallax</h5>
-- Unter Parallax versteht man (im Kontext eines Videospiels) einen Hintergrund,
-- dessen Bildausschnitt veränderlich ist. So wurden früher z.B. der Hintergrund
-- eines Side Scrollers (Super Mario, Sonic, ...) realisiert.
--
-- Während eines Briefings können bis zu 6 übereinander liegende Ebenen solcher
-- Parallaxe verwendet werden. Dabei wird eine Grafik vorgegeben, die durch
-- Angabe von UV-Koordinaten und Alphawert animiert werden kann. Diese Grafiken
-- liegen hinter allen Elementen des Thronerooms.
--
-- Parallaxe können über eine Table angegeben werden. Diese wird direkt in die
-- Briefing Table geschrieben. Jede Ebene kann getrennt von den anderen agieren.
-- Ein Parallax kann statisch ein Bild anzeigen oder animiert sein. In diesem
-- Fall wird sich von Position 1 zu Position 2 bewegt, wobei Position 2 optional
-- ist und weggelassen werden kann.
--
-- Die UV-Koordinaten ergeben zwei Punkte auf der Grafik aus der ein Rechteck
-- ergänzt wird. Die Koordinaten können entweder pixelgenau order relativ
-- angegeben werden. Pixelgenau bedeutet, dass man einen Punkt exakt an einer
-- bestimmten Position auf der Grafik auswählt und setzt (z.B. 100, 50). Gibt
-- man relative Werte an, dann benutzt man Zahlen zwischen 0 und 1, wobei 0 für
-- 0% und 1 für 100% steht. In jedem Fall sind die Koordinaten absolut oder
-- relativ zur Grafik und nicht zur Bildschirmgröße.
--
-- <b>Achtung:</b> Die Grafiken müssen immer im 16:9 Format sein. Für den Fall,
-- dass das Spiel in einer 4:3 Auflösung gespielt wird, werden automatisch die
-- angegebenen Koordinaten umgerechnet und links und rechts abgeschnitten.
-- Konzipiere Grafiken also stets so, dass sie auch im 4:3 Format noch das
-- wichtigste zeigen.
--
-- <p>(→ Beispiel #5)</p>
-- <p>(→ Beispiel #6)</p>
--
-- @param[type=table]  _Briefing Definition des Briefing
-- @param[type=string] _Name     Name des Briefing
-- @param[type=number] _PlayerID Empfänger des Briefing
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Grobes Gerüst eines Briefings
-- function Briefing1(_Name, _PlayerID)
--     local Briefing = {
--         -- Hier können verschiedene Konfigurationen vorgenommen werden.
--     };
--     local AP, ASP = API.AddBriefingPages(Briefing);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Briefing.Starting = function(_Data)
--         -- Mach was tolles hier, wenn es anfängt.
--     end
--     Briefing.Finished = function(_Data)
--         -- Mach was tolles hier, wenn es endet.
--     end
--     -- Das Briefing wird gestartet
--     API.StartBriefing(Briefing, _Name, _PlayerID);
-- end
--
-- @usage
-- -- Beispiel #2: Angabe von Animationen
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Relativdarstellung
--         -- Animationsdauer, Position1, Rotation1, Zoom1, Angle1, Position2, Rotation2, Zoom2, Angle2
--         {30, "pos4", -60, 2000, 35, "pos4", -30, 2000, 25},
--         -- Hier können weitere Animationen folgen...
--     },
--     ["Page3"] = {
--         -- Vektordarstellung
--         -- Animationsdauer, {Position1, Höhe}, {LookAt1, Höhe}, {Position2, Höhe}, {LookAt2, Höhe}
--         {30, {"pos2", 500}, {"pos4", 0}, {"pos7", 1000}, {"pos8", 0}},
--         -- Hier können weitere Animationen folgen...
--     },
--     -- Hier können weitere Pages folgen...
-- };
--
-- @usage
-- -- Beispiel #3: Laufende Animationen ersetzen
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Löscht alle laufenden Animationen
--         Clear = true,
--         {30, "pos4", -60, 2000, 35, "pos4", -30, 2000, 25},
--     },
-- };
--
-- @usage
-- -- Beispiel #4: Animation in Endlosschleife
-- Briefing.PageAnimations = {
--     ["Page1"] = {
--         -- Lässt die Animationen sich wiederholen
--         Repeat = true,
--         {30, "pos4",   0, 4000, 35, "pos4", 180, 4000, 35},
--         {30, "pos4", 180, 4000, 35, "pos4", 360, 4000, 35},
--     },
-- };
--
-- @usage
-- -- Beispiel #5: Angabe von Parallaxen
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Bilddatei, Anzeigedauer,
--         -- U0Start, V0Start, U1Start, V1Start, AlphaStart,
--         -- U0End, V0End, U1End, V1End, AlphaEnd
--         {"maps/externalmap/mapname/graphics/Parallax6.png", 60,
--          0, 0, 0.8, 1, 255,
--          0.2, 0, 1, 1, 255},
--         -- Hier können weitere Einträge folgen...
--     },
--     ["Page3"] = {
--         -- Bilddatei, Anzeigedauer,
--         -- U0Start, V0Start, U1Start, V1Start, AlphaStart
--         {"maps/externalmap/mapname/graphics/Parallax1.png", 1,
--          0, 0, 1, 1, 180},
--         -- Hier können weitere Einträge folgen...
--     }
--     -- Hier können weitere Pages folgen...
-- };
--
-- @usage
-- -- Beispiel #6: Laufende Parallaxe ersetzen
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Löscht alle laufenden Paralaxe
--         Clear = true,
--         {"maps/externalmap/mapname/graphics/Parallax6.png",
--          60, 0, 0, 0.8, 1, 255, 0.2, 0, 1, 1, 255},
--     },
-- };
--
-- @usage
-- -- Beispiel #7: Parallaxe im Vordergrund
-- Briefing.PageParallax = {
--     ["Page1"] = {
--         -- Parallaxe erscheinen im Vordergrund
--         Foreground = true,
--         {"maps/externalmap/mapname/graphics/Parallax6.png",
--          60, 0, 0, 0.8, 1, 255, 0.2, 0, 1, 1, 255},
--     },
-- };
--
function API.StartBriefing(_Briefing, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = 1;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Briefing) ~= "table" then
        error("API.StartBriefing (" .._Name.. "): _Briefing must be a table!");
        return;
    end
    if #_Briefing == 0 then
        error("API.StartBriefing (" .._Name.. "): _Briefing does not contain pages!");
        return;
    end
    for i=1, #_Briefing do
        if type(_Briefing[i]) == "table" and not _Briefing[i].__Legit then
            error("API.StartBriefing (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Briefing.EnableSky == nil then
        _Briefing.EnableSky = true;
    end
    if _Briefing.EnableFoW == nil then
        _Briefing.EnableFoW = false;
    end
    if _Briefing.EnableGlobalImmortality == nil then
        _Briefing.EnableGlobalImmortality = true;
    end
    if _Briefing.EnableBorderPins == nil then
        _Briefing.EnableBorderPins = false;
    end
    if _Briefing.RestoreGameSpeed == nil then
        _Briefing.RestoreGameSpeed = true;
    end
    if _Briefing.RestoreCamera == nil then
        _Briefing.RestoreCamera = true;
    end
    ModuleBriefingSystem.Global:StartBriefing(_Name, PlayerID, _Briefing);
end

---
-- Prüft ob für den Spieler gerade ein Briefing aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Briefing ist aktiv
-- @within Anwenderfunktionen
--
function API.IsBriefingActive(_PlayerID)
    if API.GetScriptEnvironment() == QSB.Environment.GLOBAL then
        return ModuleBriefingSystem.Global:GetCurrentBriefing(_PlayerID) ~= nil;
    end
    return ModuleBriefingSystem.Local:GetCurrentBriefing(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten und Animationen in einem
-- Briefing. Diese Funktion muss vor dem Start eines Briefing aufgerufen werden,
-- damit Seiten gebunden werden können. Je nach Bedarf können Rückgaben von
-- rechts nach links weggelassen werden.
--
-- @param[type=table] _Briefing Briefing Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @within Anwenderfunktionen
-- @see API.StartBriefing
--
-- @usage
-- -- Wenn nur AP benötigt wird.
-- local AP = API.AddBriefingPages(Briefing);
-- -- Wenn zusätzlich ASP benötigt wird.
-- local AP, ASP = API.AddBriefingPages(Briefing);
--
function API.AddBriefingPages(_Briefing)
    ModuleBriefingSystem.Global:CreateBriefingGetPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddMCPage(_Briefing);
    ModuleBriefingSystem.Global:CreateBriefingAddRedirect(_Briefing);

    local AP = function(_Page)
        local Page;
        if type(_Page) == "table" then
            if _Page.MC then
                Page = _Briefing:AddMCPage(_Page);
            else
                Page = _Briefing:AddPage(_Page);
            end
        else
            Page = _Briefing:AddRedirect(_Page);
        end
        return Page;
    end

    local ASP = function(...)
        _Briefing.PageAnimations = _Briefing.PageAnimations or {};

        local Name, Title,Text, Position;
        local DialogCam = false;
        local Action = function() end;
        local NoSkipping = false;

        -- Set page parameters
        if (#arg == 3 and type(arg[1]) == "string")
        or (#arg >= 4 and type(arg[4]) == "boolean") then
            Name = table.remove(arg, 1);
        end
        Title = table.remove(arg, 1);
        Text = table.remove(arg, 1);
        if #arg > 0 then
            DialogCam = table.remove(arg, 1) == true;
        end
        if #arg > 0 then
            Position = table.remove(arg, 1);
        end
        if #arg > 0 then
            Action = table.remove(arg, 1);
        end
        if #arg > 0 then
            NoSkipping = not table.remove(arg, 1);
        end

        -- Calculate camera rotation
        local Rotation;
        if Position then
            Rotation = QSB.Briefing.CAMERA_ROTATIONDEFAULT;
            if Position and Logic.IsSettler(GetID(Position)) == 1 then
                Rotation = Logic.GetEntityOrientation(GetID(Position)) + 90;
            end
        end

        -- Create page
        return _Briefing:AddPage {
            Name            = Name,
            Title           = Title,
            Text            = Text,
            Action          = Action,
            Position        = Position,
            DisableSkipping = NoSkipping,
            DialogCamera    = DialogCam,
            Rotation        = Rotation,
        };
    end

    -- Prevent hard errors
    local AAN = function()
        error("AAN has been removed!");
    end;
    return AP, ASP, AAN;
end

---
-- Erzeugt eine neue Seite für das Briefing.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- <h5>Briefing Page</h5>
-- Die Briefing Page definiert, was zum Zeitpunkt ihrer Anzeige dargestellt
-- wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- Folgende Parameter werden als Felder (Name = Wert) übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Feldname</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
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
-- <td>Position</td>
-- <td>string</td>
-- <td>Striptname des Entity, welches die Kamera ansieht.</td>
-- </tr>
-- <tr>
-- <td>Duration</td>
-- <td>number</td>
-- <td>(Optional) Bestimmt, wie lange die Page angezeigt wird. Wird es
-- weggelassen, wird automatisch eine Anzeigezeit anhand der Textlänge bestimmt.
-- Diese ist immer mindestens 6 Sekunden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>(Optional) Eine Boolean, welche angibt, ob Nah- oder Fernsicht benutzt
-- wird.</td>
-- </tr>
-- <tr>
-- <td>DisableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Das Überspringen der Seite wird unterbunden.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, sobald
-- die Seite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>FarClipPlane</td>
-- <td>number</td>
-- <td>(Optional) Renderdistanz für die Seite (Default 100000).
-- wird.</td>
-- </tr>
-- <tr>
-- <tr>
-- <td>Rotation</td>
-- <td>number</td>
-- <td>(Optional) Rotation der Kamera gibt den Winkel an, indem die Kamera
-- um das Ziel gedreht wird.</td>
-- </tr>
-- <tr>
-- <td>Zoom</td>
-- <td>number</td>
-- <td>(Optional) Zoom bestimmt die Entfernung der Kamera zum Ziel.</td>
-- </tr>
-- <tr>
-- <td>Angle</td>
-- <td>number</td>
-- <td>(Optional) Angle gibt den Winkel an, in dem die Kamera gekippt wird.
-- </td>
-- </tr>
-- <tr>
-- <td>FlyTo</td>
-- <td>table</td>
-- <td>(Optional) Kann ein zweites Set von Position, Rotation, Zoom und Angle
-- enthalten, zudem sich die Kamera dann bewegt.
-- </td>
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
-- <td>BarOpacity</td>
-- <td>number</td>
-- <td>(Optional) Setzt den Alphawert der Bars (Zwischen 0 und 1).</td>
-- </tr>
-- <tr>
-- <td>BigBars</td>
-- <td>boolean</td>
-- <td>(Optional) Schalted breite Balken ein oder aus.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(Optional) Liste von Optionen zur Verzweigung des Briefings. Dies kann
-- benutzt werden, um z.B. Dialoge mit Antwortmöglichkeiten zu erstellen.</td>
-- </tr>
-- </table>
--
-- <h5>Multiple Choice</h5>
-- In einem Briefing kann der Spieler auch zur Auswahl einer Option gebeten
-- werden. Dies wird als Multiple Choice bezeichnet. Schreibe die Optionen
-- in eine Untertabelle MC.
--
-- <p>(→ Beispiel #2)</p>
-- 
-- Es kann der Name der Zielseite angegeben werden, oder eine Funktion, die
-- den Namen des Ziels zurück gibt. In der Funktion können vorher beliebige
-- Dinge getan werden, wie z.B. Variablen setzen.
--
-- Eine Antwort kann markiert werden, dass sie auch bei einem Rücksprung,
-- nicht mehrfach gewählt werden kann. In diesem Fall ist sie bei erneutem
-- Aufsuchen der Seite nicht mehr gelistet.
-- 
-- <p>(→ Beispiel #3)</p>
--
-- Eine Option kann auch bedingt ausgeblendet werden. Dazu wird eine Funktion
-- angegeben, welche über die Sichtbarkeit entscheidet.
-- 
-- <p>(→ Beispiel #4)</p>
--
-- Nachdem der Spieler eine Antwort gewählt hat, wird er auf die Seite mit
-- dem angegebenen Namen geleitet.
--
-- Um das Briefing zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß das Briefing, das es an dieser
-- Stelle zuende ist.
--
-- <p>(→ Beispiel #5)</p>
--
-- Soll stattdessen zu einer anderen Seite gesprungen werden, kann bei AP der
-- Name der Seite angeben werden, zu der gesprungen werden soll.
--
-- <p>(→ Beispiel #6)</p>
--
-- Um später zu einem beliebigen Zeitpunkt die gewählte Antwort einer Seite zu
-- erfahren, muss der Name der Seite genutzt werden.
-- 
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
-- 
-- <p>(→ Beispiel #7)</p>
--
-- @param[type=table] _Data Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Briefing
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AP {
--    -- Hier werden die Attribute der Page angegeben
--    Title        = "Marcus",
--    Text         = "Das ist eine simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
-- };
--
-- @usage
-- -- Beispiel #2: Verwendung von Multiple Choice
-- AP {
--    Title        = "Marcus",
--    Text         = "Das ist eine nicht so simple Seite.",
--    Position     = "Marcus",
--    Rotation     = 30,
--    DialogCamera = true,
--    -- MC ist das Table mit den auswählbaren Antworten
--    MC = {
--        -- Zielseite ist der Name der Page, zu der gesprungen wird.
--        {"Antwort 1", "Zielseite"},
--        -- Option2Clicked ist eine Funktion, die etwas macht und
--        -- danach die Page zurückgibt, zu der gesprungen wird.
--        {"Antwort 2", Option2Clicked},
--    },
-- };
--
-- @usage
-- -- Beispiel #3: Antwort, die nur einmal gewählt werden kann
-- MC = {
--     {"Antwort 3", "AnotherPage", Remove = true},
-- }
--
-- @usage
-- -- Beispiel #4: Antwort mit gesteuerter Sichtbarkeit
-- MC = {
--     {"Antwort 3", "AnotherPage", Disable = OptionIsDisabled},
-- }
--
-- @usage
-- -- Beispiel #5: Abbruch des Briefings
-- AP()
--
-- @usage
-- -- Beispiel #6: Sprung zu anderer Seite
-- AP("SomePageName")
--
-- @usage
-- -- Beispiel #7: Erfragen der gewählten Antwort
-- Briefing.Finished = function(_Data)
--     local Choosen = _Data:GetPage("Choice"):GetSelected();
--     -- In Choosen steht der Index der Antwort
-- end
--
function AP(_Data)
    assert(false);
end

---
-- Erzeugt eine neue Seite für das Briefing in Kurzschreibweise.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddBriefingPages">API.AddBriefingPages</a> erzeugt und an
-- das Briefing gebunden.
--
-- Die Seite erhält automatisch einen Namen, entsprechend der Reihenfolge aller
-- Seitenaufrufe von AP oder ASP. Werden also vor dem Aufruf bereits 2 Seiten
-- erzeugt, so würde die Seite den Namen "Page3" erhalten.
--
-- Folgende Parameter werden in <u>genau dieser Reihenfolge</u> an die Funktion
-- übergeben:
-- <table border="1">
-- <tr>
-- <td><b>Bezeichnung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Name</td>
-- <td>string</td>
-- <td>Der interne Name der Page.</td>
-- </tr>
-- <tr>
-- <td>Title</td>
-- <td>string|table</td>
-- <td>Der angezeigte Titel der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string|table</td>
-- <td>Der angezeigte Text der Seite. Es können auch Text Keys oder
-- lokalisierte Tables übergeben werden.</td>
-- </tr>
-- <tr>
-- <td>DialogCamera</td>
-- <td>boolean</td>
-- <td>Die Kamera geht in Nahsicht und stellt Charaktere dar. Wird
-- sie weggelassen, wird die Fernsicht verwendet.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>string</td>
-- <td>(Optional) Skriptname des Entity zu das die Kamera springt.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die jedes Mal ausgeführt wird, wenn die Seite
-- angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>EnableSkipping</td>
-- <td>boolean</td>
-- <td>(Optional) Steuert, ob die Seite übersprungen werden darf. Wenn es nicht
-- angegeben wird, ist das Überspringen immer deaktiviert.</td>
-- </tr>
-- </table>
--
-- @param ... Daten der Seite
-- @return[type=table] Erzeugte Seite
-- @within Briefing
--
-- @usage
-- -- Hinweis dazu: In Lua werden Parameter von links nach rechts aufgelöst.
-- -- Will man also Parameter weglassen, wenn danach noch welche folgen, muss
-- -- man die Leerstellen mit nil auffüllen.
--
-- -- Fernsicht
-- ASP("Title", "Some important text.", false, "HQ");
-- -- Page Name
-- ASP("Page1", "Title", "Some important text.", false, "HQ");
-- -- Nahsicht
-- ASP("Title", "Some important text.", true, "Marcus");
-- -- Aktion ausführen
-- ASP("Title", "Some important text.", true, "Marcus", MyFunction);
-- -- Überspringen erlauben/verbieten
-- ASP("Title", "Some important text.", true, "HQ", nil, true);
--
function ASP(...)
    assert(false);
end

