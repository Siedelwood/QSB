function StartScript()
    gvMission.SermonCount = 0;
    gvMission.GovernMeFester = 0;
    CreatePromotionEventListener();
    CreateSermonEventListener();
end

-- Wenn eine Predigt gestarted wird, wird der Zähler erhöht.
-- Der Zähler wird in den Aufstiegsbedingungen verwendet.
function CreateSermonEventListener()
    API.AddScriptEventListener(
        QSB.ScriptEvents.SermonStarted,
        function(_PlayerID)
            if _PlayerID == 1 then
                gvMission.SermonCount = gvMission.SermonCount +1;
            end
        end
    );
end

-- Wenn der Spieler Baron wird, zeigen wir einen Auswahldialog an.
function CreatePromotionEventListener()
    API.AddScriptEventListener(
        QSB.ScriptEvents.KnightTitleChanged,
        function(_PlayerID, _TitleID)
            if _PlayerID == 1 and _TitleID == KnightTitles.Mayor then
                ShowPromotionParadigmaSelection();
            end
        end
    )
end

-- Nachdem der Spieler das erste Mal einen neuen Titel erhalten hat, wird
-- er aufgefordert, seinen Führungsstil zu wählen.
function ShowPromotionParadigmaSelection()
    -- Liste der auswählbaren Paradigmen
    local GovermentStyles = {"Militärisch", "Ökonomisch", "Gottesfürchtig"};

    -- Aktion nach Auswahl
    local Action = function(_Selected)
        -- Wir wollen uns an die Auswahl erinnern
        gvMission.GovernMeFester = _Selected;
        -- Sende Auswahl an globales Skript
        GUI.SendScriptCommand(string.format(
            "PromotionParadigmaSelectionCallback(%d)",
            _Selected
        ));
        -- Zeige Info Dialog
        API.DialogInfoBox(
            "Info",
            "Eure Prioritäten haben sich geändert! Schaut, welche Dinge "..
            "für den nächsten Titel zu leisten sind."
        )
    end

    -- Auswahldialog starten
    API.DialogSelectBox(
        "Führungsstil festlegen",
        "Entscheidet Euch für einen Weg, wie Eure Herrschaft zukünftig "..
        "verlaufen soll.",
        Action,
        GovermentStyles
    );
end

