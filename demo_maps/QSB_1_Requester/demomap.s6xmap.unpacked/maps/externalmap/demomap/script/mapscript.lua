function StartScript()
    API.StartDelay(5,  TestShowStartTestInfo);
    API.StartDelay(10, TestCreateRequesterWindows);
end

function TestShowStartTestInfo()
    Logic.ExecuteInLuaLocalState("TestShowStartTestInfo()");
end

function TestCreateRequesterWindows()
    Logic.ExecuteInLuaLocalState("TestCreateRequesterWindows()");
end

function TestStartTextWindowDelay()
    Logic.DEBUG_AddNote("Gleich kommt noch ein großes Textfenster.");
    API.StartDelay(5, TestZeigeTextWindowDelay);
end

function TestZeigeTextWindowDelay()
    local Text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr,"..
                 " sed diam nonumy eirmod tempor invidunt ut labore et dolore"..
                 " magna aliquyam erat, sed diam voluptua. At vero eos et"..
                 " accusam et justo duo dolores et ea rebum. Stet clita kasd"..
                 " gubergren, no sea takimata sanctus est Lorem ipsum dolor"..
                 " sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"..
                 " elitr, sed diam nonumy eirmod tempor invidunt ut labore et"..
                 " dolore magna aliquyam erat, sed diam voluptua. At vero eos"..
                 " et accusam et justo duo dolores et ea rebum. Stet clita"..
                 " kasd gubergren, no sea takimata sanctus est Lorem ipsum"..
                 " dolor sit amet.";
    API.TextWindow("Überschrift", Text, 1);
end

