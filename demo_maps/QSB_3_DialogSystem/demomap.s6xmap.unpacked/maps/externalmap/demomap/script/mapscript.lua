function StartScript()
    API.SetPlayerPortrait(1);
    API.SetPlayerPortrait(8, "H_NPC_Monk_ME");
end

-- DIESE DEMO MAP IST NOCH NICHT FERTIG!!!

-- > DialogTest([[Foo]], 1)
function DialogTest(_Name, _PlayerID)
    local Dialog = {
        EnableFoW = false,
        EnableBorderPins = false,
        RestoreGameSpeed = true,
        RestoreCamera = true,
    };
    local AP, ASP = API.AddDialogPages(Dialog);

    ASP(8, "npc1", "NPC", "I aren't done drowning you in useless text.", true);
    ASP(1, "npc1", "Hero", "Maybe I should make your fat neck spin...", true);

    Dialog.Starting = function(_Data)
    end
    Dialog.Finished = function(_Data)
    end
    API.StartDialog(Dialog, _Name, _PlayerID);
end

