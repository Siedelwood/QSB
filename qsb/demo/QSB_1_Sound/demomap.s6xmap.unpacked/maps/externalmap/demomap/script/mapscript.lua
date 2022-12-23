function StartScript()
    API.StartDelay(5,  TestSetSound);
    API.StartDelay(10, TestStartPlaylist);
    API.StartDelay(40, TestStopPlaylist);
    API.StartDelay(45, TestPlay2DSound);
    API.StartDelay(50, TestPlay3DSound);
    API.StartDelay(55, TestPlayVoice);
    API.StartDelay(90, TestStopVoice);
    API.StartDelay(95, TestResetSound);
end

function TestSetSound()
    Logic.DEBUG_AddNote("Sound wird umgestellt.");
    API.SoundSetVolume(100);
    API.SoundSetMusicVolume(35);
    API.SoundSetVoiceVolume(35);
    API.SoundSetAtmoVolume(35);
    API.SoundSetUIVolume(35);
end

function TestResetSound()
    Logic.DEBUG_AddNote("Sound wird zurückgesetzt.");
    Logic.DEBUG_AddNote("ENDE!");
    API.SoundRestore();
end

function TestStartPlaylist()
    Logic.DEBUG_AddNote("Playlist wird gestartet.");
    API.StartEventPlaylist("config/sound/demoplaylist.xml", 1);
end

function TestStopPlaylist()
    Logic.DEBUG_AddNote("Playlist wird beendet.");
    API.StopEventPlaylist("config/sound/demoplaylist.xml", 1);
end

function TestPlay2DSound()
    Logic.DEBUG_AddNote("2D-Sound wird abgespielt.");
    API.Play2DSound("ui/menu_left_gold_pay");
end

function TestPlay3DSound()
    Logic.DEBUG_AddNote("3D-Sound wird abgespielt.");
    local x,y = Logic.GetBuildingApproachPosition(Logic.GetHeadquarters(1));
    API.Play3DSound("Animals/cow_disease", x, y, 2000);
end

function TestPlayVoice()
    Logic.DEBUG_AddNote("Starte Thordals Gesang als Stimme.");
    API.PlayVoice("music/thordal_song_the_warrior.mp3")
end

function TestStopVoice()
    Logic.DEBUG_AddNote("Beende Thordals Gesang.");
    API.StopVoice();
end

