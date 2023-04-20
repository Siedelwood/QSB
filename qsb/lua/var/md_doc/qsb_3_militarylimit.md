# Module <code>qsb_3_militarylimit</code>
Dieses Modul ermöglicht es das Soldatenlimit eines Spielers frei festzulegen.
 <b>Hinweis</b>: Wird nichts eingestellt, wird der Standard verwendet. Das
 Limit ist dann 25, 43, 61, 91 (je nach Ausbaustufe der Burg).</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_3_militarylimit.lua.html#25

Events, auf die reagiert werden kann.





### API.GetPlayerSoldierLimit (_PlayerID)
source/qsb_3_militarylimit.lua.html#37

Gibt das aktuelle Soldatenlimit des Spielers zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Limit = API.GetPlayerSoldierLimit(<span class="number">1</span>);</pre>


</ul>


### API.SetPlayerSoldierLimit (_PlayerID, _Function)
source/qsb_3_militarylimit.lua.html#59

Setzt die Funktion zur Berechnung des Soldatenlimit.

 Wird die Funktion nil gesetzt, wird der Standard in Abhängigkeit der
 Burgausbaustufe verwendet.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Verwende den Standard (25, 43, 61, 91)
</span>API.SetPlayerSoldierLimit(<span class="number">1</span>);
<span class="comment">-- Verwende eigene Funktion (Limit ist für den Spieler immer 2000)
</span>API.SetPlayerSoldierLimit(<span class="number">1</span>, <span class="keyword">function</span>(_PlayerID)
    <span class="keyword">return</span> <span class="number">2000</span>;
<span class="keyword">end</span>);</pre>


</ul>


