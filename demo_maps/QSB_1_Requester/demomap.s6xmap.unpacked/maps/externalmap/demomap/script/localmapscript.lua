function StartScript()
end

function TestShowStartTestInfo()
    API.DialogInfoBox(
        1,
        "Info",
        "Gleich werden mehrere Dialogfenster mit sinnlosen Texten angezeigt.",
        nil
    );
end

function TestCreateRequesterWindows()
    API.DialogRequestBox(
        1,
        "Gedicht",
        "Rosen sind rot.",
        nil,
        false
    );

    API.DialogRequestBox(
        1,
        "Gedicht",
        "Veilchen sind blau.",
        nil,
        false
    );

    API.DialogRequestBox(
        1,
        "Gedicht",
        "Deine Mutter stinkt, das weiß ich ganz genau!",
        TestShowEndTestInfo,
        false
    );
end

function TestShowEndTestInfo()
    API.DialogInfoBox(
        1,
        "Info",
        "Du hast es überstanden!",
        -- Inline funktioniert auch. ;)
        function()
            GUI.SendScriptCommand("TestStartTextWindowDelay()");
        end
    );
end

