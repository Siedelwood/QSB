# Module <code>qsb_4_questjournal</code>
Stellt Behavior bereit um die Tagebuchfunktion über den Assistenten nutzbar
 zu machen.




### Reprisal_JournaHighlight (_QuestName, _EntryName, _Highlighted)
source/qsb_4_questjournal.lua.html#292

Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.





### Reprisal_JournalEnable (_QuestName, _Active)
source/qsb_4_questjournal.lua.html#22

Zeigt das Tagebuch für einen Quest an oder versteckt es.





### Reprisal_JournalRemove (_QuestName, _EntryName)
source/qsb_4_questjournal.lua.html#199

Entfernt einen Tagebucheintrag von einem Quest.





### Reprisal_JournalWrite (_QuestName, _EntryName, _EntryText)
source/qsb_4_questjournal.lua.html#101

Schreibt einen Tagebucheintrag zu dem angegebenen Quest.





### Reward_JournaHighlight (_QuestName, _EntryName, _Highlighted)
source/qsb_4_questjournal.lua.html#363

Hebt einen Eintrag im Tagebuch hervor oder setzt ihn auf normal zurück.





### Reward_JournalEnable (_QuestName, _Active)
source/qsb_4_questjournal.lua.html#74

Zeigt das Tagebuch für einen Quest an oder versteckt es.





### Reward_JournalRemove (_QuestName, _EntryName)
source/qsb_4_questjournal.lua.html#265

Entfernt einen Tagebucheintrag von einem Quest.





### Reward_JournalWrite (_QuestName, _EntryName, _EntryText)
source/qsb_4_questjournal.lua.html#173

Schreibt einen Tagebucheintrag zu dem angegebenen Quest.





### QSB.ScriptEvents
source/qsb_4_questjournal.lua.html#405

Events, auf die reagiert werden kann.





### API.AddJournalEntryToQuest (_ID, _Quest)
source/qsb_4_questjournal.lua.html#603

Fügt einen Tagebucheintrag zu einem Quest hinzu.





### Beispiel:
<ul>


<pre class="example">API.AddJournalEntryToQuest(_ID, _Quest);</pre>


</ul>


### API.AllowNotesForQuest (_Quest, _Flag)
source/qsb_4_questjournal.lua.html#452

Aktiviert die Möglichkeit, selbst Notizen zu schreiben.

 <b>Hinweis</b>: Die Zusatzinformationen müssen für den Quest aktiv sein.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Deaktivieren
</span>API.AllowNotesForQuest(<span class="string">"MyQuest"</span>, <span class="keyword">false</span>);
<span class="comment">-- Aktivieren
</span>API.AllowNotesForQuest(<span class="string">"MyQuest"</span>, <span class="keyword">true</span>);</pre>


</ul>


### API.AlterJournalEntry (_ID, _Text)
source/qsb_4_questjournal.lua.html#503

Ändert den Text einer Zusatzinformation.

 <b>Hinweis</b>: Der neue Text bezieht sich auf den Eintrag mit der ID. Ist
 der Eintrag für alle Quests sichtbar, wird er in allen Quests geändert.
 Kopien eines Eintrags werden nicht berücksichtigt.

 <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.






### Beispiel:
<ul>


<pre class="example">API.AlterJournalEntry(SomeEntryID, <span class="string">"Das ist der neue Text."</span>);</pre>


</ul>


### API.CreateJournalEntry (_Text)
source/qsb_4_questjournal.lua.html#481

Fugt eine Zusatzinformation für diesen Quests hinzu.

 <b>Hinweis</b>: Die erzeugte ID ist immer eindeutig für alle Einträge,
 ungeachtet ob sie einem Quest zugeordnet sind oder nicht.

 <b>Hinweis</b>: Der Questname kann durch nil ersetzt werden. In diesem Fall
 erscheint der Eintrag bei <i>allen</i> Quests (für die das Feature aktiviert
 ist). Und das so lange, bis er wieder gelöscht wird.

 <b>Hinweis</b>: Formatierungsbefehle sind deaktiviert.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> NewEntryID = API.CreateJournalEntry(<span class="string">"Wichtige Information zum Anzeigen"</span>);</pre>


</ul>


### API.DeleteJournalEntry (_ID)
source/qsb_4_questjournal.lua.html#558

Entfernt einen Eintrag aus den Zusatzinformationen.

 <b>Hinweis</b>: Ein Eintrag wird niemals wirklich gelöscht, sondern nur
 unsichtbar geschaltet.






### Beispiel:
<ul>


<pre class="example">API.DeleteJournalEntry(SomeEntryID);</pre>


</ul>


### API.HighlightJournalEntry (_ID, _Important)
source/qsb_4_questjournal.lua.html#533

Hebt einen Eintrag aus den Zusatzinformationen als wichtig hervor oder
 setzt ihn zurück.

 <b>Hinweis</b>: Wichtige Einträge erscheinen immer als erstes und sind durch
 rote Färbung hervorgehoben. Eigene Farben in einer Nachricht beeinträchtigen
 die rote hervorhebung.






### Beispiel:
<ul>


<pre class="example">API.HighlightJournalEntry(SomeEntryID, <span class="keyword">true</span>);</pre>


</ul>


### API.RemoveJournalEntryFromQuest (_ID, _Quest)
source/qsb_4_questjournal.lua.html#620

Entfernt einen Tagebucheintrag von einem Quest.





### Beispiel:
<ul>


<pre class="example">API.RemoveJournalEntryFromQuest(_ID, _Quest);</pre>


</ul>


### API.RestoreJournalEntry (_ID)
source/qsb_4_questjournal.lua.html#580

Stellt einen gelöschten Eintrag in den Zusatzinformationen wieder her.





### Beispiel:
<ul>


<pre class="example">API.RestoreJournalEntry(SomeEntryID);</pre>


</ul>


### API.ShowJournalForQuest (_Quest, _Flag)
source/qsb_4_questjournal.lua.html#427

Aktiviert oder Deaktiviert die Verfügbarkeit der Zusatzinformationen für den
 übergebenen Quest.

 <b>Hinweis</b>: Die Sichtbarkeit der Zusatzinformationen für einzelne Quests
 ist generell deaktiviert und muss explizit aktiviert werden.

 <b>Hinweis</b>: Der Button wird auch dann angezeigt, wenn es noch keine
 Zusatzinformationen für den Quest gibt.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Deaktivieren
</span>API.ShowJournalForQuest(<span class="string">"MyQuest"</span>, <span class="keyword">false</span>);
<span class="comment">-- Aktivieren
</span>API.ShowJournalForQuest(<span class="string">"MyQuest"</span>, <span class="keyword">true</span>);</pre>


</ul>


