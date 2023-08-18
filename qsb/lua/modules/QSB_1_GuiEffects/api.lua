-- -------------------------------------------------------------------------- --

---
-- Ermöglicht die Nutzung von verschiedenen Anzeigeeffekte.
--
-- <h5>Cinematic Event</h5> 
-- <u>Ein Kinoevent hat nichts mit den Script Events zu tun!</u> <br>
-- Es handelt sich um eine Markierung, ob für einen Spieler gerade ein Ereignis
-- stattfindet, das das normale Spielinterface manipuliert und den normalen
-- Spielfluss einschränkt. Es wird von der QSB benutzt um festzustellen, ob
-- bereits ein solcher veränderter Zustand aktiv ist und entsorechend darauf
-- zu reagieren, damit sichergestellt ist, dass beim Zurücksetzen des normalen
-- Zustandes keine Fehler passieren.
-- 
-- Der Anwender braucht sich damit nicht zu befassen, es sei denn man plant
-- etwas, das mit Kinoevents kollidieren kann. Wenn ein Feature ein Kinoevent
-- auslöst, ist dies in der Dokumentation ausgewiesen.
-- 
-- Während eines Kinoevent kann zusätzlich nicht gespeichert werden.
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

QSB.CinematicEvent = {};

CinematicEvent = {
    NotTriggered = 0,
    Active = 1,
    Concluded = 2,
}

---
-- Events, auf die reagiert werden kann.
--
-- @field CinematicActivated  Ein Kinoevent wurde aktiviert (Parameter: KinoEventID, PlayerID)
-- @field CinematicConcluded  Ein Kinoevent wurde deaktiviert (Parameter: KinoEventID, PlayerID)
-- @field BorderScrollLocked  Scrollen am Bildschirmrand wurde gesperrt (Parameter: PlayerID)
-- @field BorderScrollReset   Scrollen am Bildschirmrand wurde freigegeben (Parameter: PlayerID)
-- @field GameInterfaceShown  Die Spieloberfläche wird angezeigt (Parameter: PlayerID)
-- @field GameInterfaceHidden Die Spieloberfläche wird ausgeblendet (Parameter: PlayerID)
-- @field ImageScreenShown    Der schwarze Hintergrund wird angezeigt (Parameter: PlayerID)
-- @field ImageScreenHidden   Der schwarze Hintergrund wird ausgeblendet (Parameter: PlayerID)
-- @field TypewriterStarted   Ein Schreibmaschineneffekt beginnt (Parameter: PlayerID, DataTable)
-- @field TypewriterEnded     Ein Schreibmaschineneffekt endet (Parameter: PlayerID, DataTable)
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

-- Just to be compatible with the old version.
function API.ActivateColoredScreen(_PlayerID, _Red, _Green, _Blue, _Alpha)
    API.ActivateImageScreen(_PlayerID, "", _Red or 0, _Green or 0, _Blue or 0, _Alpha);
end

-- Just to be compatible with the old version.
function API.DeactivateColoredScreen(_PlayerID)
    API.DeactivateImageScreen(_PlayerID)
end

---
-- Blendet eine Graphic über der Spielwelt aber hinter dem Interface ein.
-- Die Grafik muss im 16:9-Format sein. Bei 4:3-Auflösungen wird
-- links und rechts abgeschnitten.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=string] _Image Pfad zur Grafik
-- @param[type=number] _Red   (Optional) Rotwert (Standard: 255)
-- @param[type=number] _Green (Optional) Grünwert (Standard: 255)
-- @param[type=number] _Blue  (Optional) Blauwert (Standard: 255)
-- @param[type=number] _Alpha (Optional) Alphawert (Standard: 255)
-- @within Anwenderfunktionen
--
function API.ActivateImageScreen(_PlayerID, _Image, _Red, _Green, _Blue, _Alpha)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleGuiEffects.Local:InterfaceActivateImageBackground(%d, "%s", %d, %d, %d, %d)]],
            _PlayerID,
            _Image,
            (_Red ~= nil and _Red) or 255,
            (_Green ~= nil and _Green) or 255,
            (_Blue ~= nil and _Blue) or 255,
            (_Alpha ~= nil and _Alpha) or 255
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateImageBackground(_PlayerID, _Image, _Red, _Green, _Blue, _Alpha);
end

