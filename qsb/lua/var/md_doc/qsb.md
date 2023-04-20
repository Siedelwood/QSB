# Module <code>qsb</code>
Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.




### API.StartJobByEventType (_EventType, _Function, ...)
source/qsb.lua.html#118

Erzeugt einen neuen Event-Job.

 <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
 können ResumeJob und YieldJob auf den Job angewendet werden.

 <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!

 <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
 Kopie angelegt um Speicherprobleme zu verhindern. Es handelt sich also um
 eine neue Table und keine Referenz!






### Beispiel:
<ul>


<pre class="example">API.StartJobByEventType(
    Events.LOGIC_EVENT_EVERY_SECOND,
    FunctionRefToCall
);</pre>


</ul>


### API.StartJob (_Function, ...)
source/qsb.lua.html#150

Führt eine Funktion ein mal pro Sekunde aus.  Die weiteren Argumente werden an
 die Funktion übergeben.

 Die Funktion kann als Referenz, Inline oder als String übergeben werden.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Führt eine Funktion nach 15 Sekunden aus.
</span>API.StartJob(<span class="keyword">function</span>(_Time, _EntityType)
    <span class="keyword">if</span> Logic.GetTime() &gt; _Time + <span class="number">15</span> <span class="keyword">then</span>
        MachWas(_EntityType);
        <span class="keyword">return</span> <span class="keyword">true</span>;
    <span class="keyword">end</span>
<span class="keyword">end</span>, Logic.GetTime(), Entities.U_KnightHealing)

<span class="comment">-- Startet einen Job
</span>StartSimpleJob(<span class="string">"MeinJob"</span>);</pre>


</ul>


### API.StartHiResJob (_Function, ...)
source/qsb.lua.html#174

Führt eine Funktion ein mal pro Turn aus.  Ein Turn entspricht einer 1/10
 Sekunde in der Spielzeit. Die weiteren Argumente werden an die Funktion
 übergeben.

 Die Funktion kann als Referenz, Inline oder als String übergeben werden.





### Verwandte Themen:
<ul>


<a href="qsb.html#API.StartJob">API.StartJob</a>


</ul>



### API.EndJob (_JobID)
source/qsb.lua.html#194

Beendet den Job mit der übergebenen ID endgültig.





### Beispiel:
<ul>


<pre class="example">API.EndJob(AnyJobID);</pre>


</ul>


### API.JobIsRunning (_JobID)
source/qsb.lua.html#215

Gibt zurück, ob der Job mit der übergebenen ID aktiv ist.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">if</span> API.JobIsRunning(AnyJobID) <span class="keyword">then</span>
    <span class="comment">-- Mach was
</span><span class="keyword">end</span>;</pre>


</ul>


### API.ResumeJob (_JobID)
source/qsb.lua.html#231

Aktiviert einen pausierten Job.





### Beispiel:
<ul>


<pre class="example">API.ResumeJob(AnyJobID);</pre>


</ul>


### API.YieldJob (_JobID)
source/qsb.lua.html#250

Pausiert einen aktivien Job.





### Beispiel:
<ul>


<pre class="example">API.YieldJob(AnyJobID);</pre>


</ul>


### API.StartDelay (_Waittime, _Function, ...)
source/qsb.lua.html#282

Wartet die angebene Zeit in Sekunden und führt anschließend die Funktion aus.

 Die Funktion kann als Referenz, Inline oder als String übergeben werden.

 <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
 Skript weiterläuft.






### Beispiel:
<ul>


<pre class="example">API.StartDelay(
    <span class="number">30</span>,
    <span class="keyword">function</span>()
        Logic.DEBUG_AddNote(<span class="string">"Zeit abgelaufen!"</span>);
    <span class="keyword">end</span>
)</pre>


</ul>


### API.StartHiResDelay (_Waittime, _Function, ...)
source/qsb.lua.html#324

Wartet die angebene Zeit in Turns und führt anschließend die Funktion aus.

 Die Funktion kann als Referenz, Inline oder als String übergeben werden.

 <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
 Skript weiterläuft.






### Beispiel:
<ul>


<pre class="example">API.StartHiResDelay(
    <span class="number">30</span>,
    <span class="keyword">function</span>()
        Logic.DEBUG_AddNote(<span class="string">"Zeit abgelaufen!"</span>);
    <span class="keyword">end</span>
)</pre>


</ul>


### API.StartRealTimeDelay (_Waittime, _Function, ...)
source/qsb.lua.html#367

Wartet die angebene Zeit in realen Sekunden und führt anschließend die
 Funktion aus.

 Die Funktion kann als Referenz, Inline oder als String übergeben werden.

 <b>Achtung</b>: Die Ausführung erfolgt asynchron. Das bedeutet, dass das
 Skript weiterläuft.






### Beispiel:
<ul>


<pre class="example">API.StartRealTimeDelay(
    <span class="number">30</span>,
    <span class="keyword">function</span>()
        Logic.DEBUG_AddNote(<span class="string">"Zeit abgelaufen!"</span>);
    <span class="keyword">end</span>
)</pre>


</ul>


### API.SaveCustomVariable (_Name, _Value)
source/qsb.lua.html#506

Speichert den Wert der Custom Variable im globalen und lokalen Skript.

 Des weiteren wird in beiden Umgebungen ein Event ausgelöst, wenn der Wert
 gesetzt wird. Das Event bekommt den Namen der Variable, den alten Wert und
 den neuen Wert übergeben.






### Beispiel:
<ul>


<pre class="example">API.SaveCustomVariable(<span class="string">"MyVariable"</span>, <span class="number">0</span>);</pre>


</ul>


### API.ObtainCustomVariable (_Name, _Default)
source/qsb.lua.html#520

Gibt den aktuellen Wert der Custom Variable zurück oder den Default-Wert.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Value = API.ObtainCustomVariable(<span class="string">"MyVariable"</span>, <span class="number">0</span>);</pre>


</ul>


### API.RegisterScriptEvent (_Name)
source/qsb.lua.html#11958

Legt ein neues Script Event an.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> EventID = API.RegisterScriptEvent(<span class="string">"MyNewEvent"</span>);</pre>


</ul>


### API.SendScriptEvent (_EventID, ...)
source/qsb.lua.html#11977

Sendet das Script Event mit der übergebenen ID und überträgt optional
 Parameter.

 <h5>Multiplayer</h5>
 Im Multiplayer kann diese Funktion nicht benutzt werden, um Script Events
 synchron oder asynchron aus dem lokalen im globalen Skript auszuführen.






### Beispiel:
<ul>


<pre class="example">API.SendScriptEvent(SomeEventID, Param1, Param2, ...);</pre>


</ul>


### API.BroadcastScriptEventToGlobal (_EventName, ...)
source/qsb.lua.html#11993

Triggerd ein Script Event im globalen Skript aus dem lokalen Skript.

 Das Event wird synchron für alle Spieler gesendet.






### Beispiel:
<ul>


<pre class="example">API.SendScriptEventToGlobal(<span class="string">"SomeEventName"</span>, Param1, Param2, ...);</pre>


</ul>


### API.SendScriptEventToGlobal (_EventName, ...)
source/qsb.lua.html#12017

Triggerd ein Script Event im globalen Skript aus dem lokalen Skript.

 Das Event wird asynchron für den kontrollierenden Spieler gesendet.






### Beispiel:
<ul>


<pre class="example">API.SendScriptEventToGlobal(<span class="string">"SomeEventName"</span>, Param1, Param2, ...);</pre>


</ul>


### API.ToBoolean (_Value)
source/qsb.lua.html#12890

Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.

 Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
 Alles andere als false.

 Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Bool = API.ToBoolean(<span class="string">"+"</span>)  <span class="comment">--&gt; Bool = true
</span><span class="keyword">local</span> Bool = API.ToBoolean(<span class="string">"1"</span>)  <span class="comment">--&gt; Bool = true
</span><span class="keyword">local</span> Bool = API.ToBoolean(<span class="number">1</span>)  <span class="comment">--&gt; Bool = true
</span><span class="keyword">local</span> Bool = API.ToBoolean(<span class="string">"no"</span>) <span class="comment">--&gt; Bool = false</span></pre>


</ul>


### API.DumpTable (_Table, _Name)
source/qsb.lua.html#12905

Schreibt ein genaues Abbild der Table ins Log.  Funktionen, Threads und
 Metatables werden als Adresse geschrieben.






### Beispiel:
<ul>


<pre class="example">Table = {<span class="number">1</span>, <span class="number">2</span>, <span class="number">3</span>, {a = <span class="keyword">true</span>}}
API.DumpTable(Table)</pre>


</ul>


### API.ReplaceEntity (_Entity, _Type, _NewOwner)
source/qsb.lua.html#549

Ersetzt ein Entity mit einem neuen eines anderen Typs.  Skriptname,
 Rotation, Position und Besitzer werden übernommen.

 Für Siedler wird automatisch die Tasklist TL_NPC_IDLE gesetzt, damit
 sie nicht versteinert in der Landschaft rumstehen.

 <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
 Spezialgebäuden kann eine Niederlage erfolgen.






### Beispiel:
<ul>


<pre class="example">API.ReplaceEntity(<span class="string">"Stein"</span>, Entities.XD_ScriptEntity)</pre>


</ul>


### API.SetEntityVulnerableFlag (_Entity, _Flag)
source/qsb.lua.html#575

Setzt das Entity oder das Battalion verwundbar oder unverwundbar.





### API.GetEntityHealth (_Entity)
source/qsb.lua.html#690

Gibt die relative Gesundheit des Entity zurück.

 <b>Hinweis</b>: Der Wert wird als Prozentwert zurückgegeben. Das bedeutet,
 der Wert liegt zwischen 0 und 100.






### API.ChangeEntityHealth (_Entity, _Health, _Relative)
source/qsb.lua.html#710

Setzt die Gesundheit des Entity.  Optional kann die Gesundheit relativ zur
 maximalen Gesundheit geändert werden.






### API.SetResourceAmount (_Entity, _StartAmount, _RefillAmount)
source/qsb.lua.html#758

Setzt die Menge an Rohstoffen und die durchschnittliche Auffüllmenge
 in einer Mine.





### Beispiel:
<ul>


<pre class="example">API.SetResourceAmount(<span class="string">"mine1"</span>, <span class="number">250</span>, <span class="number">150</span>);</pre>


</ul>


### API.GetRandomSettlerType ()
source/qsb.lua.html#840

Wählt aus einer festen Liste von Typen einen zufälligen Siedler-Typ aus.
 Es werden nur Stadtsiedler zurückgegeben. Sie können männlich oder
 weiblich sein.






### API.GetRandomMaleSettlerType ()
source/qsb.lua.html#853

Wählt aus einer Liste von Typen einen zufälligen männlichen Siedler aus.  Es
 werden nur Stadtsiedler zurückgegeben.






### API.GetRandomFemaleSettlerType ()
source/qsb.lua.html#865

Wählt aus einer Liste von Typen einen zufälligen weiblichen Siedler aus.  Es
 werden nur Stadtsiedler zurückgegeben.






### API.GetGroupLeader (_Entity)
source/qsb.lua.html#1260

