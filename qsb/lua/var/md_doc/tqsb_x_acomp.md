# Module <code>tqsb_x_acomp</code>
Die Kompatibilitätsfunktionen dienen dazu, dass die alte Schnittstelle der früheren QSB möglichst abgedeckt wird.
 <b>Hinweis</b>: Diese Funktionen sind derzeit nur in der qsb<em>comp.lua bzw qsb</em>comp.luac enthalten.

### API.AddSaveGameAction (_Function)
source/tqsb_x_acomp.lua.html#26

Registriert eine Funktion, die nach dem laden ausgeführt wird.

 <b>Alias</b>: AddOnSaveGameLoadedAction






### Beispiel:
<ul>


<pre class="example">SaveGame = <span class="keyword">function</span>()
    API.Note(<span class="string">"foo"</span>)
<span class="keyword">end</span>
API.AddSaveGameAction(SaveGame)</pre>


</ul>


### API.Confront (_entity, _entityToLookAt)
source/tqsb_x_acomp.lua.html#104

Lässt zwei Entities sich gegenseitig anschauen.





### Beispiel:
<ul>


<pre class="example">API.Confront(<span class="string">"Hakim"</span>, <span class="string">"Alandra"</span>)</pre>


</ul>


### API.EnsureScriptName (_EntityID)
source/tqsb_x_acomp.lua.html#90

Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
 Hat das Entity einen Namen, bleibt dieser unverändert und wird
 zurückgegeben.

 <b>QSB:</b> API.CreateEntityName(_EntityID)
 <b>Alias:</b> GiveEntityName






### Beispiel:
<ul>


<pre class="example">Skriptname = API.EnsureScriptName(_EntityID)</pre>


</ul>


### API.InstanceTable (_Source, _Dest)
source/tqsb_x_acomp.lua.html#50

Kopiert eine komplette Table und gibt die Kopie zurück.  Tables können
 nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
 Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
 angegebenen Tables.
 Die Funktion arbeitet rekursiv.

 <b>QSB:</b> table.copy(_Source, _Dest)
 <b>Alias:</b> CopyTableRecursive






### Beispiel:
<ul>


<pre class="example">Table = {<span class="number">1</span>, <span class="number">2</span>, <span class="number">3</span>, {a = <span class="keyword">true</span>}}
Copy = API.InstanceTable(Table)</pre>


</ul>


### API.LocateEntity (_Entity)
source/tqsb_x_acomp.lua.html#124

Lokalisiert ein Entity auf der Map.  Es können sowohl Skriptnamen als auch
 IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
 Tabelle mit XYZ = 0 zurückgegeben.

 <b>QSB:</b> API.GetPosition(_Entity)
 <p><b>Alias:</b> GetPosition</p>






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Position = API.LocateEntity(<span class="string">"Hans"</span>)</pre>


</ul>


### API.RealTimeWait (_Waittime, _Action, ...)
source/tqsb_x_acomp.lua.html#144

Wartet die angebene Zeit in realen Sekunden und führt anschließend das
 Callback aus.  Die Ausführung erfolgt asynchron. Das bedeutet, dass das
 Skript weiterläuft.

 Hinweis: Einmal gestartet, kann wait nicht beendet werden.

 <b>QSB:</b> API.StartRealTimeDelay(_Waittime, _Function, ...)






### API.Round (_Value, _DecimalDigits)
source/tqsb_x_acomp.lua.html#161

Rundet eine Dezimalzahl kaufmännisch ab.

 <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
 History Edition zu umgehen.

 <p><b>Alias:</b> Round</p>






### API.StartEventJob (_EventType, _Function, ...)
source/tqsb_x_acomp.lua.html#238

Erzeugt einen neuen Event-Job.

 <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
 können ResumeJob und YieldJob auf den Job angewendet werden.

 <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!

 <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
 Kopie angeleigt um Speicherprobleme zu verhindern. Es handelt sich also um
 eine neue Table und keine Referenz!

 <b>QSB:</b> API.StartJobByEventType (_EventType, _Function, ...)






### API.TraverseTable (_Data, _Table)
source/tqsb_x_acomp.lua.html#70

Sucht in einer eindimensionalen Table nach einem Wert.  Das erste Auftreten des Suchwerts wird als Erfolg gewertet. Es können praktisch alle Lua-Werte gesucht werden.

 <b>QSB:</b> table.contains(_Data, _Table)
 <b>Alias:</b> Inside






### Beispiel:
<ul>


<pre class="example">Table = {<span class="number">1</span>, <span class="number">2</span>, <span class="number">3</span>, {a = <span class="keyword">true</span>}}
<span class="keyword">local</span> Found = API.TraverseTable(<span class="number">3</span>, Table)</pre>


</ul>


### API.ValidatePosition (_Pos)
source/tqsb_x_acomp.lua.html#213

Prüft, ob eine Positionstabelle eine gültige Position enthält.

 Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
 Das ist der Fall bei negativen Werten oder Werten, welche die Größe
 der Welt übersteigen.

 <b>QSB:</b> API.IsValidPosition(_Pos)
 <p><b>Alias:</b> IsValidPosition</p>






### API.AddHotKey (_Key, _Description)
source/tqsb_x_acomp.lua.html#253

Fügt eine Beschreibung zu einem selbst gewählten Hotkey hinzu.

 Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.

 <b>QSB:</b> API.AddShortcutEntry(_Key, _Description)






### API.RemoveHotKey (_ID)
source/tqsb_x_acomp.lua.html#265

Entfernt eine Beschreibung eines selbst gewählten Hotkeys.

 <b>QSB:</b> API.RemoveShortcutEntry(_ID)






### API.GetEntitiesOfCategoryInTerritory (_PlayerID, _Category, _Territory)
source/tqsb_x_acomp.lua.html#284

Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
 sie als Liste zurück.

 <b>QSB:</b> API.SearchEntitiesOfCategoryInTerritory(_Territory, _Category, _PlayerID)
 <p><b>Alias:</b> GetEntitiesOfCategoryInTerritory</p>






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Found = API.GetEntitiesOfCategoryInTerritory(<span class="number">1</span>, EntityCategories.Hero, <span class="number">5</span>)</pre>


</ul>


