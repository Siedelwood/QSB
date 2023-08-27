
---
-- Erzeugt die Funktionen zur Erstellung von Flights in einer Cutsceme und
-- bindet sie an die Cutscene. Diese Funktion muss vor dem Start einer
-- Cutscene aufgerufen werden um Flights hinzuzufügen.
-- <ul>
-- <li><a href="#AF">AF</a></li>
-- </ul>
--
-- <b>Alias</b>: AddFlights
--
-- <b>QSB:</b> API.AddCutscenePages(_Cutscene)
--
-- @param[type=table] _Cutscene Cutscene Definition
-- @return[type=function] <a href="#AF">AF</a>
-- @within QSB_3_CutsceneSystem
--
function API.AddFlights(_Cutscene)
    if GUI then
        return;
    end
    return API.AddCutscenePages(_Cutscene);
end
AddFlights = API.AddFlights;

---
-- Startet eine Cutscene.
--
-- Die einzelnen Flights einer Cutscene werden als CS-Dateien definiert.
--
-- Eine Cutscene besteht aus den einzelnen Kameraflügen, also Flights, und
-- speziellen Feldern, mit denen weitere Einstellungen gemacht werden können.
-- Siehe dazu auch das Briefing System für einen Vergleich.
--
-- Die Funktion gibt die ID der Cutscene zurück, mit der geprüft werden kann,
-- ob die Cutscene beendet ist.
-- 
-- <b>Alias</b>: StartCutscene
--
-- <b>QSB:</b> API.StartCutscene(_Cutscene, _Name, _PlayerID)
--
-- @param[type=table]   _Cutscene Cutscene table
-- @return[type=number] ID der Cutscene
-- @within QSB_3_CutsceneSystem
--
function API.CutsceneStart(_Cutscene)
    if GUI then
        warn("API.CutsceneStart: Cannot start cutscene from local script!");
        return;
    end
    return API.StartCutscene(_Cutscene, tostring(_Cutscene), 1)
end
StartCutscene = API.CutsceneStart;