Gibt den Leader des Soldaten zurück.





### API.GroupHeal (_Entity, _Amount)
source/qsb.lua.html#1279

Heilt das Entity um die angegebene Menge an Gesundheit.





### API.GroupHurt (_Entity, _Damage, _Attacker)
source/qsb.lua.html#1305

Verwundet ein Entity oder ein Battallion um die angegebene
 Menge an Schaden.  Bei einem Battalion wird der Schaden solange
 auf Soldaten aufgeteilt, bis er komplett verrechnet wurde.






### API.InteractiveObjectActivate (_ScriptName, _State)
source/qsb.lua.html#1358

Aktiviert ein Interaktives Objekt.





### API.InteractiveObjectDeactivate (_ScriptName)
source/qsb.lua.html#1375

Deaktiviert ein interaktives Objekt.





### API.SendCart (_Position, _PlayerID, _GoodType, _Amount, _CartOverlay, _IgnoreReservation, _Overtake)
source/qsb.lua.html#616

Sendet einen Handelskarren zu dem Spieler.  Startet der Karren von einem
 Gebäude, wird immer die Position des Eingangs genommen.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- API-Call
</span>API.SendCart(Logic.GetStoreHouse(<span class="number">1</span>), <span class="number">2</span>, Goods.G_Grain, <span class="number">45</span>)</pre>


</ul>


### API.CreateEntityName (_EntityID)
source/qsb.lua.html#786

Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
 Hat das Entity einen Namen, bleibt dieser unverändert und wird
 zurückgegeben.





### API.GetGameVersion ()
source/qsb.lua.html#2360

Gibt die Version des Spiels zurück.

 <b>Hinweis</b>: Unter der Version wird verstanden, ob das Originalspiel
 oder die History Edition gespielt wird. Zwischen den einzelnen Patches
 des Originalspiels oder der History Edition wird nicht unterschieden. Es
 wird die aktuellste Version vorausgesetzt.





### Verwandte Themen:
<ul>


<a href="qsb.html#QSB.GameVersion">QSB.GameVersion</a>


</ul>



### API.GetGameVariant ()
source/qsb.lua.html#2374

Gibt die Variante des Spiels zurück.

 <b>Hinweis</b>: Unter der Variante wird verstanden, ob das unveränderte
 Spiel oder der Community Patch gespielt wird.





### Verwandte Themen:
<ul>


<a href="qsb.html#QSB.GameVariant">QSB.GameVariant</a>


</ul>



### API.GetScriptEnvironment ()
source/qsb.lua.html#2388

Gibt die Skriptumgebung zurück.

 <b>Hinweis</b>: Unter dem Environment wird verstanden, ob es sich um das
 globale oder das lokale Skript handelt.





### Verwandte Themen:
<ul>


<a href="qsb.html#QSB.Environment">QSB.Environment</a>


</ul>



### API.IsHistoryEditionNetworkGame ()
source/qsb.lua.html#2403

Prüft, ob das laufende Spiel eine Multiplayerpartie in der History Edition
 ist.

 <b>Hinweis</b>: Es ist unmöglich, dass Original und History Edition in einer
 Partie aufeinander treffen, da die alten Server längst abgeschaltet und die
 Option zum LAN-Spiel in der HE nicht verfügbar ist.






### API.ShowTextInput (_PlayerID, _AllowDebug)
source/qsb.lua.html#13076

Offnet das Chatfenster für eine Eingabe.

 <b>Hinweis</b>: Im Multiplayer kann der Chat nicht über Skript gesteuert
 werden.






### API.ActivateDebugMode (_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
source/qsb.lua.html#13932

Aktiviert oder deaktiviert Optionen des Debug Mode.

 <b>Hinweis:</b> Du kannst alle Optionen unbegrenzt oft beliebig ein-
 und ausschalten.

 <ul>
 <li><u>Prüfung zum Spielbeginn</u>: <br>
 Quests werden auf konsistenz geprüft, bevor sie starten. </li>
 <li><u>Questverfolgung</u>: <br>
 Jede Statusänderung an einem Quest löst eine Nachricht auf dem Bildschirm
 aus, die die Änderung wiedergibt. </li>
 <li><u>Eintwickler Cheaks</u>: <br>
 Aktivier die Entwickler Cheats. </li>
 <li><u>Debug Chat-Eingabe</u>: <br>
 Die Chat-Eingabe kann zur Eingabe von Befehlen genutzt werden. </li>
 </ul>






### API.GetClosestToTarget (_Target, _List)
source/qsb.lua.html#880

Gibt das Entity aus der Liste zurück, welches dem Ziel am nähsten ist.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Clostest = API.GetClosestToTarget(<span class="string">"HQ1"</span>, {<span class="string">"Marcus"</span>, <span class="string">"Alandra"</span>, <span class="string">"Hakim"</span>});</pre>


</ul>


### API.GetPosition (_Entity)
source/qsb.lua.html#904

Lokalisiert ein Entity auf der Map.  Es können sowohl Skriptnamen als auch
 IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
 Tabelle mit XYZ = 0 zurückgegeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Position = API.GetPosition(<span class="string">"Hans"</span>);</pre>


</ul>


### API.SetPosition (_Entity, _Target)
source/qsb.lua.html#930

Setzt ein Entity auf eine neue Position





### Beispiel:
<ul>


<pre class="example">API.SetPosition(<span class="string">"Hans"</span>, <span class="string">"Horst"</span>);</pre>


</ul>


### API.IsValidPosition (_Pos)
source/qsb.lua.html#967

Prüft, ob eine Positionstabelle eine gültige Position enthält.

 Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
 Das ist der Fall bei negativen Werten oder Werten, welche die Größe
 der Welt übersteigen.






### API.GetDistance (_Pos1, _Pos2)
source/qsb.lua.html#998

Bestimmt die Distanz zwischen zwei Punkten.  Es können Entity-IDs,
 Skriptnamen oder Positionstables angegeben werden.

 Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Distance = API.GetDistance(<span class="string">"HQ1"</span>, Logic.GetKnightID(<span class="number">1</span>))</pre>


</ul>


### API.LookAt (_Entity, _Target, _Offset)
source/qsb.lua.html#1025

Rotiert ein Entity, sodass es zum Ziel schaut.





### Beispiel:
<ul>


<pre class="example">API.LookAt(<span class="string">"Hakim"</span>, <span class="string">"Alandra"</span>)</pre>


</ul>


### API.GetAngleBetween (_Pos1, _Pos2)
source/qsb.lua.html#1078

Bestimmt den Winkel zwischen zwei Punkten.  Es können Entity-IDs,
 Skriptnamen oder Positionstables angegeben werden.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Angle = API.GetAngleBetween(<span class="string">"HQ1"</span>, Logic.GetKnightID(<span class="number">1</span>))</pre>


</ul>


### API.GetGeometricFocus (...)
source/qsb.lua.html#1115

Bestimmt die Durchschnittsposition mehrerer Entities.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Center = API.GetGeometricFocus(<span class="string">"Hakim"</span>, <span class="string">"Marcus"</span>, <span class="string">"Alandra"</span>);</pre>


</ul>


### API.GetLinePosition (_Pos1, _Pos2, _Percentage)
source/qsb.lua.html#1146

Gib eine Position auf einer Linie im relativen Abstand zur ersten Position
 zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Position = API.GetLinePosition(<span class="string">"HQ1"</span>, <span class="string">"HQ2"</span>, <span class="number">0.75</span>);</pre>


</ul>


### API.GetLinePositions (_Pos1, _Pos2, _Periode)
source/qsb.lua.html#1185

Gib Positionen im gleichen Abstand auf der Linie zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> PositionList = API.GetLinePositions(<span class="string">"HQ1"</span>, <span class="string">"HQ2"</span>, <span class="number">6</span>);</pre>


</ul>


### API.GetCirclePosition (_Target, _Distance, _Angle)
source/qsb.lua.html#1205

Gibt eine Position auf einer Kreisbahn um einen Punkt zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Position = API.GetCirclePosition(<span class="string">"HQ1"</span>, <span class="number">3000</span>, -<span class="number">45</span>);</pre>


</ul>


### API.GetCirclePositions (_Target, _Distance, _Periode, _Offset)
source/qsb.lua.html#1240

Gibt Positionen im gleichen Abstand auf der Kreisbahn zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> PositionList = API.GetCirclePositions(<span class="string">"Position"</span>, <span class="number">3000</span>, <span class="number">6</span>, <span class="number">45</span>);</pre>


</ul>


### API.SetLogLevel (_ScreenLogLevel, _FileLogLevel)
source/qsb.lua.html#1516

Setzt, ab wann Log-Nachrichten geschrieben werden.

 Es wird zwischen der Ausgabe am Bildschirm und dem Wegschreiben ins Log
 unterschieden. Die Anzeige am Bildschirm kann strenger eingestellt sein,
 als das Speichern in der Log-Datei.

 Mögliche Level:
 <table border=1>
 <tr>
 <td><b>Name</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>QSB.LogLevel.ALL</td>
 <td>Alle Stufen ausgeben (Debug, Info, Warning, Error)</td>
 </tr>
 <tr>
 <td>QSB.LogLevel.INFO</td>
 <td>Erst ab Stufe Info ausgeben (Info, Warning, Error)</td>
 </tr>
 <tr>
 <td>QSB.LogLevel.WARNING</td>
 <td>Erst ab Stufe Warning ausgeben (Warning, Error)</td>
 </tr>
 <tr>
 <td>QSB.LogLevel.ERROR</td>
 <td>Erst ab Stufe Error ausgeben (Error)</td>
 </tr>
 <tr>
 <td>QSB.LogLevel.OFF</td>
 <td>Keine Meldungen ausgeben</td>
 </tr>
 </table>

 <b>Alias:</b> API.SetLoggingLevel






### Beispiel:
<ul>


<pre class="example">API.SetLogLevel(QSB.LogLevel.ERROR, QSB.LogLevel.WARNING);</pre>


</ul>


### ParameterType
source/qsb.lua.html#1916