---
-- Deaktiviert ein angezeigtes Bild, wenn dieses angezeigt wird.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.DeactivateImageScreen(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateImageBackground(_PlayerID);
end

---
-- Zeigt das normale Interface an.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.ActivateNormalInterface(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceActivateNormalInterface(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateNormalInterface(_PlayerID);
end

---
-- Blendet das normale Interface aus.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.DeactivateNormalInterface(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateNormalInterface(_PlayerID);
end

---
-- Akliviert border Scroll wieder und löst die Fixierung auf ein Entity auf.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.ActivateBorderScroll(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceActivateBorderScroll(%d)",
            _PlayerID
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceActivateBorderScroll(_PlayerID);
end

---
-- Deaktiviert Randscrollen und setzt die Kamera optional auf das Ziel
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Position (Optional) Entity auf das die Kamera schaut
-- @within Anwenderfunktionen
--
function API.DeactivateBorderScroll(_PlayerID, _Position)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    local PositionID;
    if _Position then
        PositionID = GetID(_Position);
    end
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            "ModuleGuiEffects.Local:InterfaceDeactivateBorderScroll(%d, %d)",
            _PlayerID,
            (PositionID or 0)
        ));
        return;
    end
    ModuleGuiEffects.Local:InterfaceDeactivateBorderScroll(_PlayerID, PositionID);
end

---
-- Propagiert den Beginn des Kinoevent und bindet es an den Spieler.
--
-- <b>Hinweis:</b>Während des aktiven Kinoevent kann nicht gespeichert werden.
--
-- @param[type=string] _Name     Bezeichner
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.StartCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    local ID = ModuleGuiEffects.Global:ActivateCinematicEvent(_PlayerID);
    QSB.CinematicEvent[_PlayerID][_Name] = ID;
end

---
-- Propagiert das Ende des Kinoevent.
--
-- @param[type=string] _Name     Bezeichner
-- @param[type=number] _PlayerID ID des Spielers
-- @within Anwenderfunktionen
--
function API.FinishCinematicEvent(_Name, _PlayerID)
    if GUI then
        return;
    end
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    if QSB.CinematicEvent[_PlayerID][_Name] then
        ModuleGuiEffects.Global:ConcludeCinematicEvent(QSB.CinematicEvent[_PlayerID][_Name], _PlayerID);
    end
end

---
-- Gibt den Zustand des Kinoevent zurück.
--
-- @param _Identifier            Bezeichner oder ID
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Zustand des Kinoevent
-- @within Anwenderfunktionen
--
function API.GetCinematicEvent(_Identifier, _PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    if type(_Identifier) == "number" then
        if GUI then
            return ModuleGuiEffects.Local:GetCinematicEventStatus(_Identifier);
        end
        return ModuleGuiEffects.Global:GetCinematicEventStatus(_Identifier);
    end
    if QSB.CinematicEvent[_PlayerID][_Identifier] then
        if GUI then
            return ModuleGuiEffects.Local:GetCinematicEventStatus(QSB.CinematicEvent[_PlayerID][_Identifier]);
        end
        return ModuleGuiEffects.Global:GetCinematicEventStatus(QSB.CinematicEvent[_PlayerID][_Identifier]);
    end
    return CinematicEvent.NotTriggered;
end

---
-- Prüft ob gerade ein Kinoevent für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Kinoevent ist aktiv
-- @within Anwenderfunktionen
--
function API.IsCinematicEventActive(_PlayerID)
    assert(_PlayerID and _PlayerID >= 1 and _PlayerID <= 8);
    QSB.CinematicEvent[_PlayerID] = QSB.CinematicEvent[_PlayerID] or {};
    for k, v in pairs(QSB.CinematicEvent[_PlayerID]) do
        if API.GetCinematicEvent(k, _PlayerID) == CinematicEvent.Active then
            return true;
        end
    end
    return false;
end

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
--     Color = { R = 0, G = 0, B = 66 }, -- A = 255 statt Opacity möglich
--     Opacity = 255,
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
    return ModuleGuiEffects.Global:StartTypewriter(_Data);
end
API.SimpleTypewriter = API.StartTypewriter;

