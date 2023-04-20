# Module <code>qsb_2_selection</code>
Die Optionen für selektierte Einheiten können individualisiert werden.
 Es wird ein Button zum Entlassen von Einheiten hinzugefügt.</p>

<p> <table border="1">
 <tr><td><b>Einheitentyp</b></td><td><b>Vorsteinstellung</b></td></tr>
 <tr><td>Soldaten</td><td>aktiv</td></tr>
 <tr><td>Kriegsmaschinen</td><td>aktiv</td></tr>
 <tr><td>Diebe</td><td>deaktiviert</td></tr>
 </table></p>

<p> Trebuchets haben nun das gleiche Menü, wie die anderen Kriegsmaschinen. Sie
 können jedoch nicht abgebaut werden.</p>

<p> <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 <li><a href="modules.QSB_1_GuiControl.QSB_1_GuiControl.html">(1) Anzeigekontrolle</a></li>
 </ul>

### QSB.ScriptEvents
source/qsb_2_selection.lua.html#35

Events, auf die reagiert werden kann.





### API.DisableReleaseSiegeEngines (_Flag)
source/qsb_2_selection.lua.html#64

Deaktiviert oder aktiviert das Entlassen von Kriegsmaschinen.





### Beispiel:
<ul>


<pre class="example">API.DisableReleaseSiegeEngines(<span class="keyword">true</span>);</pre>


</ul>


### API.DisableReleaseSoldiers (_Flag)
source/qsb_2_selection.lua.html#83

Deaktiviert oder aktiviert das Entlassen von Soldaten.





### Beispiel:
<ul>


<pre class="example">API.DisableReleaseSoldiers(<span class="keyword">false</span>);</pre>


</ul>


### API.DisableReleaseThieves (_Flag)
source/qsb_2_selection.lua.html#45

Deaktiviert oder aktiviert das Entlassen von Dieben.





### Beispiel:
<ul>


<pre class="example">API.DisableReleaseThieves(<span class="keyword">false</span>);</pre>


</ul>


### API.GetSelectedEntities (_PlayerID)
source/qsb_2_selection.lua.html#158

Gibt alle selektierten Entities zurück.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Selection = API.GetSelectedEntities(<span class="number">1</span>);</pre>


</ul>


### API.GetSelectedEntity (_PlayerID)
source/qsb_2_selection.lua.html#138

Gibt die ID des selektierten Entity zurück.

 Wenn mehr als ein Entity selektiert sind, wird das erste Entity
 zurückgegeben. Sind keine Entities selektiert, wird 0 zurückgegeben.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> SelectedEntity = API.GetSelectedEntity(<span class="number">1</span>);</pre>


</ul>


### API.IsEntityInSelection (_Entity, _PlayerID)
source/qsb_2_selection.lua.html#107

Prüft ob das Entity selektiert ist.





### Beispiel:
<ul>


<pre class="example"><span class="keyword">if</span> API.IsEntityInSelection(<span class="string">"hakim"</span>, <span class="number">1</span>) <span class="keyword">then</span>
    <span class="comment">-- Do something
</span><span class="keyword">end</span></pre>


</ul>