Stellt wichtige Kernfunktionen bereit.

 <h5>Behobene Fehler</h5>

 Die QSB kommt mit einigen Bugfixes mit, die Fehler im Spiel beheben.

 <ul>
 <li>NPC-Lagerhäuser können jetzt Salz und Farbe einlagern.</li>
 <li>Die NPC-Kasernen von Mitteleuropa respawnen jetzt Soldaten.</li>
 <li>Werden Waren im Zuge eines Quests gesandt, wird bei den Zielgebäuden von
 der Position des Eingangs ausgegangen anstatt von der Gebäudemitte. Dadurch
 schlagen Lieferungen bei bestimmten Lagerhäusern nicht mehr fehl.</li>
 <li>Bei interaktiven Objekten können jetzt auch nur zwei Rohstoffe anstatt
 von Gold und einem Rohstoff als Kosten benutzt werden.</li>
 <li>Spezielle Script Entities werden bei Goal_DestroyAllPlayerUnids nicht
 mehr fälschlich mitgezählt.</li>
 </ul>

 <h5>Platzhalter</h5>

 <u>Mehrsprachige Texte:</u><br>
 Anstatt eines Strings wird ein Table mit dem gleichen Text in verschiedenen
 Sprachen angegeben. Der richtige Text wird anhand der eingestellten Sprache
 gewählt. Wenn nichts vorgegeben wird, ist die Systemsprache voreingestellt.
 Als Standard für nichtdeutsche Sprachen wird Englisch verwendet, wenn für
 die Sprache selbst kein Text vorhanden ist. Es muss also immer wenigstens
 English (en) und Deutsch (de) vorhanden sein. <br>
 Einige Features lokalisieren Texte automatisch. <br>
 (Siehe dazu: <a href="#API.Localize">API.Localize</a>)

 <u>Platzhalter in Texten:</u><br>
 In Texten können vordefinierte Farben, Namen für Entity-Typen und benannte
 Entities, sowie Inhalte von Variablen ersetzt werden. Dies wird von einigen
 QSB-Features automatisch vorgenommen. Es kann Mittels API-Funktion auch
 manuell angestoßen werden. <br>
 (Siehe dazu: <a href="#API.ConvertPlaceholders">API.ConvertPlaceholders</a>)

 <h5>Scripting Values</h5>
 Bei den Scripting Values handelt es sich um einige Werte, die direkt im
 Arbeitsspeicher manipuliert werden können und Auswirkungen auf Entities
 haben.<br>
 (Siehe dazu: <a href="#ScriptingValue">QSB.ScriptingValue</a>)

 <h5>Entwicklungsmodus</h5>

 Die QSB kann verschiedene Optionen zum schnelleren Testen und finden von
 fehlern aktivieren. <br>
 (Siehe dazu: <a href="#API.ActivateDebugMode">API.ActivateDebugMode</a>)

 <b>Befehle:</b><br>
 <i>Diese Befehle können über die Konsole (SHIFT + ^) eingegeben werden, wenn
 der Debug Mode aktiviert ist.</i><br>
 <table border="1">
 <tr>
 <td><b>Befehl</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>restartmap</td>
 <td>Map sofort neu starten</td>
 </tr>
 <tr>
 <td>&gt; Befehl</td>
 <td>Einen Lua Befehl im globalen Skript ausführen.
 (Die Zeichen " ' { } können nicht verwendet werden)</td>
 </tr>
 <tr>
 <td>&gt;&gt; Befehl</td>
 <td>Einen Lua Befehl im lokalen Skript ausführen.
 (Die Zeichen " ' { } können nicht verwendet werden)</td>
 </tr>
 <tr>
 <td>&lt; Pfad</td>
 <td>Lua-Datei zur Laufzeit ins globale Skript laden.
 (Es muss / anstatt \ verwendet werden)</td>
 </tr>
 <tr>
 <td>&lt;&lt; Pfad</td>
 <td>Lua-Datei zur Laufzeit ins lokale Skript laden.
 (Es muss / anstatt \ verwendet werden)</td>
 </tr>
 </table>

 <b>Cheats:</b><br>
 <i>Bei aktivierten Debug Mode können diese Cheat Codes verwendet werden.</i><br>
 <table border="1">
 <tr>
 <td><b>Cheat</b></td>
 <td><b>Beschreibung</b></td>
 </tr>
 <tr>
 <td>SHIFT + ^</td>
 <td>Konsole öffnen</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + ALT + R</td>
 <td>Map sofort neu starten.</td>
 </tr>
 <td>CTRL + C</td>
 <td>Zeitanzeige an/aus</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + A</td>
 <td>Clutter (Gräser) anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + C</td>
 <td>Grasobjekte anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + E</td>
 <td>Laubbäume anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + F</td>
 <td>FoW anzeigen (an/aus) <i>Gebiete werden dauerhaft erkundet!</i></td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + G</td>
 <td>GUI anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + H</td>
 <td>Steine und Tannen anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + R</td>
 <td>Straßen anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + S</td>
 <td>Schatten anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + T</td>
 <td>Boden anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + U</td>
 <td>FoW anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + W</td>
 <td>Wasser anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + X</td>
 <td>Render Mode des Wassers umschalten (Einfach und komplex)</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + Y</td>
 <td>Himmel anzeigen (an/aus)</td>
 </tr>
 <tr>
 <td>ALT + F10</td>
 <td>Selektiertes Gebäude anzünden</td>
 </tr>
 <tr>
 <td>ALT + F11</td>
 <td>Selektierte Einheit verwunden</td>
 </tr>
 <tr>
 <td>ALT + F12</td>
 <td>Alle Rechte freigeben / wieder sperren</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + 1</td>
 <td>FPS-Anzeige</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 4</td>
 <td>Bogenschützen unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 5</td>
 <td>Schwertkämpfer unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 6</td>
 <td>Katapultkarren unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 7</td>
 <td>Ramme unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 8</td>
 <td>Belagerungsturm unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 9</td>
 <td>Katapult unter der Maus spawnen</td>
 </tr>
 <tr>
 <td>(Num) +</td>
 <td>Spiel beschleunigen</td>
 </tr>
 <tr>
 <td>(Num) -</td>
 <td>Spiel verlangsamen</td>
 </tr>
 <tr>
 <td>(Num) *</td>
 <td>Geschwindigkeit zurücksetzen</td>
 </tr>
 <tr>
 <td>CTRL + F1</td>
 <td>+ 50 Gold</td>
 </tr>
 <tr>
 <td>CTRL + F2</td>
 <td>+ 10 Holz</td>
 </tr>
 <tr>
 <td>CTRL + F3</td>
 <td>+ 10 Stein</td>
 </tr>
 <tr>
 <td>CTRL + F4</td>
 <td>+ 10 Getreide</td>
 </tr>
 <tr>
 <td>CTRL + F5</td>
 <td>+ 10 Milch</td>
 </tr>
 <tr>
 <td>CTRL + F6</td>
 <td>+ 10 Kräuter</td>
 </tr>
 <tr>
 <td>CTRL + F7</td>
 <td>+ 10 Wolle</td>
 </tr>
 <tr>
 <td>CTRL + F8</td>
 <td>+ 10 auf alle Waren</td>
 </tr>
 <tr>
 <td>SHIFT + F1</td>
 <td>+ 10 Honig</td>
 </tr>
 <tr>
 <td>SHIFT + F2</td>
 <td>+ 10 Eisen</td>
 </tr>
 <tr>
 <td>SHIFT + F3</td>
 <td>+ 10 Fisch</td>
 </tr>
 <tr>
 <td>SHIFT + F4</td>
 <td>+ 10 Wild</td>
 </tr>
 <tr>
 <td>ALT + F5</td>
 <td>Bedürfnis nach Nahrung in Gebäude aktivieren</td>
 </tr>
 <tr>
 <td>ALT + F6</td>
 <td>Bedürfnis nach Kleidung in Gebäude aktivieren</td>
 </tr>
 <tr>
 <td>ALT + F7</td>
 <td>Bedürfnis nach Hygiene in Gebäude aktivieren</td>
 </tr>
 <tr>
 <td>ALT + F8</td>
 <td>Bedürfnis nach Unterhaltung in Gebäude aktivieren</td>
 </tr>
 <tr>
 <td>CTRL + F9</td>
 <td>Nahrung für selektiertes Gebäude erhöhen</td>
 </tr>
 <tr>
 <td>SHIFT + F9</td>
 <td>Nahrung für selektiertes Gebäude verringern</td>
 </tr>
 <tr>
 <td>CTRL + F10</td>
 <td>Kleidung für selektiertes Gebäude erhöhen</td>
 </tr>
 <tr>
 <td>SHIFT + F10</td>
 <td>Kleidung für selektiertes Gebäude verringern</td>
 </tr>
 <tr>
 <td>CTRL + F11</td>
 <td>Hygiene für selektiertes Gebäude erhöhen</td>
 </tr>
 <tr>
 <td>SHIFT + F11</td>
 <td>Hygiene für selektiertes Gebäude verringern</td>
 </tr>
 <tr>
 <td>CTRL + F12</td>
 <td>Unterhaltung für selektiertes Gebäude erhöhen</td>
 </tr>
 <tr>
 <td>SHIFT + F12</td>
 <td>Unterhaltung für selektiertes Gebäude verringern</td>
 </tr>
 <tr>
 <td>ALT + CTRL + F10</td>
 <td>Einnahmen des selektierten Gebäudes erhöhen</td>
 </tr>
 <tr>
 <td>ALT + (Num) 1</td>
 <td>Burg selektiert → Gold verringern, Werkstatt selektiert → Ware verringern</td>
 </tr>
 <tr>
 <td>ALT + (Num) 2</td>
 <td>Burg selektiert → Gold erhöhen, Werkstatt selektiert → Ware erhöhen</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 1</td>
 <td>Kontrolle über Spieler 1</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 2</td>
 <td>Kontrolle über Spieler 2</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 3</td>
 <td>Kontrolle über Spieler 3</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 4</td>
 <td>Kontrolle über Spieler 4</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 5</td>
 <td>Kontrolle über Spieler 5</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 6</td>
 <td>Kontrolle über Spieler 6</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 7</td>
 <td>Kontrolle über Spieler 7</td>
 </tr>
 <tr>
 <td>CTRL + ALT + 8</td>
 <td>Kontrolle über Spieler 8</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 0</td>
 <td>Kamera durchschalten</td>
 </tr>
 <tr>
 <td>CTRL + (Num) 1</td>
 <td>Kamerasprünge im RTS-Mode</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + V</td>
 <td>Territorien anzeigen</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + B</td>
 <td>Blocking anzeigen</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + N</td>
 <td>Gitter verstecken</td>
 </tr>
 <tr>
 <td>CTRL + SHIFT + F9</td>
 <td>DEBUG-Ausgabe einschalten</td>
 </tr>
 <tr>
 <td>ALT + F9</td>
 <td>Zufälligen Arbeiter verheiraten</td>
 </tr>
 </table>






### QSB.ScriptEvents
source/qsb.lua.html#1961

Events, um auf Ereignisse zu reagieren.

 <h5>Was sind Script Events</h5>

 Um dem Mapper das (z.T. fehlerbehaftete) Überschreiben von Game Callbacks
 oder anlegen von (echten) Triggern zu ersparen, wurden die Script Events
 eingeführt. Sie vereinheitlichen alle diese Operationen. Ein Event kann
 von einem Modul oder in den Skripten des Anwenders über einen Event Listener
 oder ein spezielles Game Callback gefangen werden.

 Ein Event zu fangen bedeutet auf ein eingetretenes Ereignis - z.B. Wenn ein
 Spielstand geladen wurde - zu reagieren. Events werden immer sowohl im
 globalen als auch lokalen Skript ausgelöst, wenn ein entsprechendes Ereignis
 aufgetreten ist, anstatt vieler Callbacks, die auf eine spezifische Umgebung
 beschränkt sind.

 Module bringen manchmal Events mit. Jedes Modul, welches ein neues Event
 einführt, wird es in seiner API-Beschreibung aufgführen.

 <u>Script Events, die von der QSB direkt bereitgestellt werden:</u>






### API.AddScriptEventListener (_EventID, _Function)
source/qsb.lua.html#12049

Erstellt einen neuen Listener für das Event.

 An den Listener werden die gleichen Parameter übergeben, die für das Event
 auch bei GameCallback_QSB_OnEventReceived übergeben werden.

 <b>Hinweis</b>: Event Listener für ein spezifisches Event werden nach
 GameCallback_QSB_OnEventReceived aufgerufen.





### Verwandte Themen:
<ul>


<a href="qsb.html#API.RemoveScriptEventListener">API.RemoveScriptEventListener</a>


</ul>



### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> ListenerID = API.AddScriptEventListener(QSB.ScriptEvents.SaveGameLoaded, <span class="keyword">function</span>()
    Logic.DEBUG_AddNote(<span class="string">"A save has been loaded!"</span>);
<span class="keyword">end</span>);</pre>


</ul>


### API.RemoveScriptEventListener (_EventID, _ID)
source/qsb.lua.html#12070

Entfernt einen Listener von dem Event.




### Verwandte Themen:
<ul>


<a href="qsb.html#API.AddScriptEventListener">API.AddScriptEventListener</a>


</ul>



### QSB.Environment
source/qsb.lua.html#1969

Konstanten der Script Environments





### QSB.GameVersion
source/qsb.lua.html#1980

Konstanten der Spielversionen





### QSB.GameVariant
source/qsb.lua.html#1991

Konstanten der Spielvarianten





### API.GetPlayerSlotID (_PlayerID)
source/qsb.lua.html#2418

Gibt den Slot zurück, den der Spieler einnimmt.  Hat der Spieler keinen
 Slot okkupiert oder ist nicht menschlich, wird -1 zurückgegeben.

 <h5>Multiplayer</h5>
 Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!






### API.GetSlotPlayerID (_SlotID)
source/qsb.lua.html#2442

Gibt den Spieler zurück, welcher den Slot okkupiert.  Hat der Slot keinen
 Spieler oder ist der Spieler nicht menschlich, wird -1 zurückgegeben.

 <h5>Multiplayer</h5>
 Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!






### API.GetActivePlayers ()
source/qsb.lua.html#2461

Gibt eine Liste aller Spieler im Spiel zurück.

 <h5>Multiplayer</h5>
 Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!






### API.GetDelayedPlayers ()
source/qsb.lua.html#2483

Gibt alle Spieler zurück, auf die gerade gewartet wird.

 <h5>Multiplayer</h5>
 Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!






### API.IsMultiplayerLoaded ()
source/qsb.lua.html#2502

Gibt zurück, ob die Sitzung geladen wurde.

 <h5>Multiplayer</h5>
 Nur für Multiplayer ausgelegt! Nicht im Singleplayer nutzen!






### API.GetQuestID (_Name)
source/qsb.lua.html#2616

Gibt die ID des Quests mit dem angegebenen Namen zurück.  Existiert der
 Quest nicht, wird nil zurückgegeben.






### API.IsValidQuest (_QuestID)
source/qsb.lua.html#2638

Prüft, ob zu der angegebenen ID ein Quest existiert.  Wird ein Questname
 angegeben wird dessen Quest-ID ermittelt und geprüft.






### API.IsValidQuestName (_Name)
source/qsb.lua.html#2650

Prüft den angegebenen Questnamen auf verbotene Zeichen.





### API.FailQuest (_QuestName, _NoMessage)
source/qsb.lua.html#2664

Lässt den Quest fehlschlagen.

 Der Status wird auf Over und das Resultat auf Failure gesetzt.






### API.RestartQuest (_QuestName, _NoMessage)
source/qsb.lua.html#2688

Startet den Quest neu.

 Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
 neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
 der Quest wird manuell getriggert.






### API.StartQuest (_QuestName, _NoMessage)
source/qsb.lua.html#2786

Startet den Quest sofort, sofern er existiert.

 Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.






### API.StopQuest (_QuestName, _NoMessage)
source/qsb.lua.html#2810

Unterbricht den Quest.

 Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
 gesetzt, werden diese entfernt.






### API.WinQuest (_QuestName, _NoMessage)
source/qsb.lua.html#2832

Gewinnt den Quest.

 Der Status wird auf Over und das Resultat auf Success gesetzt.






### Reward_DEBUG (_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
source/qsb.lua.html#3006

Aktiviert den Debug.




### Verwandte Themen:
<ul>


<a href="qsb.html#API.ActivateDebugMode">API.ActivateDebugMode</a>


</ul>



### Reward_ObjectDeactivate (_ScriptName)
source/qsb.lua.html#7279

Deaktiviert ein interaktives Objekt





### Reward_ObjectActivate (_ScriptName, _State)
source/qsb.lua.html#7313

Aktiviert ein interaktives Objekt.

 Der Status bestimmt, wie das objekt aktiviert wird.
 <ul>
 <li>0: Kann nur mit Helden aktiviert werden</li>
 <li>1: Kann immer aktiviert werden</li>
 <li>2: Kann niemals aktiviert werden</li>
 </ul>






### Reward_ObjectInit (_ScriptName, _Distance, _Time, _RType1, _RAmount, _CType1, _CAmount1, _CType2, _CAmount2, _Status)
source/qsb.lua.html#7352

Initialisiert ein interaktives Objekt.

 Interaktive Objekte können Kosten und Belohnungen enthalten, müssen sie
 jedoch nicht. Ist eine Wartezeit angegeben, kann das Objekt erst nach
 Ablauf eines Cooldowns benutzt werden.






### Reward_Diplomacy (_Party1, _Party2, _State)
source/qsb.lua.html#7547

Änder den Diplomatiestatus zwischen zwei Spielern.





### Reward_DiplomacyIncrease ()
source/qsb.lua.html#7572

Verbessert die diplomatischen Beziehungen zwischen Sender und Empfänger
 um einen Grad.





### Reward_TradeOffers (_PlayerID, _Amount1, _Type1, _Amount2, _Type2, _Amount3, _Type3, _Amount4, _Type4)
source/qsb.lua.html#7627

Erzeugt Handelsangebote im Lagerhaus des angegebenen Spielers.

 Sollen Angebote gelöscht werden, muss "-" als Ware ausgewählt werden.

 <b>Achtung:</b> Stadtlagerhäuser können keine Söldner anbieten!






### Reward_DestroyEntity (_ScriptName)
source/qsb.lua.html#7790

Ein benanntes Entity wird entfernt.

 <b>Hinweis</b>: Das Entity wird durch ein XD_ScriptEntity ersetzt. Es
 behält Name, Besitzer und Ausrichtung.






### Reward_DestroyEffect (_EffectName)
source/qsb.lua.html#7816

Zerstört einen über ein Behavior erzeugten Effekt.





### Reward_CreateBattalion (_Position, _PlayerID, _UnitType, _Orientation, _Soldiers, _HideFromAI)
source/qsb.lua.html#7852

Ersetzt ein Entity mit einem Batallion.

 Ist die Position ein Gebäude, werden die Battalione am Eingang erzeugt und
 Das Entity wird nicht ersetzt.

 Das erzeugte Battalion kann vor der KI des Besitzers versteckt werden.






### Reward_CreateSeveralBattalions (_Amount, _Position, _PlayerID, _UnitType, _Orientation, _Soldiers, _HideFromAI)
source/qsb.lua.html#7966

Erzeugt eine Menga von Battalionen an der Position.

 Die erzeugten Battalione können vor der KI ihres Besitzers versteckt werden.






### Reward_CreateEffect (_EffectName, _TypeName, _PlayerID, _Location, _Orientation)
source/qsb.lua.html#8091

Erzeugt einen Effekt an der angegebenen Position.

 Der Effekt kann über seinen Namen jeder Zeit gelöscht werden.

 <b>Achtung</b>: Feuereffekte sind bekannt dafür Abstürzue zu verursachen.
 Vermeide sie entweder ganz oder unterbinde das Speichern, solange ein
 solcher Effekt aktiv ist!






### Reward_CreateEntity (_ScriptName, _PlayerID, _TypeName, _Orientation, _HideFromAI)
source/qsb.lua.html#8194

Ersetzt ein Entity mit dem Skriptnamen durch ein neues Entity.

 Ist die Position ein Gebäude, werden die Entities am Eingang erzeugt und
 die Position wird nicht ersetzt.

 Das erzeugte Entity kann vor der KI des Besitzers versteckt werden.






### Reward_CreateSeveralEntities (_Amount, _ScriptName, _PlayerID, _TypeName, _Orientation, _HideFromAI)
source/qsb.lua.html#8327

Erzeugt mehrere Entities an der angegebenen Position.

 Die erzeugten Entities können vor der KI ihres Besitzers versteckt werden.






### Reward_MoveSettler (_Settler, _Destination)
source/qsb.lua.html#8450

Bewegt einen Siedler, einen Helden oder ein Battalion zum angegebenen
 Zielort.





### Reward_Victory ()
source/qsb.lua.html#8511

Der Spieler gewinnt das Spiel.





### Reward_Defeat ()
source/qsb.lua.html#8538

Der Spieler verliert das Spiel.







### Reward_FakeVictory ()
source/qsb.lua.html#8572

Zeigt die Siegdekoration an dem Quest an.

 Dies ist reine Optik! Der Spieler wird dadurch nicht das Spiel gewinnen.






### Reward_AI_SpawnAndAttackTerritory (_PlayerID, _SpawnPoint, _Territory, _Sword, _Bow, _Cata, _Towers, _Rams, _Ammo, _Type, _Reuse)
source/qsb.lua.html#8616

Erzeugt eine Armee, die das angegebene Territorium angreift.

 Die Armee wird versuchen Gebäude auf dem Territrium zu zerstören.
 <ul>
 <li>Außenposten: Die Armee versucht den Außenposten zu zerstören</li>
 <li>Stadt: Die Armee versucht das Lagerhaus zu zerstören</li>
 </ul>






### Reward_AI_SpawnAndAttackArea (_PlayerID, _SpawnPoint, _Target, _Radius, _Sword, _Bow, _Soldier, _Reuse)
source/qsb.lua.html#8779

Erzeugt eine Armee, die sich zum Zielpunkt bewegt und das Gebiet angreift.

 Dabei werden die Soldaten alle erreichbaren Gebäude in Brand stecken. Ist
 Das Zielgebiet eingemauert, können die Soldaten nicht angreifen und werden
 sich zurückziehen.






### Reward_AI_SpawnAndProtectArea (_PlayerID, _SpawnPoint, _Target, _Radius, _Time, _Sword, _Bow, _CaptureCarts, _Type, _Reuse)
source/qsb.lua.html#8916

Erstellt eine Armee, die das Zielgebiet verteidigt.





### Reward_AI_SetNumericalFact (_PlayerID, _Fact, _Value)
source/qsb.lua.html#9083

Ändert die Konfiguration eines KI-Spielers.

 Optionen:
 <ul>
 <li>Courage/FEAR: Angstfaktor (0 bis ?)</li>
 <li>Reconstruction/BARB: Wiederaufbau von Gebäuden (0 oder 1)</li>
 <li>Build Order/BPMX: Buildorder ausführen (Nummer der Build Order)</li>
 <li>Conquer Outposts/FCOP: Außenposten einnehmen (0 oder 1)</li>
 <li>Mount Outposts/FMOP: Eigene Außenposten bemannen (0 oder 1)</li>
 <li>max. Bowmen/FMBM: Maximale Anzahl an Bogenschützen (min. 1)</li>
 <li>max. Swordmen/FMSM: Maximale Anzahl an Schwerkkämpfer (min. 1) </li>
 <li>max. Rams/FMRA: Maximale Anzahl an Rammen (min. 1)</li>
 <li>max. Catapults/FMCA: Maximale Anzahl an Katapulten (min. 1)</li>
 <li>max. Ammunition Carts/FMAC: Maximale Anzahl an Minitionswagen (min. 1)</li>
 <li>max. Siege Towers/FMST: Maximale Anzahl an Belagerungstürmen (min. 1)</li>
 <li>max. Wall Catapults/FMBA: Maximale Anzahl an Mauerkatapulten (min. 1)</li>
 </ul>






### Reward_AI_Aggressiveness (_PlayerID, _Aggressiveness)
source/qsb.lua.html#9205

Stellt den Aggressivitätswert des KI-Spielers nachträglich ein.





### Reward_AI_SetEnemy (_PlayerID, _EnemyPlayerID)
source/qsb.lua.html#9276

Stellt den Feind des Skirmish-KI ein.

 Der Skirmish-KI (maximale Aggressivität) kann nur einen Spieler als Feind
 behandeln. Für gewöhnlich ist dies der menschliche Spieler.






### Reward_ReplaceEntity (_Entity, _Type, _Owner)
source/qsb.lua.html#9336

Ein Entity wird durch ein neues anderen Typs ersetzt.

 Das neue Entity übernimmt Skriptname, Besitzer und Ausrichtung des
 alten Entity.






### Reward_SetResourceAmount (_ScriptName, _Amount)
source/qsb.lua.html#9366

Setzt die Menge von Rohstoffen in einer Mine.

 <b>Achtung:</b> Im Reich des Ostens darf die Mine nicht eingestürzt sein!
 Außerdem bringt dieses Behavior die Nachfüllmechanik durcheinander.






### Reward_Resources (_Type, _Amount)
source/qsb.lua.html#9432

Fügt dem Lagerhaus des Auftragnehmers eine Menge an Rohstoffen hinzu.  Die
 Rohstoffe werden direkt ins Lagerhaus bzw. die Schatzkammer gelegt.






### Reward_SendCart (_ScriptName, _Owner, _Type, _Good, _Amount, _OtherPlayer, _NoReservation, _Replace)
source/qsb.lua.html#9484

Entsendet einen Karren zum angegebenen Spieler.

 Wenn der Spawnpoint ein Gebäude ist, wird der Wagen am Eingang erstellt.
 Andernfalls kann der Spawnpoint gelöscht werden und der Wagen übernimmt
 dann den Skriptnamen.






### Reward_Units (_Type, _Amount)
source/qsb.lua.html#9612

Gibt dem Auftragnehmer eine Menge an Einheiten.

 Die Einheiten erscheinen an der Burg. Hat der Spieler keine Burg, dann
 erscheinen sie vorm Lagerhaus.






### Reward_QuestRestart (_QuestName)
source/qsb.lua.html#9652

Startet einen Quest neu.





### Reward_QuestFailure (_QuestName)
source/qsb.lua.html#9678

Lässt einen Quest fehlschlagen.





### Reward_QuestSuccess (_QuestName)
source/qsb.lua.html#9704

Wertet einen Quest als erfolgreich.





### Reward_QuestActivate (_QuestName)
source/qsb.lua.html#9730

Triggert einen Quest.





### Reward_QuestInterrupt (_QuestName)
source/qsb.lua.html#9756

Unterbricht einen Quest.





### Reward_QuestForceInterrupt (_QuestName, _EndetQuests)
source/qsb.lua.html#9783

Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.





### Reward_CustomVariables (_Name, _Operator, _Value)
source/qsb.lua.html#9825

Ändert den Wert einer benutzerdefinierten Variable.

 Benutzerdefinierte Variablen können ausschließlich Zahlen sein. Nutze
 dieses Behavior bevor die Variable in einem Goal oder Trigger abgefragt
 wird, um sie zu initialisieren!

 <p>Operatoren</p>
 <ul>
 <li>= - Variablenwert wird auf den Wert gesetzt</li>
 <li>- - Variablenwert mit Wert Subtrahieren</li>
 <li>+ - Variablenwert mit Wert addieren</li>
 <li>* - Variablenwert mit Wert multiplizieren</li>
 <li>/ - Variablenwert mit Wert dividieren</li>
 <li>^ - Variablenwert mit Wert potenzieren</li>
 </ul>






### Reward_MapScriptFunction (_FunctionName)
source/qsb.lua.html#9861

Führt eine Funktion im Skript als Reward aus.

 Wird ein Funktionsname als String übergeben, wird die Funktion mit den
 Daten des Behavors und des zugehörigen Quest aufgerufen (Standard).

 Wird eine Funktionsreferenz angegeben, wird die Funktion zusammen mit allen
 optionalen Parametern aufgerufen, als sei es ein gewöhnlicher Aufruf im
 Skript.
 <pre>Reward_MapScriptFunction(ReplaceEntity, "block", Entities.XD_ScriptEntity);
 -- entspricht: ReplaceEntity("block", Entities.XD_ScriptEntity);</pre>
 <b>Achtung:</b> Nicht über den Assistenten verfügbar!






### Reward_Technology (_PlayerID, _Lock, _Technology)
source/qsb.lua.html#9889

Erlaubt oder verbietet einem Spieler ein Recht.





### Reward_PrestigePoints (_Amount)
source/qsb.lua.html#9916

Gibt dem Auftragnehmer eine Anzahl an Prestigepunkten.

 Prestige hat i.d.R. keine Funktion und wird nur als Zusatzpunkte in der
 Statistik angezeigt.






### Reward_AI_MountOutpost (_ScriptName, _Type)
source/qsb.lua.html#9954

Besetzt einen Außenposten mit Soldaten.





### Reward_QuestRestartForceActive (_QuestName)
source/qsb.lua.html#10025

Startet einen Quest neu und lößt ihn sofort aus.





### Reward_UpgradeBuilding (_ScriptName)
source/qsb.lua.html#10083

Baut das angegebene Gabäude um eine Stufe aus.  Das Gebäude wird durch einen
 Arbeiter um eine Stufe erweitert. Der Arbeiter muss zuerst aus dem Lagerhaus
 kommen und sich zum Gebäude bewegen.

 <b>Achtung:</b> Ein Gebäude muss erst fertig ausgebaut sein, bevor ein
 weiterer Ausbau begonnen werden kann!






### Reward_SetBuildingUpgradeLevel (_ScriptName, _Level)
source/qsb.lua.html#10145

Setzt das Upgrade Level des angegebenen Gebäudes.

 Ein Geböude erhält sofort eine neue Stufe, ohne dass ein Arbeiter kommen
 und es ausbauen muss. Für eine Werkstatt wird ein neuer Arbeiter gespawnt.






### Goal_ActivateObject (_ScriptName)
source/qsb.lua.html#3061

Ein Interaktives Objekt muss benutzt werden.





### Goal_Deliver (_GoodType, _GoodAmount, _OtherTarget, _IgnoreCapture)
source/qsb.lua.html#3110

Einem Spieler müssen Rohstoffe oder Waren gesendet werden.

 In der Regel wird zum Auftraggeber gesendet. Es ist aber möglich auch zu
 einem anderen Zielspieler schicken zu lassen. Wird ein Wagen gefangen
 genommen, dann muss erneut geschickt werden. Optional kann dem Spieler
 auch erlaubt werden, den Karren zurückzuerobern.






### Goal_Diplomacy (_PlayerID, _Relation, _State)
source/qsb.lua.html#3213

Es muss ein bestimmter Diplomatiestatus zu einer anderen Patei erreicht
 werden.  Der Status kann eine Verbesserung oder eine Verschlechterung zum
 aktuellen Status sein.

 Die Relation kann entweder auf kleiner oder gleich (<=), größer oder gleich
 (>=), oder exakte Gleichheit (==) eingestellt werden. Exakte GLeichheit ist
 wegen der Gefahr eines Soft Locks mit Vorsicht zu genießen.






### Goal_DiscoverPlayer (_PlayerID)
source/qsb.lua.html#3310

Das Heimatterritorium des Spielers muss entdeckt werden.

 Das Heimatterritorium ist immer das, wo sich Burg oder Lagerhaus der
 zu entdeckenden Partei befinden.






### Goal_DiscoverTerritory (_Territory)
source/qsb.lua.html#3368

Ein Territorium muss erstmalig vom Auftragnehmer betreten werden.

 Wenn ein Spieler zuvor mit seinen Einheiten auf dem Territorium war, ist
 es bereits entdeckt und das Ziel sofort erfüllt.






### Goal_DestroyPlayer (_PlayerID)
source/qsb.lua.html#3420

Eine andere Partei muss besiegt werden.

 Die Partei gilt als besiegt, wenn ein Hauptgebäude (Burg, Kirche, Lager)
 zerstört wurde.

 <b>Achtung:</b> Bei Banditen ist dieses Behavior wenig sinnvoll, da sie
 nicht durch zerstörung ihres Hauptzeltes vernichtet werden. Hier bietet
 sich Goal_DestroyAllPlayerUnits an.






### Goal_StealInformation (_PlayerID)
source/qsb.lua.html#3482

Es sollen Informationen aus der Burg gestohlen werden.

 Der Spieler muss einen Dieb entsenden um Informationen aus der Burg zu
 stehlen.

 <b>Achtung:</b> Das ist nur bei Feinden möglich!






### Goal_DestroyAllPlayerUnits (_PlayerID)
source/qsb.lua.html#3536

Alle Einheiten des Spielers müssen zerstört werden.

 <b>Achtung</b>: Bei normalen Parteien, welche ein Dorf oder eine Stadt
 besitzen, ist Goal_DestroyPlayer besser geeignet!






### Goal_DestroyScriptEntity (_ScriptName)
source/qsb.lua.html#3598

Ein benanntes Entity muss zerstört werden.

 Ein Entity gilt als zerstört, wenn es nicht mehr existiert oder während
 der Laufzeit des Quests seine Entity-ID oder den Besitzer verändert.

 <b>Achtung</b>: Helden können nicht direkt zerstört werden. Bei ihnen
 genügt es, wenn sie sich "in die Burg zurückziehen".






### Goal_DestroyType (_EntityType, _Amount, _PlayerID)
source/qsb.lua.html#3673

Eine Menge an Entities eines Typs müssen zerstört werden.

 <b>Achtung</b>: Wenn Raubtiere zerstört werden sollen, muss Spieler 0
 als Besitzer angegeben werden.






### Goal_EntityDistance (_ScriptName1, _ScriptName2, _Relation, _Distance)
source/qsb.lua.html#3762

Eine Entfernung zwischen zwei Entities muss erreicht werden.

 Je nach angegebener Relation muss die Entfernung unter- oder überschritten
 werden, um den Quest zu gewinnen.






### Goal_KnightDistance (_ScriptName, _Disctande)
source/qsb.lua.html#3843

Der Primary Knight des angegebenen Spielers muss sich dem Ziel nähern.

 Die Distanz, die unterschritten werden muss, kann frei bestimmt werden.
 Wird die Distanz 0 belassen, wird sie automatisch 2500.






### Goal_UnitsOnTerritory (_Territory, _PlayerID, _Category, _Relation, _Amount)
source/qsb.lua.html#3896

Eine bestimmte Anzahl an Einheiten einer Kategorie muss sich auf dem
 Territorium befinden.

 Es kann entweder gefordert werden, weniger als die angegebene Menge auf
 dem Territorium zu haben (z.B. "<"" 1 für 0) oder mindestens so
 viele Entities (z.B. ">=" 5 für mindestens 5).






### Goal_ActivateBuff (_PlayerID, _Buff)
source/qsb.lua.html#4042

Der angegebene Spieler muss einen Buff aktivieren.

 <u>Buffs "Aufstieg eines Königreich"</u>
 <li>Buff_Spice: Salz</li>
 <li>Buff_Colour: Farben</li>
 <li>Buff_Entertainers: Entertainer anheuern</li>
 <li>Buff_FoodDiversity: Vielfältige Nahrung</li>
 <li>Buff_ClothesDiversity: Vielfältige Kleidung</li>
 <li>Buff_HygieneDiversity: Vielfältige Hygiene</li>
 <li>Buff_EntertainmentDiversity: Vielfältige Unterhaltung</li>
 <li>Buff_Sermon: Predigt halten</li>
 <li>Buff_Festival: Fest veranstalten</li>
 <li>Buff_ExtraPayment: Bonussold auszahlen</li>
 <li>Buff_HighTaxes: Hohe Steuern verlangen</li>
 <li>Buff_NoPayment: Sold streichen</li>
 <li>Buff_NoTaxes: Keine Steuern verlangen</li>
 <br/>
 <u>Buffs "Reich des Ostens"</u>
 <li>Buff_Gems: Edelsteine</li>
 <li>Buff_MusicalInstrument: Musikinstrumente</li>
 <li>Buff_Olibanum: Weihrauch</li>






### Goal_BuildRoad (_Position1, _Position2, _OnlyRoads)
source/qsb.lua.html#4173

Zwei Punkte auf der Spielwelt müssen mit einer Straße verbunden werden.





### Goal_BuildWall (_PlayerID, _Position1, _Position2)
source/qsb.lua.html#4248

Eine Mauer muss gebaut werden um die Bewegung eines Spielers einzuschränken.

 Einschränken bedeutet, dass sich der angegebene Spieler nicht von Punkt A
 nach Punkt B bewegen kann, weil eine Mauer im Weg ist. Die Punkte sind
 frei wählbar. In den meisten Fällen reicht es, Marktplätze anzugeben.

 Beispiel: Spieler 3 ist der Feind von Spieler 1, aber Bekannt mit Spieler 2.
 Wenn er sich nicht mehr zwischen den Marktplätzen von Spieler 1 und 2
 bewegen kann, weil eine Mauer dazwischen ist, ist das Ziel erreicht.

 <b>Achtung:</b> Bei Monsun kann dieses Ziel fälschlicher Weise als erfüllt
 gewertet werden, wenn der Weg durch Wasser blockiert wird!






### Goal_Claim (_Territory)
source/qsb.lua.html#4341

Ein bestimmtes Territorium muss vom Auftragnehmer eingenommen werden.





### Goal_ClaimXTerritories (_Amount)
source/qsb.lua.html#4386

Der Auftragnehmer muss eine Menge an Territorien besitzen.
 Das Heimatterritorium des Spielers wird mitgezählt!






### Goal_Create (_Type, _Amount, _Territory)
source/qsb.lua.html#4432

Der Auftragnehmer muss auf dem Territorium einen Entitytyp erstellen.

 Dieses Behavior eignet sich für Aufgaben vom Schlag "Baue X Getreidefarmen
 Auf Territorium >".






### Goal_Produce (_Type, _Amount)
source/qsb.lua.html#4483

Der Auftragnehmer muss eine Menge von Rohstoffen produzieren.





### Goal_GoodAmount (_Type, _Amount, _Relation)
source/qsb.lua.html#4530

Der Spieler muss eine bestimmte Menge einer Ware erreichen.





### Goal_SatisfyNeed (_PlayerID, _Need)
source/qsb.lua.html#4602

Die Siedler des Spielers dürfen nicht aufgrund des Bedürfnisses streiken.

 <u>Bedürfnisse</u>
 <ul>
 <li>Clothes: Kleidung</li>
 <li>Entertainment: Unterhaltung</li>
 <li>Nutrition: Nahrung</li>
 <li>Hygiene: Hygiene</li>
 <li>Medicine: Medizin</li>
 </ul>






### Goal_SettlersNumber (_Amount, _PlayerID)
source/qsb.lua.html#4663

Der angegebene Spieler muss eine Menge an Siedlern in der Stadt haben.





### Goal_Spouses (_Amount)
source/qsb.lua.html#4707

Der Auftragnehmer muss eine Menge von Ehefrauen in der Stadt haben.





### Goal_SoldierCount (_PlayerID, _Relation, _Amount)
source/qsb.lua.html#4759

Ein Spieler muss eine Menge an Soldaten haben.

 <u>Relationen</u>
 <ul>
 <li>>= - Anzahl als Mindestmenge</li>
 <li>< - Weniger als Anzahl</li>
 </ul>

 Dieses Behavior kann verwendet werden um die Menge an feindlichen
 Soldaten zu zählen oder die Menge an Soldaten des Spielers.






### Goal_KnightTitle (_Title)
source/qsb.lua.html#4895

Der Auftragnehmer muss wenigstens einen bestimmten Titel erreichen.

 Folgende Titel können verwendet werden:
 <table border="1">
 <tr>
 <td><b>Titel</b></td>
 <td><b>Übersetzung</b></td>
 </tr>
 <tr>
 <td>Knight</td>
 <td>Ritter</td>
 </tr>
 <tr>
 <td>Mayor</td>
 <td>Landvogt</td>
 </tr>
 <tr>
 <td>Baron</td>
 <td>Baron</td>
 </tr>
 <tr>
 <td>Earl</td>
 <td>Graf</td>
 </tr>
 <tr>
 <td>Marquees</td>
 <td>Marktgraf</td>
 </tr>
 <tr>
 <td>Duke</td>
 <td>Herzog</td>
 </tr>
 </tr>
 <tr>
 <td>Archduke</td>
 <td>Erzherzog</td>
 </tr>
 <table>






### Goal_Festivals (_PlayerID, _Amount)
source/qsb.lua.html#4947

Der angegebene Spieler muss mindestens die Menge an Festen feiern.

 Ein Fest wird gewertet, sobald die Metfässer auf dem Markt erscheinen. Diese
 Metfässer erscheinen im normalen Spielverlauf nur durch ein Fest!

 <b>Achtung</b>: Wenn ein Spieler aus einem anderen Grund Metfässer besitzt,
 wird dieses Behavior nicht mehr richtig funktionieren!






### Goal_Capture (_ScriptName)
source/qsb.lua.html#5047

Der Auftragnehmer muss eine Einheit gefangen nehmen.





### Goal_CaptureType (_Typ, _Amount, _PlayerID)
source/qsb.lua.html#5109

Der Auftragnehmer muss eine Menge von Einheiten eines Typs von einem
 Spieler gefangen nehmen.





### Goal_Protect (_ScriptName)
source/qsb.lua.html#5191

Der Auftragnehmer muss das angegebene Entity beschützen.

 Wird ein Wagen zerstört oder in das Lagerhaus / die Burg eines Feindes
 gebracht, schlägt das Ziel fehl.






### Goal_Refill (_ScriptName)
source/qsb.lua.html#5266

Der Auftragnehmer muss eine Mine mit einem Geologen wieder auffüllen.

 <b>Achtung</b>: Dieses Behavior ist nur in "Reich des Ostens" verfügbar.






### Goal_ResourceAmount (_ScriptName, _Relation, _Amount)
source/qsb.lua.html#5321

Eine bestimmte Menge an Rohstoffen in einer Mine muss erreicht werden.

 Dieses Behavior eignet sich besonders für den Einsatz als versteckter
 Quest um eine Reaktion auszulösen, wenn z.B. eine Mine leer ist.

 <u>Relationen</u>
 <ul>
 <li>> - Mehr als Anzahl</li>
 <li>< - Weniger als Anzahl</li>
 </ul>






### Goal_InstantFailure ()
source/qsb.lua.html#5395

Der Quest schlägt sofort fehl.





### Goal_InstantSuccess ()
source/qsb.lua.html#5421

Der Quest wird sofort erfüllt.





### Goal_NoChange ()
source/qsb.lua.html#5450

Der Zustand des Quests ändert sich niemals  Wenn ein Zeitlimit auf dem Quest liegt, wird dieses Behavior nicht
 fehlschlagen sondern automatisch erfüllt.






### Goal_MapScriptFunction (_FunctionName)
source/qsb.lua.html#5489

Führt eine Funktion im Skript als Goal aus.

 Die Funktion muss entweder true, false oder nichts zurückgeben.
 <ul>
 <li>true: Erfolgreich abgeschlossen</li>
 <li>false: Fehlschlag</li>
 <li>nichts: Zustand unbestimmt</li>
 </ul>

 Anstelle eines Strings kann beim Einsatz im Skript eine Funktionsreferenz
 übergeben werden. In diesem Fall werden alle weiteren Parameter direkt an
 die Funktion weitergereicht.






### Goal_CustomVariables (_Name, _Relation, _Value)
source/qsb.lua.html#5562

Eine benutzerdefinierte Variable muss einen bestimmten Wert haben.

 Custom Variables können ausschließlich Zahlen enthalten. Bevor eine
 Variable in einem Goal abgefragt werden kann, muss sie zuvor mit
 Reprisal_CustomVariables oder Reward_CutsomVariables initialisiert
 worden sein.

 <p>Vergleichsoperatoren</p>
 <ul>
 <li>== - Werte müssen gleich sein</li>
 <li>~= - Werte müssen ungleich sein</li>
 <li>> - Variablenwert größer Vergleichswert</li>
 <li>>= - Variablenwert größer oder gleich Vergleichswert</li>
 <li>< - Variablenwert kleiner Vergleichswert</li>
 <li><= - Variablenwert kleiner oder gleich Vergleichswert</li>
 </ul>






### Goal_TributeDiplomacy (_GoldAmount, _Periode, _Time, _StartMsg, _SuccessMsg, _FailureMsg, _Restart)
source/qsb.lua.html#5672

Der Spieler kann durch regelmäßiges Begleichen eines Tributes bessere
 Diplomatie zu einem Spieler erreichen.

 Die Zeit zum Bezahlen des Tributes muss immer kleiner sein als die
 Wiederholungsperiode.

 <b>Hinweis</b>: Je mehr Zeit sich der Spieler lässt um den Tribut zu
 begleichen, desto mehr wird sich der Start der nächsten Periode verzögern.






### Goal_TributeClaim (_Territory, _PlayerID, _Cost, _Periode, _Time, _StartMsg, _SuccessMsg, _FailMsg, _HowOften, _OtherOwner, _Abort)
source/qsb.lua.html#5865

Erlaubt es dem Spieler ein Territorium zu "mieten".

 Zerstört der Spieler den Außenposten, schlägt der Quest fehl und das
 Territorium wird an den Vermieter übergeben. Wenn der Spieler die Pacht
 nicht bezahlt, geht der Besitz an den Vermieter über.

 Die Zeit zum Bezahlen des Tributes muss immer kleiner sein als die
 Wiederholungsperiode.

 <b>Hinweis</b>: Je mehr Zeit sich der Spieler lässt um den Tribut zu
 begleichen, desto mehr wird sich der Start der nächsten Periode verzögern.






### Reprisal_ObjectDeactivate (_ScriptName)
source/qsb.lua.html#6125

Deaktiviert ein interaktives Objekt.





### Reprisal_ObjectActivate (_ScriptName, _State)
source/qsb.lua.html#6189

Aktiviert ein interaktives Objekt.

 Der Status bestimmt, wie das Objekt aktiviert wird.
 <ul>
 <li>0: Kann nur mit Helden aktiviert werden</li>
 <li>1: Kann immer aktiviert werden</li>
 <li>2: Kann niemals aktiviert werden</li>
 </ul>






### Reprisal_DiplomacyDecrease ()
source/qsb.lua.html#6255

Der diplomatische Status zwischen Sender und Empfänger verschlechtert sich
 um eine Stufe.





### Reprisal_Diplomacy (_Party1, _Party2, _State)
source/qsb.lua.html#6300

Änder den Diplomatiestatus zwischen zwei Spielern.





### Reprisal_DestroyEntity (_ScriptName)
source/qsb.lua.html#6364

Ein benanntes Entity wird entfernt.

 <b>Hinweis</b>: Das Entity wird durch ein XD_ScriptEntity ersetzt. Es
 behält Name, Besitzer und Ausrichtung.






### Reprisal_DestroyEffect (_EffectName)
source/qsb.lua.html#6413

Zerstört einen über ein Behavior erzeugten Effekt.





### Reprisal_Defeat ()
source/qsb.lua.html#6462

Der Spieler verliert das Spiel.





### Reprisal_FakeDefeat ()
source/qsb.lua.html#6490

Zeigt die Niederlagedekoration am Quest an.

 Es handelt sich dabei um reine Optik! Der Spieler wird nicht verlieren.






### Reprisal_ReplaceEntity (_Entity, _Type, _Owner)
source/qsb.lua.html#6523

Ein Entity wird durch ein neues anderen Typs ersetzt.

 Das neue Entity übernimmt Skriptname, Besitzer  und Ausrichtung des
 alten Entity.






### Reprisal_QuestRestart (_QuestName)
source/qsb.lua.html#6614

Startet einen Quest neu.





### Reprisal_QuestFailure (_QuestName)
source/qsb.lua.html#6663

Lässt einen Quest fehlschlagen.





### Reprisal_QuestSuccess (_QuestName)
source/qsb.lua.html#6712

Wertet einen Quest als erfolgreich.





### Reprisal_QuestActivate (_QuestName)
source/qsb.lua.html#6761

Triggert einen Quest.





### Reprisal_QuestInterrupt (_QuestName)
source/qsb.lua.html#6812

Unterbricht einen Quest.





### Reprisal_QuestForceInterrupt (_QuestName, _EndetQuests)
source/qsb.lua.html#6869

Unterbricht einen Quest, selbst wenn dieser noch nicht ausgelöst wurde.





### Reprisal_CustomVariables (_Name, _Operator, _Value)
source/qsb.lua.html#6958

Ändert den Wert einer benutzerdefinierten Variable.

 Benutzerdefinierte Variablen können ausschließlich Zahlen sein. Nutze
 dieses Behavior bevor die Variable in einem Goal oder Trigger abgefragt
 wird, um sie zu initialisieren!

 <p>Operatoren</p>
 <ul>
 <li>= - Variablenwert wird auf den Wert gesetzt</li>
 <li>- - Variablenwert mit Wert Subtrahieren</li>
 <li>+ - Variablenwert mit Wert addieren</li>
 <li>* - Variablenwert mit Wert multiplizieren</li>
 <li>/ - Variablenwert mit Wert dividieren</li>
 <li>^ - Variablenwert mit Wert potenzieren</li>
 </ul>






### Reprisal_MapScriptFunction (_Function)
source/qsb.lua.html#7051

Führt eine Funktion im Skript als Reprisal aus.

 Wird ein Funktionsname als String übergeben, wird die Funktion mit den
 Daten des Behavors und des zugehörigen Quest aufgerufen (Standard).

 Wird eine Funktionsreferenz angegeben, wird die Funktion zusammen mit allen
 optionalen Parametern aufgerufen, als sei es ein gewöhnlicher Aufruf im
 Skript.
 <pre> Reprisal_MapScriptFunction(ReplaceEntity, "block", Entities.XD_ScriptEntity);
 -- entspricht: ReplaceEntity("block", Entities.XD_ScriptEntity);</pre>
 <b>Achtung:</b> Nicht über den Assistenten verfügbar!






### Reprisal_Technology (_PlayerID, _Lock, _Technology)
source/qsb.lua.html#7110

Erlaubt oder verbietet einem Spieler ein Recht.





### Reprisal_Technology (_PlayerID, _Lock, _Technology)
source/qsb.lua.html#7195

Erlaubt oder verbietet einem Spieler ein Recht.





### Trigger_PlayerDiscovered (_PlayerID)
source/qsb.lua.html#10220

Starte den Quest, wenn ein anderer Spieler entdeckt wurde.

 Ein Spieler ist dann entdeckt, wenn sein Heimatterritorium aufgedeckt wird.






### Trigger_OnDiplomacy (_PlayerID, _State)
source/qsb.lua.html#10259

Starte den Quest, wenn zwischen dem Empfänger und der angegebenen Partei
 der geforderte Diplomatiestatus herrscht.





### Trigger_OnNeedUnsatisfied (_PlayerID, _Need, _Amount)
source/qsb.lua.html#10301

Starte den Quest, sobald ein Bedürfnis nicht erfüllt wird.





### Trigger_OnResourceDepleted (_ScriptName)
source/qsb.lua.html#10362

Startet den Quest, wenn die angegebene Mine erschöpft ist.





### Trigger_OnAmountOfGoods (_PlayerID, _Type, _Amount)
source/qsb.lua.html#10407

Startet den Quest, sobald der angegebene Spieler eine Menge an Rohstoffen
 im Lagerhaus hat.





### Trigger_OnQuestActive (_QuestName, _Time)
source/qsb.lua.html#10478

Startet den Quest, sobald ein anderer aktiv ist.





### Trigger_OnQuestFailure (_QuestName, _Time)
source/qsb.lua.html#10585

Startet einen Quest, sobald ein anderer fehlschlägt.





### Trigger_OnQuestNotTriggered (_QuestName)
source/qsb.lua.html#10683

Startet einen Quest, wenn ein anderer noch nicht ausgelöst wurde.





### Trigger_OnQuestInterrupted (_QuestName, _Time)
source/qsb.lua.html#10739

Startet den Quest, sobald ein anderer unterbrochen wurde.





### Trigger_OnQuestOver (_QuestName, _Time)
source/qsb.lua.html#10841

Startet den Quest, sobald ein anderer bendet wurde.

 Dabei ist das Resultat egal. Der Quest kann entweder erfolgreich beendet
 wurden oder fehlgeschlagen sein.






### Trigger_OnQuestSuccess (_QuestName, _Time)
source/qsb.lua.html#10940

Startet den Quest, sobald ein anderer Quest erfolgreich abgeschlossen wurde.





### Trigger_CustomVariables (_Name, _Relation, _Value)
source/qsb.lua.html#11046

Startet den Quest, wenn eine benutzerdefinierte Variable einen bestimmten
 Wert angenommen hat.

 Benutzerdefinierte Variablen müssen Zahlen sein. Bevor eine
 Variable in einem Goal abgefragt werden kann, muss sie zuvor mit
 Reprisal_CustomVariables oder Reward_CutsomVariables initialisiert
 worden sein.






### Trigger_AlwaysActive ()
source/qsb.lua.html#11132

Startet den Quest sofort.





### Trigger_OnMonth (_Month)
source/qsb.lua.html#11160

Startet den Quest im angegebenen Monat.





### Trigger_OnMonsoon ()
source/qsb.lua.html#11221

Startet den Quest sobald der Monsunregen einsetzt.

 <b>Achtung:</b> Dieses Behavior ist nur für Reich des Ostens verfügbar.






### Trigger_Time (_Time)
source/qsb.lua.html#11258

Startet den Quest sobald der Timer abgelaufen ist.

 Der Timer zählt immer vom Start der Map an.






### Trigger_OnWaterFreezes ()
source/qsb.lua.html#11293

Startet den Quest sobald das Wasser gefriert.





### Trigger_NeverTriggered ()
source/qsb.lua.html#11328

Startet den Quest niemals.

 Quests, für die dieser Trigger gesetzt ist, müssen durch einen anderen
 Quest über Reward_QuestActive oder Reprisal_QuestActive gestartet werden.






### Trigger_OnAtLeastOneQuestFailure (_QuestName1, _QuestName2)
source/qsb.lua.html#11359

Startet den Quest, sobald wenigstens einer von zwei Quests fehlschlägt.





### Trigger_OnAtLeastOneQuestSuccess (_QuestName1, _QuestName2)
source/qsb.lua.html#11426

Startet den Quest, sobald wenigstens einer von zwei Quests erfolgreich ist.





### Trigger_OnAtLeastXOfYQuestsSuccess (_MinAmount, _QuestAmount, _Quest1, _Quest2, _Quest3, _Quest4, _Quest5)
source/qsb.lua.html#11498

Startet den Quest, sobald mindestens X von Y Quests erfolgreich sind.





### Trigger_MapScriptFunction (_FunctionName)
source/qsb.lua.html#11602

Führt eine Funktion im Skript als Trigger aus.

 Die Funktion muss entweder true or false zurückgeben.

 Nur Skipt: Wird statt einem Funktionsnamen (String) eine Funktionsreferenz
 übergeben, werden alle weiteren Parameter an die Funktion weitergereicht.






### Trigger_OnEffectDestroyed (_EffectName)
source/qsb.lua.html#11659

Startet den Quest, sobald ein Effekt zerstört wird oder verschwindet.

 <b>Achtung</b>: Das Behavior kann nur auf Effekte angewand werden, die
 über Effekt-Behavior erzeugt wurden.






### QSB.ScriptingValue
source/qsb.lua.html#12250

Liste der unterstützten Scripting Values.

 <ul>
 <li><b>QSB.ScriptingValue.Destination.X</b><br>
 Gibt die Z-Koordinate des Bewegungsziels als Float zurück.</li>
 <li><b>QSB.ScriptingValue.Destination.Y</b><br>
 Gibt die Y-Koordinate des Bewegungsziels als Float zurück.</li>
 <li><b>QSB.ScriptingValue.Health</b><br>
 Setzt die Gesundheit eines Entity ohne Folgeaktionen zu triggern.</li>
 <li><b>QSB.ScriptingValue.Player</b><br>
 Setzt den Besitzer des Entity ohne Plausibelitätsprüfungen.</li>
 <li><b>QSB.ScriptingValue.Size</b><br>
 Setzt den Größenfaktor eines Entities als Float.</li>
 <li><b>QSB.ScriptingValue.Visible</b><br>
 Sichtbarkeit eines Entities abfragen (801280 == sichtbar)</li>
 <li><b>QSB.ScriptingValue.NPC</b><br>
 NPC-Flag eines Siedlers setzen (0 = inaktiv, 1 - 4 = aktiv)</li>
 </ul>





### API.GetInteger (_Entity, _SV)
source/qsb.lua.html#12263

Gibt den Wert auf dem übergebenen Index für das Entity zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> PlayerID = API.GetInteger(<span class="string">"HansWurst"</span>, QSB.ScriptingValue.Player);</pre>


</ul>


### API.GetFloat (_Entity, _SV)
source/qsb.lua.html#12282

Gibt den Wert auf dem übergebenen Index für das Entity zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Size = API.GetFloat(<span class="string">"HansWurst"</span>, QSB.ScriptingValue.Size);</pre>


</ul>


### API.SetInteger (_Entity, _SV, _Value)
source/qsb.lua.html#12302

Setzt den Wert auf dem übergebenen Index für das Entity.






### Beispiel:
<ul>


<pre class="example">API.SetInteger(<span class="string">"HansWurst"</span>, QSB.ScriptingValue.Player, <span class="number">2</span>);</pre>


</ul>


### API.SetFloat (_Entity, _SV, _Value)
source/qsb.lua.html#12321

Setzt den Wert auf dem übergebenen Index für das Entity.





### Beispiel:
<ul>


<pre class="example">API.SetFloat(<span class="string">"HansWurst"</span>, QSB.ScriptingValue.Size, <span class="number">1.5</span>);</pre>


</ul>


### API.ConvertIntegerToFloat (_Value)
source/qsb.lua.html#12339

Konvertirert den Wert in eine Ganzzahl.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Converted = API.ConvertIntegerToFloat(Value)</pre>


</ul>


### API.ConvertFloatToInteger (_Value)
source/qsb.lua.html#12353

Konvertirert den Wert in eine Gleitkommazahl.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Converted = API.ConvertFloatToInteger(Value)</pre>


</ul>


### API.DisableAutoSave (_Flag)
source/qsb.lua.html#13197

Deaktiviert das automatische Speichern der History Edition.





### API.DisableSaving (_Flag)
source/qsb.lua.html#13212

Deaktiviert das Speichern des Spiels.





### API.DisableLoading (_Flag)
source/qsb.lua.html#13221

Deaktiviert das Laden von Spielständen.





### API.Localize (_Text)
source/qsb.lua.html#13514

Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.

 Wird ein normaler String übergeben, wird dieser sofort zurückgegeben.
 Bei einem Table mit einem passenden Sprach-Key (de, en, fr, ...) wird die
 entsprechende Sprache zurückgegeben. Sollte ein Nested Table übergeben
 werden, werden alle Texte innerhalb des Tables rekursiv übersetzt als Table
 zurückgegeben. Alle anderen Werte sind nicht in der Rückgabe enthalten.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Table lokalisieren
</span><span class="keyword">local</span> Text = API.Localize({de = <span class="string">"Deutsch"</span>, en = <span class="string">"English"</span>});
<span class="comment">-- Rückgabe: "Deutsch"</span></pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Mehrstufige (Nested) Tables
</span><span class="comment">-- (Nested Tables sind in dem Fall mit Vorsicht zu genießen!)
</span>API.Localize{{de = <span class="string">"Deutsch"</span>, en = <span class="string">"English"</span>}, {{<span class="number">1</span>,<span class="number">2</span>,<span class="number">3</span>,<span class="number">4</span>, de = <span class="string">"A"</span>, en = <span class="string">"B"</span>}}}
<span class="comment">-- Rückgabe: {"Deutsch", {"A"}}</span></pre></li>


</ul>


### API.Note (_Text)
source/qsb.lua.html#13533

Schreibt eine Nachricht in das Debug Window.  Der Text erscheint links am
 Bildschirm und ist nicht statisch.

 <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
 <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>

 <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.






### Beispiel:
<ul>


<pre class="example">API.Note(<span class="string">"Das ist eine flüchtige Information!"</span>);</pre>


</ul>


### API.StaticNote (_Text)
source/qsb.lua.html#13557

Schreibt eine Nachricht in das Debug Window.  Der Text erscheint links am
 Bildschirm und verbleibt dauerhaft am Bildschirm.

 <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
 <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>

 <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.






### Beispiel:
<ul>


<pre class="example">API.StaticNote(<span class="string">"Das ist eine dauerhafte Information!"</span>);</pre>


</ul>


### API.Message (_Text, _Sound)
source/qsb.lua.html#13590

Schreibt eine Nachricht unten in das Nachrichtenfenster.  Die Nachricht
 verschwindet nach einigen Sekunden.

 <i>Platzhalter werden automatisch im aufrufenden Environment ersetzt.</i><br>
 <i>Multilinguale Texte werden automatisch im aufrufenden Environment übersetzt.</i>

 <b>Hinweis:</b> Texte werden automatisch lokalisiert und Platzhalter ersetzt.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Einfache Nachricht
</span>API.Message(<span class="string">"Das ist eine Nachricht!"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Nachricht und Ton
</span>API.Message(<span class="string">"Das ist eine WERTVOLLE Nachricht!"</span>, <span class="string">"ui/menu_left_gold_pay"</span>);</pre></li>


</ul>


### API.ClearNotes ()
source/qsb.lua.html#13615

Löscht alle Nachrichten im Debug Window.





### Beispiel:
<ul>


<pre class="example">API.ClearNotes();</pre>


</ul>


### API.ConvertPlaceholders (_Message)
source/qsb.lua.html#13682

Ersetzt alle Platzhalter im Text oder in der Table.

 Mögliche Platzhalter:
 <ul>
 <li>{n:xyz} - Ersetzt einen Skriptnamen mit dem zuvor gesetzten Wert.</li>
 <li>{t:xyz} - Ersetzt einen Typen mit dem zuvor gesetzten Wert.</li>
 <li>{v:xyz} - Ersetzt mit dem Inhalt der angegebenen Variable. Der Wert muss
 in der Umgebung vorhanden sein, in der er ersetzt wird.</li>
 </ul>

 Außerdem werden einige Standardfarben ersetzt.
 <pre>{COLOR}</pre>
 Ersetze {COLOR} in deinen Texten mit einer der gelisteten Farben.

 <table border="1">
 <tr><th><b>Platzhalter</b></th><th><b>Farbe</b></th><th><b>RGBA</b></th></tr>

 <tr><td>red</td>     <td>Rot</td>           <td>255,80,80,255</td></tr>
 <tr><td>blue</td>    <td>Blau</td>          <td>104,104,232,255</td></tr>
 <tr><td>yellow</td>  <td>Gelp</td>          <td>255,255,80,255</td></tr>
 <tr><td>green</td>   <td>Grün</td>          <td>80,180,0,255</td></tr>
 <tr><td>white</td>   <td>Weiß</td>          <td>255,255,255,255</td></tr>
 <tr><td>black</td>   <td>Schwarz</td>       <td>0,0,0,255</td></tr>
 <tr><td>grey</td>    <td>Grau</td>          <td>140,140,140,255</td></tr>
 <tr><td>azure</td>   <td>Azurblau</td>      <td>255,176,30,255</td></tr>
 <tr><td>orange</td>  <td>Orange</td>        <td>255,176,30,255</td></tr>
 <tr><td>amber</td>   <td>Bernstein</td>     <td>224,197,117,255</td></tr>
 <tr><td>violet</td>  <td>Violett</td>       <td>180,100,190,255</td></tr>
 <tr><td>pink</td>    <td>Rosa</td>          <td>255,170,200,255</td></tr>
 <tr><td>scarlet</td> <td>Scharlachrot</td>  <td>190,0,0,255</td></tr>
 <tr><td>magenta</td> <td>Magenta</td>       <td>190,0,89,255</td></tr>
 <tr><td>olive</td>   <td>Olivgrün</td>      <td>74,120,0,255</td></tr>
 <tr><td>sky</td>     <td>Himmelsblau</td>   <td>145,170,210,255</td></tr>
 <tr><td>tooltip</td> <td>Tooltip-Blau</td>  <td>51,51,120,255</td></tr>
 <tr><td>lucid</td>   <td>Transparent</td>   <td>0,0,0,0</td></tr>
 <tr><td>none</td>    <td>Standardfarbe</td> <td>(Abhängig vom Widget)</td></tr>
 </table>






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Vordefinierte Farbe austauschen
</span><span class="keyword">local</span> Replaced = API.ConvertPlaceholders(<span class="string">"{scarlet}Dieser Text ist jetzt rot!"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Skriptnamen austauschen
</span><span class="keyword">local</span> Replaced = API.ConvertPlaceholders(<span class="string">"{n:placeholder2} wurde ersetzt!"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Typen austauschen
</span><span class="keyword">local</span> Replaced = API.ConvertPlaceholders(<span class="string">"{t:U_KnightHealing} wurde ersetzt!"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #4: Variable austauschen
</span><span class="keyword">local</span> Replaced = API.ConvertPlaceholders(<span class="string">"{v:MyVariable.1.MyValue} wurde ersetzt!"</span>);</pre></li>


</ul>


### API.AddNamePlaceholder (_Name, _Replacement)
source/qsb.lua.html#13710

Fügt einen Platzhalter für den angegebenen Namen hinzu.

 Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
 <pre>{n:SOME_NAME}</pre>
 SOME_NAME muss mit dem Namen ersetzt werden.






### Beispiel:
<ul>


<pre class="example">API.AddNamePlaceholder(<span class="string">"Scriptname"</span>, <span class="string">"Horst"</span>);
API.AddNamePlaceholder(<span class="string">"Scriptname"</span>, {de = <span class="string">"Kuchen"</span>, en = <span class="string">"Cake"</span>});</pre>


</ul>


### API.AddEntityTypePlaceholder (_Type, _Replacement)
source/qsb.lua.html#13734

Fügt einen Platzhalter für einen Entity-Typ hinzu.

 Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
 <pre>{t:ENTITY_TYP}</pre>
 ENTITY_TYP muss mit einem Entity-Typ ersetzt werden. Der Typ wird ohne
 Entities. davor geschrieben.






### Beispiel:
<ul>


<pre class="example">API.AddNamePlaceholder(<span class="string">"U_KnightHealing"</span>, <span class="string">"Arroganze Ziege"</span>);
API.AddNamePlaceholder(<span class="string">"B_Castle_SE"</span>, {de = <span class="string">"Festung des Bösen"</span>, en = <span class="string">"Fortress of Evil"</span>});</pre>


</ul>


