-- -------------------------------------------------------------------------- --

---
-- Stellt Funktionen für die RTS-Camera bereit.
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
-- Aktiviert oder deaktiviert den erweiterten Zoom.
--
-- Der maximale Zoom wird erweitert. Dabei entsteht eine fast völlige 
-- Draufsicht. Dies kann nütztlich sein, wenn der Spieler ein größeres 
-- Sichtfeld benötigt.
--
-- @param[type=boolean] _Flag Erweiterter Zoom gestattet
-- @within Anwenderfunktionen
--
-- @usage
-- -- Erweitere Kamera einschalten
-- API.AllowExtendedZoom(true);
-- -- Erweitere Kamera abschalten
-- API.AllowExtendedZoom(false);
--
function API.AllowExtendedZoom(_Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.AllowExtendedZoom(%s)]],
            tostring(_Flag)
        ))
        return;
    end
    ModuleCamera.Local.ExtendedZoomAllowed = _Flag == true;
    if _Flag == true then
        ModuleCamera.Local:RegisterExtendedZoomHotkey();
    else
        ModuleCamera.Local:UnregisterExtendedZoomHotkey();
        ModuleCamera.Local:DeactivateExtendedZoom();
    end
end

---
-- Fokusiert die Kamera auf dem Primärritter des Spielers.
--
-- @param[type=number] _Player Partei
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
-- @usage
-- -- Zentriert die Kamera über den Helden von Spieler 3.
-- API.FocusCameraOnKnight(3, 90, 0.5);
--
function API.FocusCameraOnKnight(_Player, _Rotation, _ZoomFactor)
    API.FocusCameraOnEntity(Logic.GetKnightID(_Player), _Rotation, _ZoomFactor)
end

---
-- Fokusiert die Kamera auf dem Entity.
--
-- @param _Entity Entity (Skriptname oder ID)
-- @param[type=number] _Rotation Kamerawinkel
-- @param[type=number] _ZoomFactor Zoomfaktor
-- @within Anwenderfunktionen
--
-- @usage
-- -- Zentriert die Kamera über dem Entity mit dem Skriptnamen "HansWurst".
-- API.FocusCameraOnKnight("HansWurst", -45, 0.2);
--
function API.FocusCameraOnEntity(_Entity, _Rotation, _ZoomFactor)
    if not GUI then
        local Subject = (type(_Entity) ~= "string" and _Entity) or ("'" .._Entity.. "'");
        Logic.ExecuteInLuaLocalState("API.FocusCameraOnEntity(" ..Subject.. ", " ..tostring(_Rotation).. ", " ..tostring(_ZoomFactor).. ")");
        return;
    end
    if type(_Rotation) ~= "number" then
        error("API.FocusCameraOnEntity: Rotation is wrong!");
        return;
    end
    if type(_ZoomFactor) ~= "number" then
        error("API.FocusCameraOnEntity: Zoom factor is wrong!");
        return;
    end
    if not IsExisting(_Entity) then
        error("API.FocusCameraOnEntity: Entity " ..tostring(_Entity).." does not exist!");
        return;
    end
    return ModuleCamera.Local:SetCameraToEntity(_Entity, _Rotation, _ZoomFactor);
end

