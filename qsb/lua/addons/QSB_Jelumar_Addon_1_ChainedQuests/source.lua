-- -------------------------------------------------------------------------- --

AddOnChainedQuests = {
    Properties = {
        Name = "AddOnChainedQuests",
    },

    Global = {
        Data = {
            DefaultDelay = 10,
        },
    },
    Local = {
        Data = {},
    },
}

-- Global Script ---------------------------------------------------------------

---
-- Initalisiert das Bundle im globalen Skript.
--
-- @within Private
-- @local
--
function AddOnChainedQuests.Global:OnGameStart()

end

function AddOnChainedQuests.Global:SetDefaultDelay(_Delay)
    self.Data.DefaultDelay = _Delay
end

function AddOnChainedQuests.Global:CreateChainedQuest(_Data)
    if not _Data.Segments then
        return;
    end

    _Data.Visible = false
    local lastSegmentName = _Data.Segments[#_Data.Segments].Name or _Data.Name .. "@Segment" .. #_Data.Segments
    table.insert(_Data, Goal_WinQuest(lastSegmentName))
    API.CreateQuest(_Data)

    local triggerQuest = nil
    local ignore = nil
    local segment = nil
    for i= 1, #_Data.Segments, 1 do
        segment = _Data.Segments[i]
        self:CreateSegmentForChainedQuest(segment, _Data.Name, i, triggerQuest, ignore)
        triggerQuest = segment.Name or _Data.Name .. "@Segment" .. i
        ignore = (segment.Result == QSB.SegmentResult.Ignore)
    end
end

function AddOnChainedQuests.Global:CreateSegmentForChainedQuest(_Data, _ParentName, _Index, _TriggerQuest, _Ignore)
    local Name = _Data.Name or _ParentName.. "@Segment" .._Index
    local Parent = Quests[GetQuestID(_ParentName)]

    local QuestDescription = {
        Name        = Name,
        Result      = _Data.Result or QSB.SegmentResult.Success,
        Sender      = _Data.Sender or Parent.SendingPlayer,
        Receiver    = _Data.Receiver or Parent.ReceivingPlayer,
        Time        = _Data.Time,
        Suggestion  = _Data.Suggestion,
        Success     = _Data.Success,
        Failure     = _Data.Failure,
        Description = _Data.Description,
        Loop        = _Data.Loop,
        Callback    = _Data.Callback,
    }
    for i= 1, #_Data do
        table.insert(QuestDescription, _Data[i])
    end

    table.insert(QuestDescription, Trigger_OnQuestActive(_ParentName, 0))
    if _Data.Result ~= QSB.SegmentResult.Ignore then
        table.insert(QuestDescription, Reprisal_QuestFailure(_ParentName))
    end
    if _TriggerQuest ~= nil then
        if _Ignore then
            table.insert(QuestDescription, Trigger_OnQuestOver(_TriggerQuest, _Data.Delay or self.Data.DefaultDelay))
        else
            table.insert(QuestDescription, Trigger_OnQuestSuccess(_TriggerQuest, _Data.Delay or self.Data.DefaultDelay))
        end
    end
    API.CreateQuest(QuestDescription)
end

-- Local Script ----------------------------------------------------------------

---
-- Initalisiert das Bundle im lokalen Skript.
--
-- @within Private
-- @local
--
function AddOnChainedQuests.Local:OnGameStart()

end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(AddOnChainedQuests);