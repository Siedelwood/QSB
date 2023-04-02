-- -------------------------------------------------------------------------- --

---
-- Ermöglicht mit interaktiven Objekten Baustellen zu setzen.
--
-- Die Baustelle muss durch den Helden aktiviert werden. Ein Siedler wird aus
-- dem Lagerhaus kommen und das Gebäude bauen.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
-- <li><a href="modules.QSB_2_Objects.QSB_2_Objects.html">(2) Interaktive Objekte</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Events, auf die reagiert werden kann.
--
-- @field InteractiveSiteBuilt (Parameter: ScriptName, PlayerID, BuildingID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Erzeugt eine Baustelle eines beliebigen Gebäudetyps an der Position.
--
-- Diese Baustelle kann durch einen Helden aktiviert werden. Dann wird ein
-- Siedler zur Baustelle eilen und das Gebäude aufbauen. Es ist egal, ob es
-- sich um ein Territorium des Spielers oder einer KI handelt.
--
-- Es ist dabei zu beachten, dass der Spieler, dem die Baustelle zugeordnet
-- wird, das Territorium besitzt, auf dem er bauen soll. Des weiteren muss
-- er über ein Lagerhaus/Hauptzelt verfügen.
--
-- <p><b>Hinweis:</b> Es kann vorkommen, dass das Model der Baustelle nicht
-- geladen wird. Dann ist der Boden der Baustelle schwarz. Sobald wenigstens
-- ein reguläres Gebäude gebaut wurde, sollte die Textur jedoch vorhanden sein.
-- </p>
--
-- Mögliche Angaben für die Konfiguration:
-- <table border="1">
-- <tr><td><b>Feldname</b></td><td><b>Typ</b></td><td><b>Beschreibung</b></td></tr>
-- <tr><td>Name</td><td>string</td><td>Position für die Baustelle</td></tr>
-- <tr><td>PlayerID</td><td>number</td><td>Besitzer des Gebäudes</td></tr>
-- <tr><td>Type</td><td>number</td><td>Typ des Gebäudes</td></tr>
-- <tr><td>Costs</td><td>table</td><td>(optional) Eigene Gebäudekosten</td></tr>
-- <tr><td>Distance</td><td>number</td><td>(optional) Aktivierungsentfernung</td></tr>
-- <tr><td>Icon</td><td>table</td><td>(optional) Icon des Schalters</td></tr>
-- <tr><td>Title</td><td>string</td><td>(optional) Titel der Beschreibung</td></tr>
-- <tr><td>Text</td><td>string</td><td>(optional) Text der Beschreibung</td></tr>
-- <tr><td>Condition</td><td>function</td><td>(optional) Optionale Aktivierungsbedingung</td></tr>
-- <tr><td>Action</td><td>function</td><td>(optional) Optionale Funktion bei Aktivierung</td></tr>
-- </table>
--
-- @param[type=table] _Data Konfiguration des Objektes
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Eine einfache Baustelle erzeugen
-- API.CreateIOBuildingSite {
--     Name     = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery
-- };
--
-- @usage
-- -- Beispiel #2: Baustelle mit Kosten erzeugen
-- API.CreateIOBuildingSite {
--     Name     = "haus",
--     PlayerID = 1,
--     Type     = Entities.B_Bakery,
--     Costs    = {Goods.G_Wood, 4},
--     Distance = 1000
-- };
--
function API.CreateIOBuildingSite(_Data)
    if GUI then
        return;
    end
    if not IsExisting(_Data.Name) then
        error("API.CreateIOBuildingSite: Position (" ..tostring(_Data.Name).. ") does not exist!");
        return;
    end
    if type(_Data.PlayerID) ~= "number" or _Data.PlayerID < 1 or _Data.PlayerID > 8 then
        error("API.CreateIOBuildingSite: PlayerID is wrong!");
        return;
    end
    if GetNameOfKeyInTable(Entities, _Data.Type) == nil then
        error("API.CreateIOBuildingSite: Type (" ..tostring(_Data.Type).. ") is wrong!");
        return;
    end
    if _Data.Costs and (type(_Data.Costs) ~= "table" or #_Data.Costs %2 ~= 0) then
        error("API.CreateIOBuildingSite: Costs has the wrong format!");
        return;
    end
    if _Data.Distance and (type(_Data.Distance) ~= "number" or _Data.Distance < 100) then
        error("API.CreateIOBuildingSite: Distance (" ..tostring(_Data.Distance).. ") is wrong or too small!");
        return;
    end
    if _Data.Condition and type(_Data.Condition) ~= "function" then
        error("API.CreateIOBuildingSite: Condition must be a function!");
        return;
    end
    if _Data.Action and type(_Data.Action) ~= "function" then
        error("API.CreateIOBuildingSite: Action must be a function!");
        return;
    end
    ModuleInteractiveSites.Global:CreateIOBuildingSite(_Data);
end

