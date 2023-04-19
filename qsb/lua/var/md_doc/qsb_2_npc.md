# Module <code>qsb_2_npc</code>
Der Held muss einen Nichtspielercharakter ansprechen.
 Es wird automatisch ein NPC erzeugt und überwacht, sobald der Quest
 aktiviert wurde. Ein NPC darf nicht auf geblocktem Gebiet stehen oder
 seine Enity-ID verändern.</p>

<p> <b>Hinweis</b>: Jeder Siedler kann zu jedem Zeitpunkt nur <u>einen</u> NPC
 haben. Wird ein weiterer NPC zugewiesen, wird der alte überschrieben und
 der verknüpfte Quest funktioniert nicht mehr!

### QSB.ScriptEvents
source/qsb_2_npc.lua.html#87

Events, auf die reagiert werden kann.





### API.NpcCompose (_Data)
source/qsb_2_npc.lua.html#179

Erstellt einen neuen NPC für den angegebenen Siedler.

 Mögliche Einstellungen für den NPC:
 <table border="1">
 <tr>
 <th><b>Eigenschaft</b></th>
 <th><b>Beschreibung</b></th>
 </tr>
 <tr>
 <td>Name</td>
 <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
 </tr>
 <tr>
 <td>Type</td>
 <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
 vorhanden, den Anzeigemodus des NPC Icon.</td>
 </tr>
 <tr>
 <td>Condition</td>
 <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
 </tr>
 <tr>
 <td>Callback</td>
 <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Player</td>
 <td>(number|table) Spieler, der/die mit dem NPC sprechen kann/können.</td>
 </tr>
 <tr>
 <td>WrongPlayerAction</td>
 <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Hero</td>
 <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongHeroAction</td>
 <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
 </tr>
 </table>






### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Einfachen NPC erstellen
</span>MyNpc = API.NpcCompose {
    Name     = <span class="string">"HansWurst"</span>,
    Callback = <span class="keyword">function</span>(_Data)
        <span class="keyword">local</span> HeroID = QSB.LastHeroEntityID;
        <span class="keyword">local</span> NpcID = GetID(_Data.Name);
        <span class="comment">-- mach was tolles
</span>    <span class="keyword">end</span>
}</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: NPC mit Bedingung erstellen
</span>MyNpc = API.NpcCompose {
    Name      = <span class="string">"HansWurst"</span>,
    Condition = <span class="keyword">function</span>(_Data)
        <span class="keyword">local</span> NpcID = GetID(_Data.Name);
        <span class="comment">-- prüfe irgend was
</span>        <span class="keyword">return</span> MyConditon == <span class="keyword">true</span>;
    <span class="keyword">end</span>
    Callback  = <span class="keyword">function</span>(_Data)
        <span class="keyword">local</span> HeroID = QSB.LastHeroEntityID;
        <span class="keyword">local</span> NpcID = GetID(_Data.Name);
        <span class="comment">-- mach was tolles
</span>    <span class="keyword">end</span>
}</pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: NPC auf Spieler beschränken
</span>MyNpc = API.NpcCompose {
    Name              = <span class="string">"HansWurst"</span>,
    Player            = {<span class="number">1</span>, <span class="number">2</span>},
    WrongPlayerAction = <span class="keyword">function</span>(_Data)
        API.Note(<span class="string">"Ich rede nicht mit Euch!"</span>);
    <span class="keyword">end</span>,
    Callback          = <span class="keyword">function</span>(_Data)
        <span class="keyword">local</span> HeroID = QSB.LastHeroEntityID;
        <span class="keyword">local</span> NpcID = GetID(_Data.Name);
        <span class="comment">-- mach was tolles
</span>    <span class="keyword">end</span>
}</pre></li>


</ul>


### API.NpcDispose (_Data)
source/qsb_2_npc.lua.html#207

Entfernt den NPC komplett vom Entity.  Das Entity bleibt dabei erhalten.






### Beispiel:
<ul>


<pre class="example">API.NpcDispose(MyNpc);</pre>


</ul>


### API.NpcUpdate (_Data)
source/qsb_2_npc.lua.html#283

Aktualisiert die Daten des NPC.

 Mögliche Einstellungen für den NPC:
 <table border="1">
 <tr>
 <th><b>Eigenschaft</b></th>
 <th><b>Beschreibung</b></th>
 </tr>
 <tr>
 <td>Name</td>
 <td>(string) Skriptname des NPC. Dieses Attribut wird immer benötigt!</td>
 </tr>
 <tr>
 <td>Type</td>
 <td>(number) Typ des NPC. Zahl zwischen 1 und 4 möglich. Bestimmt, falls
 vorhanden, den Anzeigemodus des NPC Icon.</td>
 </tr>
 <tr>
 <td>Condition</td>
 <td>(function) Bedingung, um die Konversation auszuführen. Muss boolean zurückgeben.</td>
 </tr>
 <tr>
 <td>Callback</td>
 <td>(function) Funktion, die bei erfolgreicher Aktivierung ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Player</td>
 <td>(number) Spieler, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongPlayerAction</td>
 <td>(function) Funktion, die für einen falschen Spieler ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Hero</td>
 <td>(string) Skriptnamen von Helden, die mit dem NPC sprechen können.</td>
 </tr>
 <tr>
 <td>WrongHeroAction</td>
 <td>(function) Funktion, die für einen falschen Helden ausgeführt wird.</td>
 </tr>
 <tr>
 <td>Active</td>
 <td>(boolean) Steuert, ob der NPC aktiv ist.</td>
 </tr>
 </table>






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Einen NPC wieder aktivieren
</span>MyNpc.Active = <span class="keyword">true</span>;
MyNpc.TalkedTo = <span class="number">0</span>;
<span class="comment">-- Die Aktion ändern
</span>MyNpc.Callback = <span class="keyword">function</span>(_Data)
    <span class="comment">-- mach was hier
</span><span class="keyword">end</span>;
API.NpcUpdate(MyNpc);</pre>


</ul>


### API.NpcIsActive (_Data)
source/qsb_2_npc.lua.html#308

Prüft, ob der NPC gerade aktiv ist.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">if</span> API.NpcIsActive(MyNpc) <span class="keyword">then</span></pre>


</ul>


### API.NpcTalkedTo (_Data, _Hero, _PlayerID)
source/qsb_2_npc.lua.html#345

Prüft, ob ein NPC schon gesprochen hat und optional auch mit wem.





### Beispiel:
<ul>


<li><pre class="example"><span class="comment">-- Beispiel #1: Wurde mit NPC gesprochen
</span><span class="keyword">if</span> API.NpcTalkedTo(MyNpc) <span class="keyword">then</span></pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #2: Spieler hat mit NPC gesprochen
</span><span class="keyword">if</span> API.NpcTalkedTo(MyNpc, <span class="keyword">nil</span>, <span class="number">1</span>) <span class="keyword">then</span></pre></li>


<li><pre class="example"><span class="comment">-- Beispiel #3: Held des Spielers hat mit NPC gesprochen
</span><span class="keyword">if</span> API.NpcTalkedTo(MyNpc, <span class="string">"Marcus"</span>, <span class="number">1</span>) <span class="keyword">then</span></pre></li>


</ul>


