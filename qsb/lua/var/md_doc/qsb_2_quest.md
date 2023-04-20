# Module <code>qsb_2_quest</code>
Aufträge können über das Skript erstellt werden.
 Normaler Weise werden Aufträge im Questassistenten erzeugt. Dies ist aber
 statisch und das Kopieren von Aufträgen ist nicht möglich. Wenn Aufträge
 im Skript erzeugt werden, verschwinden alle diese Nachteile. Aufträge
 können im Skript kopiert und angepasst werden. Es ist ebenfalls machbar,
 die Aufträge in Sequenzen zu erzeugen.</p>

<p> Außerdem können Aufträge ineinander verschachtelt werden. Diese sogenannten
 Nested Quests vereinfachen die Schreibweise und die Verlinkung der Aufträge.</p>

<p> <b>Befehle:</b><br>
 <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
 der Debug Mode aktiviert ist.</i><br>
 <table border="1">
 <tr>
 <td><b>Befehl</b></td>
 <td><b>Parameter</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>stop</td>
 <td>QuestName</td>
 <td>Unterbricht den angegebenen Quest.</td>
 </tr>
 <tr>
 <td>start</td>
 <td>QuestName</td>
 <td>Startet den angegebenen Quest.</td>
 </tr>
 <tr>
 <td>win</td>
 <td>QuestName</td>
 <td>Schließt den angegebenen Quest erfolgreich ab.</td>
 </tr>
 <tr>
 <td>fail</td>
 <td>QuestName</td>
 <td>Lässt den angegebenen Quest fehlschlagen</td>
 </tr>
 <tr>
 <td>restart</td>
 <td>QuestName</td>
 <td>Startet den angegebenen Quest neu.</td>
 </tr>
 </table></p>

<p> <h4>Bekannte Probleme</h4>
 Jede Voice Message - <b>Quests sind ebenfalls Voice Messages</b> - hat die
 Chance, dass die Message Queue des Spiels hängen bleibt und dann ein leeres
 Fenster mit dem Titel "Rhian over the Sea Chapell" angezeigt wird, welches
 das Portrait Window dauerhaft blockiert und verhindert, dass weitere Voice
 Messages - <b>auch Quests</b> - angezeigt werden können.</p>

<p> Es wird dringend geraten, Quests <b>ausschließlich</b> zur Darstellung von
 Aufgaben für den Spieler und für <b>nichts anderes</b> zu benutzen.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 <li><a href="modules.QSB_1_Requester.QSB_1_Requester.html">(1) Requester</a></li>
 </ul>

### QSB.SegmentResult
source/qsb_2_quest.lua.html#79

Die Abschlussarten eines Quest Segment.





### API.CreateNestedQuest (_Data)
source/qsb_2_quest.lua.html#212

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





### Verwandte Themen:
<ul>


<li><a href="qsb_2_quest.html#QSB.SegmentResult">QSB.SegmentResult</a></li>


<li><a href="qsb_2_quest.html#API.CreateQuest">API.CreateQuest</a></li>


</ul>



### Beispiel:
<ul>


<pre class="example">API.CreateNestedQuest {
    Name        = <span class="string">"MainQuest"</span>,
    Segments    = {
        {
            Suggestion  = <span class="string">"Wir benötigen einen höheren Titel!"</span>,

            Goal_KnightTitle(<span class="string">"Mayor"</span>),
        },
        {
            <span class="comment">-- Mit dem Typ Ignore wird ein Fehlschlag ignoriert.
</span>            Result      = QSB.SegmentResult.Ignore,

            Suggestion  = <span class="string">"Wir benötigen außerdem mehr Asche! Und das sofort..."</span>,
            Success     = <span class="string">"Geschafft!"</span>,
            Failure     = <span class="string">"Versagt!"</span>,
            Time        = <span class="number">3</span> * <span class="number">60</span>,

            Goal_Produce(<span class="string">"G_Gold"</span>, <span class="number">5000</span>),

            Trigger_OnQuestSuccess(<span class="string">"MainQuest@Segment1"</span>, <span class="number">1</span>),
            <span class="comment">-- Segmented Quest wird gewonnen.
</span>            Reward_QuestSuccess(<span class="string">"MainQuest"</span>),
        },
        {
            Suggestion  = <span class="string">"Dann versuchen wir es mit Eisen..."</span>,
            Success     = <span class="string">"Geschafft!"</span>,
            Failure     = <span class="string">"Versagt!"</span>,
            Time        = <span class="number">3</span> * <span class="number">60</span>,

            Trigger_OnQuestFailure(<span class="string">"MainQuest@Segment2"</span>),
            Goal_Produce(<span class="string">"G_Iron"</span>, <span class="number">50</span>),
        }
    },

    <span class="comment">-- Wenn ein Quest nicht das erwartete Ergebnis hat, Fehlschlag.
</span>    Reprisal_Defeat(),
    <span class="comment">-- Wenn alles erfüllt wird, ist das Spiel gewonnen.
</span>    Reward_VictoryWithParty(),
};</pre>


</ul>


### API.CreateQuest (_Data)
source/qsb_2_quest.lua.html#122

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





### Verwandte Themen:
<ul>


<a href="qsb_2_quest.html#API.CreateNestedQuest">API.CreateNestedQuest</a>


</ul>



### Beispiel:
<ul>


<pre class="example">API.CreateQuest {
    Name        = <span class="string">"UnimaginativeQuestname"</span>,
    Suggestion  = <span class="string">"Wir müssen das Kloster finden."</span>,
    Success     = <span class="string">"Dies sind die berümten Heilermönche."</span>,

    Goal_DiscoverPlayer(<span class="number">4</span>),
    Reward_Diplomacy(<span class="number">1</span>, <span class="number">4</span>, <span class="string">"EstablishedContact"</span>),
    Trigger_Time(<span class="number">0</span>),
}</pre>


</ul>


