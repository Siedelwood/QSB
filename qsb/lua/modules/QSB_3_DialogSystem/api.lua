--[[
Copyright (C) 2023 totalwarANGEL - All Rights Reserved.

This file is part of the QSB-R. QSB-R is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

-- -------------------------------------------------------------------------- --

---
-- Dialoge können verwendet werden, um Gespräche darzustellen.
--
-- Dialoge dienen zur Darstellung von Gesprächen. Mit Multiple Choice können
-- dem Spieler mehrere Auswahlmöglichkeiten gegeben, multiple Handlungsstränge
-- gestartet werden. Mittels Sprüngen und Leerseiten kann innerhalb des
-- Dialog navigiert werden.
--
-- Das Dialogsystem soll eine Alternative zu den Briefings darstellen, denen
-- die Darstellung wie im Thronsaal zu "unpersönlich" ist.
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
-- @field DialogStarted        Ein Dialog beginnt (Parameter: PlayerID, DialogTable)
-- @field DialogEnded          Ein Dialog endet (Parameter: PlayerID, DialogTable)
-- @field DialogPageShown      Ein Dialog endet (Parameter: PlayerID, PageIndex)
-- @field DialogOptionSelected Eine Multiple Choice Option wurde ausgewählt (Parameter: PlayerID, OptionID)
--
-- @within Event
--
QSB.ScriptEvents = QSB.ScriptEvents or {};

---
-- Startet einen Dialog.
--
-- Die Funktion bekommt ein Table mit der Dialogdefinition, wenn sie
-- aufgerufen wird.
--
-- <p>(→ Beispiel #1)</p>
--
-- Für einen Dialog können verschiedene spezielle Einstellungen vorgenommen
-- werden.<br>Mögliche Werte:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Starting</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die beim Start des Dialog ausgeführt wird.<br>
-- Wird (im globalen Skript) vor QSB.ScriptEvents.DialogStarted aufgerufen!
-- </td>
-- </tr>
-- <tr>
-- <td>Finished</td>
-- <td>function</td>
-- <td>(Optional) Eine Funktion, die nach Beendigung des Dialog ausgeführt wird.<br>
-- Wird (im globalen Skript) nach QSB.ScriptEvents.DialogEnded aufgerufen!
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
-- <td>(Optional) Alle Einheiten und Gebäude werden unverwundbar solange der Dialog aktiv ist. <br>Standard: ein</td>
-- </tr>
-- <tr>
-- <td>EnableFoW</td>
-- <td>boolean</td>
-- <td>(Optional) Der Nebel des Krieges während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- <tr>
-- <td>EnableBorderPins</td>
-- <td>boolean</td>
-- <td>(Optional) Die Grenzsteine während des Dialog anzeigen. <br>Standard: aus</td>
-- </tr>
-- </table>
--
-- @param[type=table]  _Dialog   Definition des Dialog
-- @param[type=string] _Name     Name des Dialog
-- @param[type=number] _PlayerID Empfänger des Dialog
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel #1: Grobes Gerüst eines Briefings
-- function Dialog1(_Name, _PlayerID)
--     local Dialog = {
--         DisableFow = true,
--         DisableBoderPins = true,
--     };
--     local AP, ASP = API.AddDialogPages(Dialog);
--
--     -- Aufrufe von AP oder ASP um Seiten zu erstellen
--
--     Dialog.Starting = function(_Data)
--         -- Mach was tolles hier, wenn es anfängt.
--     end
--     Dialog.Finished = function(_Data)
--         -- Mach was tolles hier, wenn es endet.
--     end
--     API.StartDialog(Dialog, _Name, _PlayerID);
-- end
--
function API.StartDialog(_Dialog, _Name, _PlayerID)
    if GUI then
        return;
    end
    local PlayerID = _PlayerID;
    if not PlayerID and not Framework.IsNetworkGame() then
        PlayerID = QSB.HumanPlayerID;
    end
    assert(_Name ~= nil);
    assert(_PlayerID ~= nil);
    if type(_Dialog) ~= "table" then
        error("API.StartDialog (" .._Name.. "): _Dialog must be a table!");
        return;
    end
    if #_Dialog == 0 then
        error("API.StartDialog (" .._Name.. "): _Dialog does not contain pages!");
        return;
    end
    for i=1, #_Dialog do
        if type(_Dialog[i]) == "table" and not _Dialog[i].__Legit then
            error("API.StartDialog (" .._Name.. ", Page #" ..i.. "): Page is not initialized!");
            return;
        end
    end
    if _Dialog.EnableSky == nil then
        _Dialog.EnableSky = true;
    end
    if _Dialog.EnableFoW == nil then
        _Dialog.EnableFoW = false;
    end
    if _Dialog.EnableGlobalImmortality == nil then
        _Dialog.EnableGlobalImmortality = true;
    end
    if _Dialog.EnableBorderPins == nil then
        _Dialog.EnableBorderPins = false;
    end
    if _Dialog.RestoreGameSpeed == nil then
        _Dialog.RestoreGameSpeed = true;
    end
    if _Dialog.RestoreCamera == nil then
        _Dialog.RestoreCamera = true;
    end
    ModuleDialogSystem.Global:StartDialog(_Name, PlayerID, _Dialog);
end

---
-- Prüft ob für den Spieler gerade ein Dialog aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=boolean] Dialog ist aktiv
-- @within Anwenderfunktionen
--
function API.IsDialogActive(_PlayerID)
    if API.GetScriptEnvironment() == QSB.Environment.GLOBAL then
        return ModuleDialogSystem.Global:GetCurrentDialog(_PlayerID) ~= nil;
    end
    return ModuleDialogSystem.Local:GetCurrentDialog(_PlayerID) ~= nil;
end

---
-- Erzeugt die Funktionen zur Erstellung von Seiten in einem Dialog und bindet
-- sie an selbigen. Diese Funktion muss vor dem Start eines Dialog aufgerufen
-- werden um Seiten hinzuzufügen.
--
-- @param[type=table] _Dialog Dialog Definition
-- @return[type=function] <a href="#AP">AP</a>
-- @return[type=function] <a href="#ASP">ASP</a>
-- @within Anwenderfunktionen
--
-- @usage
-- -- Wenn nur AP benötigt wird.
-- local AP = API.AddPages(Dialog);
-- -- Wenn zusätzlich ASP benötigt wird.
-- local AP, ASP = API.AddPages(Dialog);
--
function API.AddDialogPages(_Dialog)
    ModuleDialogSystem.Global:CreateDialogGetPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddMCPage(_Dialog);
    ModuleDialogSystem.Global:CreateDialogAddRedirect(_Dialog);

    local AP = function(_Page)
        local Page;
        if type(_Page) == "table" then
            if _Page.MC then
                Page = _Dialog:AddMCPage(_Page);
            else
                Page = _Dialog:AddPage(_Page);
            end
        else
            Page = _Dialog:AddRedirect(_Page);
        end
        return Page;
    end

    local ASP = function(...)
        if type(arg[1]) ~= "number" then
            Name = table.remove(arg, 1);
        end
        local Sender   = table.remove(arg, 1);
        local Position = table.remove(arg, 1);
        local Title    = table.remove(arg, 1);
        local Text     = table.remove(arg, 1);
        local Dialog   = table.remove(arg, 1);
        local Action;
        if type(arg[1]) == "function" then
            Action = table.remove(arg, 1);
        end
        return _Dialog:AddPage{
            Name         = Name,
            Title        = Title,
            Text         = Text,
            Actor        = Sender,
            Target       = Position,
            DialogCamera = Dialog == true,
            Action       = Action,
        };
    end
    return AP, ASP;
end

---
-- Erstellt eine Seite für einen Dialog.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- <h5>Dialog Page</h5>
-- Eine Dialog Page stellt den gesprochenen Text mit und ohne Akteur dar.
--
-- <p>(→ Beispiel #1)</p>
-- 
-- Mögliche Felder:
-- <table border="1">
-- <tr>
-- <td><b>Einstellung</b></td>
-- <td><b>Typ</b></td>
-- <td><b>Beschreibung</b></td>
-- </tr>
-- <tr>
-- <td>Actor</td>
-- <td>number</td>
-- <td>(optional) Spieler-ID des Akteur</td>
-- </tr>
-- <tr>
-- <td>Titel</td>
-- <td>string</td>
-- <td>(optional) Zeigt den Namen des Sprechers an. (Nur mit Akteur)</td>
-- </tr>
-- <tr>
-- <td>Text</td>
-- <td>string</td>
-- <td>(optional) Zeigt Text auf der Dialogseite an.</td>
-- </tr>
-- <tr>
-- <td>Action</td>
-- <td>function</td>
-- <td>(optional) Führt eine Funktion aus, wenn die aktuelle Dialogseite angezeigt wird.</td>
-- </tr>
-- <tr>
-- <td>Position</td>
-- <td>any (string|number|table)</td>
-- <td>Legt die Kameraposition der Seite fest.</td>
-- </tr>
-- <tr>
-- <td>Target</td>
-- <td>any (string|number)</td>
-- <td>Legt das Entity fest, dem die Kamera folgt.</td>
-- </tr>
-- <tr>
-- <td>Distance</td>
-- <td>number</td>
-- <td>(optional) Bestimmt die Entfernung der Kamera zur Position.</td>
-- </tr>
-- <tr>
-- <td>Rotation</td>
-- <td>number</td>
-- <td>(optional) Rotationswinkel der Kamera. Werte zwischen 0 und 360 sind möglich.</td>
-- </tr>
-- <tr>
-- <td>MC</td>
-- <td>table</td>
-- <td>(optional) Table mit möglichen Dialogoptionen. (Multiple Choice)</td>
-- </tr>
-- <tr>
-- <td>FadeIn</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Einblendens von Schwarz zu Beginn der Page.<br>
-- Die Page benötigt eine Anzeigedauer!</td>
-- </tr>
-- <tr>
-- <td>FadeOut</td>
-- <td>number</td>
-- <td>(Optional) Dauer des Abblendens zu Schwarz am Ende der Page.<br>
-- Die Page benötigt eine Anzeigedauer!</td>
-- </tr>
-- <tr>
-- <td>FaderAlpha</td>
-- <td>number</td>
-- <td>(Optional) Zeigt entweder die Blende an (1) oder nicht (0). Per Default
-- wird die Blende nicht angezeigt. <br><b>Zwischen einer Seite mit FadeOut und
-- der nächsten mit FadeIn muss immer eine Seite mit FaderAlpha sein!</b></td>
-- </tr>
-- </table>
--
-- <br><h5>Multiple Choice</h5>
-- In einem Dialog kann der Spieler auch zur Auswahl einer Option gebeten
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
-- Um den Dialog zu beenden, nachdem ein Pfad beendet ist, wird eine leere
-- AP-Seite genutzt. Auf diese Weise weiß der Dialog, das er an dieser
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
-- <p>(→ Beispiel #7)</p>
--
-- Die zurückgegebene Zahl ist die ID der Antwort, angefangen von oben. Wird 0
-- zurückgegeben, wurde noch nicht geantwortet.
--
-- @param[type=table] _Page Spezifikation der Seite
-- @return[type=table] Refernez auf die angelegte Seite
-- @within Dialog
--
-- @usage
-- -- Beispiel #1: Eine einfache Seite erstellen
-- AP {
--     Title        = "Hero",
--     Text         = "This page has an actor and a choice.",
--     Actor        = 1,
--     Duration     = 2,
--     FadeIn       = 2,
--     Position     = "npc1",
--     DialogCamera = true,
-- };
--
-- @usage
-- -- Beispiel #2: Verwendung von Multiple Choice
-- AP {
--     Title        = "Hero",
--     Text         = "This page has an actor and a choice.",
--     Actor        = 1,
--     Duration     = 2,
--     FadeIn       = 2,
--     Position     = "npc1",
--     DialogCamera = true,
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
-- -- Beispiel #5: Abbruch des Dialog
-- AP()
--
-- @usage
-- -- Beispiel #6: Sprung zu anderer Seite
-- AP("SomePageName")
--
-- @usage
-- -- Beispiel #7: Erfragen der gewählten Antwort
-- Dialog.Finished = function(_Data)
--     local Choosen = _Data:GetPage("Choice"):GetSelected();
--     -- In Choosen steht der Index der Antwort
-- end
-- 
--
function AP(_Data)
    assert(false);
end

---
-- Erstellt eine Seite in vereinfachter Syntax. Es wird davon ausgegangen, dass
-- das Entity ein Siedler ist. Die Kamera schaut den Siedler an.
--
-- <b>Achtung</b>: Diese Funktion wird von
-- <a href="#API.AddPages">API.AddDialogPages</a> erzeugt und an
-- den Dialog gebunden.
--
-- @param[type=string]   _Name         (Optional) Name der Seite
-- @param[type=number]   _Sender       Spieler-ID des Akteur
-- @param[type=string]   _Target       Entity auf die die Kamera schaut
-- @param[type=string]   _Title        Name des Sprechers
-- @param[type=string]   _Text         Text der Seite
-- @param[type=boolean]  _DialogCamera Nahsicht an/aus
-- @param[type=function] _Action       (Optional) Callback-Funktion
-- @return[type=table] Referenz auf die Seite
-- @within Dialog
--
-- @usage
-- -- Beispiel ohne Page Name
-- ASP(1, "hans", "Hans", "Ich gehe in die weitel Welt hinein.", true);
-- -- Beispiel mit Page Name
-- ASP("Page1", 1, "hans", "Hans", "Ich gehe in die weitel Welt hinein.", true);
--
function ASP(...)
    assert(false);
end

