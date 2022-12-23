function StartScript()
    FocusCameraOnMeetingPlace();
end

function FocusCameraOnMeetingPlace()
    API.AddScriptEventListener(
        QSB.ScriptEvents.LoadscreenClosed,
        function()
            local pos = GetPosition("q01_meetingpoint");
            Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
            Camera.RTS_SetRotationAngle(-90);
            Camera.RTS_SetZoomFactor(0.2);
        end
    );
end

function ResetNormalCamera()
    local pos = GetPosition(Logic.GetKnightID(1));
    Camera.RTS_SetLookAtPosition(pos.X, pos.Y);
    Camera.RTS_SetRotationAngle(-90);
    Camera.RTS_SetZoomFactor(0.5);
end

