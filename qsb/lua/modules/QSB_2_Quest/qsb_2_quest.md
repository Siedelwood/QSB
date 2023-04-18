### QSB.SegmentResult

Die Abschlussarten eines Quest Segment.

### API.CreateNestedQuest (_Data)

Erstellt einen verschachtelten Auftrag.

 Verschachtelte Aufträge (Nested Quests) vereinfachen aufschreiben und
 zuordnen der zugeordneten Aufträge. Ein Nested Quest ist selbst unsichtbar
 und hat mindestens ein ihm untergeordnetes Segment. Die Segmente eines
 Nested Quest sind wiederum Quests.

 Du kannst für Segmente die gleichen Einträge setzen, wie bei gewöhnlichen
 Quests. Zudem kannst du auch ihnen einen Namen geben. Wenn du das nicht tust,
 werden sie automatisch benannt. Der Name setzt sich dann zusammen aus dem
 Namen des Nested Quest und ihrem Index (z.B. "ExampleName@Segment1").

 Segmente haben ein erwartetes Ergebnis. Für gewöhnlich ist dies auf Erfolg
 festgelegt. Du kanns es aber auch auf Fehlschlag ändern oder ganz ignorieren.
 Ein Nested Quest ist abgeschlossen, wenn alle Segmente mit ihrem erwarteten
 Ergebnis abgeschlossen wurden (Erfolg) oder mindestens einer ein anderes
 Ergebnis als erwartet hatte (Fehlschlag).

 Werden Status oder Resultat eines Quest über Funktionen verändert (zb.
 API.StopQuest oder "stop" Konsolenbefehl), dann werden die Segmente
 ebenfalls beeinflusst.

 Es ist nicht zwingend notwendig, einen Trigger für die Segmente zu setzen.
 Alle Segmente starten automatisch sobald der Nested Quest startet. Du kannst
 weitere Trigger zu Segmenten hinzufügen, um dieses Verhalten nach deinen
 Bedürfnissen abzuändern (z.B. auf ein vorangegangenes Segment triggern).

 Nested Quests können auch ineinander verschachtelt werden. Man kann also
 innerhalb eines verschachtelten Auftrags eine weitere Ebene Verschachtelung
 aufmachen.


### API.CreateQuest (_Data)

Erstellt einen Quest.

 Ein Auftrag braucht immer wenigstens ein Goal und einen Trigger um ihn
 erstellen zu können. Hat ein Quest keinen Namen, erhält er automatisch
 einen mit fortlaufender Nummerierung.

 Ein Quest besteht aus verschiedenen Eigenschaften und Behavior, die nicht
 alle zwingend gesetzt werden müssen. Behavior werden einfach nach den
 Eigenschaften nacheinander angegeben.
 <p><u>Eigenschaften:</u></p>
 <ul>
 <li>Name: Der eindeutige Name des Quests</li>
 <li>Sender: PlayerID des Auftraggeber (Default 1)</li>
 <li>Receiver: PlayerID des Auftragnehmer (Default 1)</li>
 <li>Suggestion: Vorschlagnachricht des Quests</li>
 <li>Success: Erfolgsnachricht des Quest</li>
 <li>Failure: Fehlschlagnachricht des Quest</li>
 <li>Description: Aufgabenbeschreibung (Nur bei Custom)</li>
 <li>Time: Zeit bis zu, Fehlschlag/Abschluss</li>
 <li>Loop: Funktion, die während der Laufzeit des Quests aufgerufen wird</li>
 <li>Callback: Funktion, die nach Abschluss aufgerufen wird</li>
 </ul>


