### Reprisal_JournaHighlight (_QuestName, _EntryName, _Highlighted)

Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.

### Reprisal_JournalEnable (_QuestName, _Active)

Zeigt das Tagebuch für einen Quest an oder versteckt es.

### Reprisal_JournalRemove (_QuestName, _EntryName)

Entfernt einen Tagebucheintrag von einem Quest.

### Reprisal_JournalWrite (_QuestName, _EntryName, _EntryText)

Schreibt einen Tagebucheintrag zu dem angegebenen Quest.

### Reward_JournaHighlight (_QuestName, _EntryName, _Highlighted)

Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.

### Reward_JournalEnable (_QuestName, _Active)

Zeigt das Tagebuch für einen Quest an oder versteckt es.

### Reward_JournalRemove (_QuestName, _EntryName)

Entfernt einen Tagebucheintrag von einem Quest.

### Reward_JournalWrite (_QuestName, _EntryName, _EntryText)

Schreibt einen Tagebucheintrag zu dem angegebenen Quest.

### QSB.ScriptEvents

Events, auf die reagiert werden kann.

### API.AddJournalEntryToQuest (_ID, _Quest)

Fügt einen Tagebucheintrag zu einem Quest hinzu.

### API.AllowNotesForQuest (_Quest, _Flag)

Aktiviert die Möglichkeit, selbst Notizen zu schreiben.

 <b>Hinweis</b>: Die Zusatzinformationen müssen für den Quest aktiv sein.


### API.AlterJournalEntry (_ID, _Text)

Ändert den Text einer Zusatzinformation.

 <b>Hinweis</b>: Der neue Text bezieht sich auf den Eintrag mit der ID. Ist
 der Eintrag für alle Quests sichtbar, wird er in allen Quests geändert.
 Kopien eines Eintrags werden nicht berücksichtigt.

 <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.


### API.CreateJournalEntry (_Text)

Fugt eine Zusatzinformation für diesen Quests hinzu.

 <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
 ungeachtet ob sie einem Quest zugeordnet sind oder nicht.

 <b>Hinweis</b>: Der Questname kann durch nil ersetzt werden. In diesem Fall
 erscheint der Eintrag bei <i>allen</i> Quests (für die das Feature aktiviert
 ist). Und das so lange, bis er wieder gelöscht wird.

 <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.


### API.DeleteJournalEntry (_ID)

Entfernt einen Eintrag aus den Zusatzinformationen.

 <b>Hinweis</b>: Ein Eintrag wird niemals wirklich gelöscht, sondern nur
 unsichtbar geschaltet.


### API.HighlightJournalEntry (_ID, _Important)

Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
 setzt ihn zurück.

 <b>Hinweis</b>: Wichtige Einträge erscheinen immer als erstes und sind durch
 rote Färbung hervorgehoben. Eigene Farben in einer Nachricht beeinträchtigen
 die rote hervorhebung.


### API.RemoveJournalEntryFromQuest (_ID, _Quest)

Entfernt einen Tagebucheintrag von einem Quest.

### API.RestoreJournalEntry (_ID)

Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.

### API.ShowJournalForQuest (_Quest, _Flag)

Aktiviert oder Deaktiviert die Verfügbarkeit der Zusatzinformationen für den
 übergebenen Quest.

 <b>Hinweis</b>: Die Sichtbarkeit der Zusatzinformationen für einzelne Quests
 ist generell deaktiviert und muss explizit aktiviert werden.

 <b>Hinweis</b>: Der Button wird auch dann angezeigt, wenn es noch keine
 Zusatzinformationen für den Quest gibt.


