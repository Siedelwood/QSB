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


### API.InstanceTable (_Source, _Dest)
source/tqsb_x_acomp.lua.html#49

Kopiert eine komplette Table und gibt die Kopie zurück.  Tables können
 nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
 Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
 angegebenen Tables.
 Die Funktion arbeitet rekursiv.

 <b>Alias:</b> CopyTableRecursive






### Beispiel:
<ul>


<pre class="example">Table = {<span class="number">1</span>, <span class="number">2</span>, <span class="number">3</span>, {a = <span class="keyword">true</span>}}
Copy = API.InstanceTable(Table)</pre>


</ul>


### API.TraverseTable (_Data, _Table)
source/tqsb_x_acomp.lua.html#68

Sucht in einer eindimensionalen Table nach einem Wert.  Das erste Auftreten des Suchwerts wird als Erfolg gewertet. Es können praktisch alle Lua-Werte gesucht werden.

 <b>Alias:</b> Inside






### Beispiel:
<ul>


<pre class="example">Table = {<span class="number">1</span>, <span class="number">2</span>, <span class="number">3</span>, {a = <span class="keyword">true</span>}}
<span class="keyword">local</span> Found = API.TraverseTable(<span class="number">3</span>, Table)</pre>


</ul>


