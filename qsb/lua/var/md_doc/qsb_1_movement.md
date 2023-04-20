# Module <code>qsb_1_movement</code>
Ermoglicht die Bewegung von Entities und Berechnung von Pfaden.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_1_movement.lua.html#26

Events, auf die reagiert werden kann.





### API.MoveEntity (_Entity, _Target, _IgnoreBlocking)
source/qsb_1_movement.lua.html#50

Bewegt ein Entity zum Zielpunkt.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Normale Bewegung
</span>API.MoveEntity(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Schiff bewegen
</span>API.MoveEntity(<span class="string">"Ship"</span>, <span class="string">"Harbor"</span>, <span class="keyword">true</span>);</pre></li>


</ul>


### API.MoveEntityAndExecute (_Entity, _Target, _Action, _IgnoreBlocking)
source/qsb_1_movement.lua.html#186

Bewegt ein Entity zum Zielpunkt und führt die Funktion aus.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.






### Beispiel:
<ul>


<pre class="example">API.MoveEntityAndExecute(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>, <span class="keyword">function</span>()
    Logic.DEBUG_AddNote(<span class="string">"Marcus ist angekommen!"</span>);
<span class="keyword">end</span>);</pre>


</ul>


### API.MoveEntityAndLookAt (_Entity, _Target, _LookAt, _IgnoreBlocking)
source/qsb_1_movement.lua.html#93

Bewegt ein Entity zum Zielpunkt und lässt es das Ziel anschauen.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.






### Beispiel:
<ul>


<pre class="example">API.MoveEntityAndLookAt(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>, <span class="string">"Alandra"</span>);</pre>


</ul>


### API.MoveEntityOnCheckpoints (_Entity, _WaypointList, _IgnoreBlocking)
source/qsb_1_movement.lua.html#231

Bewegt ein Entity über den angegebenen Pfad.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Jedes Mal wenn das Entity einen Wegpunkt erreicht hat, wird das Event
 QSB.ScriptEvents.EntityAtCheckpoint geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.






### Beispiel:
<ul>


<pre class="example">API.MoveEntityOnCheckpoints(<span class="string">"Marcus"</span>, {<span class="string">"WP1"</span>, <span class="string">"WP2"</span>, <span class="string">"WP3"</span>, <span class="string">"Target"</span>});</pre>


</ul>


### API.MoveEntityToPosition (_Entity, _Target, _Distance, _Angle, _IgnoreBlocking)
source/qsb_1_movement.lua.html#137

Bewegt ein Entity relativ zu einer Position.

 Wenn das Ziel zu irgend einem Zeitpunkt nicht erreicht werden kann, wird die
 Bewegung abgebrochen und das Event QSB.ScriptEvents.EntityStuck geworfen.

 Das Ziel gilt als erreicht, sobald sich das Entity nicht mehr bewegt. Dann
 wird das Event QSB.ScriptEvents.EntityArrived geworfen.






### Beispiel:
<ul>


<pre class="example">API.MoveEntityToPosition(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>, <span class="number">1000</span>, <span class="number">90</span>);</pre>


</ul>


### API.PlaceEntityAndLookAt (_Entity, _Target, _LookAt)
source/qsb_1_movement.lua.html#260

Positioniert ein Entity und lässt es einen Ort ansehen.





### Beispiel:
<ul>


<pre class="example">API.PlaceEntityAndLookAt(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>, <span class="string">"Alandra"</span>);</pre>


</ul>


### API.PlaceEntityToPosition (_Entity, _Target, _Distance, _Angle)
source/qsb_1_movement.lua.html#292

Positioniert ein Entity relativ zu einer Position.





### Beispiel:
<ul>


<pre class="example">API.PlaceEntityAndLookAt(<span class="string">"Marcus"</span>, <span class="string">"Target"</span>, <span class="number">1000</span>, <span class="number">90</span>);</pre>


</ul>


### API.IsPathBeingCalculated (_ID)
source/qsb_1_movement.lua.html#408

Prüft ob ein Pfad mit der ID noch gesucht wird.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">if</span> API.IsPathBeingCalculated(MyPathID) <span class="keyword">then</span>
    <span class="comment">-- Mach was
</span><span class="keyword">end</span></pre>


</ul>


### API.IsPathExisting (_ID)
source/qsb_1_movement.lua.html#392

Prüft ob ein Pfad mit der ID existiert.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">if</span> API.IsPathExisting(MyPathID) <span class="keyword">then</span>
    <span class="comment">-- Mach was
</span><span class="keyword">end</span></pre>


</ul>


### API.RetrievePath (_ID)
source/qsb_1_movement.lua.html#422

Gibt den Pfad mit der ID als Liste von Entity-IDs zurück.





### Beispiel:
<ul>


<pre class="example">WaypointList = API.RetrievePath(MyPathID);</pre>


</ul>


### API.StartPathfinding (_StartPosition, _EndPosition, _NodeFilter)
source/qsb_1_movement.lua.html#357

Beginnt die Wegsuche zwischen zwei Punkten.

 Der Pfad wird nicht sofort zurückgegeben. Stattdessen eine ID. Der Pfad wird
 asynchron gesucht, damit das Spiel nicht einfriert. Wenn die Pfadsuche
 abgeschlossen wird, werden entsprechende Events ausgelöst.

 <ul>
 <li><b>QSB.ScriptEvents.PathFindingFinished</b><br/>
 Ein Pfad zwischen den Punkten wurde gefunden.</li>
 <li><b>QSB.ScriptEvents.PathFindingFailed</b><br/>
 Es konnte kein Pfad gefunden werden.</li>
 </ul>

 Wird der Node Filter weggelassen, wird automatisch eine Funktion erstellt,
 die alle Positionen ausschließt, die geblockt sind.






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Standard Wegsuche
</span>MyPathID = API.StartPathfinding(<span class="string">"Start"</span>, <span class="string">"End"</span>);</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Wegsuche mit Filter
</span>MyPathID = API.StartPathfinding(<span class="string">"Start"</span>, <span class="string">"End"</span>, <span class="keyword">function</span>(_CurrentNode, _AdjacentNodes)
    <span class="comment">-- Position verwerfen, wenn sie im Blocking ist
</span>    <span class="keyword">if</span> Logic.DEBUG_GetSectorAtPosition(_CurrentNode.X, _CurrentNode.Y) == <span class="number">0</span> <span class="keyword">then</span>
        <span class="keyword">return</span> <span class="keyword">false</span>;
    <span class="keyword">end</span>
    <span class="comment">-- Position verwerfen, wenn sie auf Territorium 16 liegt
</span>    <span class="keyword">if</span> Logic.GetTerritoryAtPosition(_CurrentNode.X, _CurrentNode.Y) == <span class="number">16</span> <span class="keyword">then</span>
        <span class="keyword">return</span> <span class="keyword">false</span>;
    <span class="keyword">end</span>
    <span class="comment">-- Position akzeptieren
</span>    <span class="keyword">return</span> <span class="keyword">true</span>;
<span class="keyword">end</span>);</pre></li>


</ul>


