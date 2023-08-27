
---
-- Dieses Addon erlaubt es Questketten zu erzeugen
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="qsb.html">(0) Basismodul</a></li>
-- </ul>
--
-- @within Modulbeschreibung
-- @set sort=true
-- @author Jelumar
--

API = API or {}

---
-- Erzeugt eine Questkette. Diese Quests werden alle in Folge ausgeführt, wobei die
-- jeweils nächste Quest erst nach erfolg der aktuellen startet (Kann auch so eingestellt
-- werden, dass ein nach Misserfolg die nächste trotzdem startet)
--
-- @param[type=table] _Data Daten zu der Questkette
-- @within Anwenderfunktionen
-- @see API.CreateQuest
--
-- @usage
-- API.CreateChainedQuest {
--     Name = "ChainedQuest",
--     Segments = { -- Segmente der Questkette
--         {
--             Suggestion = "Wir sollten etwas Holz sammeln!",
--
--             Goal_GoodAmount("G_Wood", 25, ">"), -- Jedes segment benötigt nur einen Goal da der Trigger der Erfolg der vorigen ist
--         },
--         {
--             Suggestion = "Nochmehr Holz, diesmal aber mit Zeitbeschränkung!",
--
--             Result = QSB.SegmentResult.Ignore, -- Nächstes Element der Chain wird auch ausgeführt bei Misserfolg
--             Time = 2 * 60,
--             Delay = 15,
--
--             Goal_GoodAmount("G_Wood", 35, ">"),
--         },
--         {
--             Suggestion = "Noch etwas Holz und wir haben es geschafft",
--
--             Goal_GoodAmount("G_Wood", 50, ">"),
--         },
--     },
--
--     Trigger_AlwaysActive(),  -- Trigger der Questkette
--     Reward_VictoryWithParty(), --Reward/Reprisal der gesamten Kette
-- }
function API.CreateChainedQuest(_Data)
    if GUI or type(_Data) ~= "table" then
        return
    end
    if _Data.Segments == nil or #_Data.Segments == 0 then
        error(string.format("API.CreateChainedQuest: Chained quest '%s' is missing it's segments!", tostring(_Data.Name)))
        return
    end
    if _Data.Name == nil then
        error("API.CreateChainedQuest: Chained quest is missing it's name!")
        return
    end
    return AddOnChainedQuests.Global:CreateChainedQuest(_Data)
end

---
-- Bestimmt die Wartezeit zum Start der nächsten Quest in der Questkette
--
-- @param[type=number] _Delay Wartezeit zur nächsten Quest der Kette
-- @within Anwenderfunktionen
--
-- @usage
-- -- Quests in einer Questkette sollen immer sofort nach der letzten starten
-- API.SetChainedQuestsDefaultDelay(0) 
--
function API.SetChainedQuestsDefaultDelay(_Delay)
    AddOnChainedQuests.Global:SetDefaultDelay(_Delay)
end
