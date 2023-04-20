# Module <code>qsb_1_requester</code>
Stellt verschiedene Dialog- oder Textfenster zur Verfügung.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### API.DefineLanguage (_Shortcut, _Name, _Fallback)
source/qsb_1_requester.lua.html#240

Fügt eine neue Sprache zur Auswahl hinzu.





### Beispiel:
<ul>


<pre class="example">API.DefineLanguage(<span class="string">"sx"</span>, <span class="string">"Sächsich"</span>, <span class="string">"de"</span>)</pre>


</ul>


### API.DialogInfoBox (_PlayerID, _Title, _Text, _Action)
source/qsb_1_requester.lua.html#81

Öffnet einen Info-Dialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 An die Action wird der Spieler übergeben, der den Dialog bestätigt hat.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.






### Beispiel:
<ul>


<pre class="example">API.DialogInfoBox(<span class="string">"Wichtige Information"</span>, <span class="string">"Diese Information ist Spielentscheidend!"</span>);</pre>


</ul>


### API.DialogLanguageSelection (_PlayerID)
source/qsb_1_requester.lua.html#201

Öffnet den Dialog für die Auswahl der Sprache.  Deutsch, Englisch und
 Französisch sind vorkonfiguriert.






### Beispiel:
<ul>


<pre class="example"><span class="comment">-- Für alle Spieler
</span>API.DialogLanguageSelection();
<span class="comment">-- Nur für Spieler 2 anzeigen
</span>API.DialogLanguageSelection(<span class="number">2</span>);</pre>


</ul>


### API.DialogRequestBox (_PlayerID, _Title, _Text, _Action, _OkCancel)
source/qsb_1_requester.lua.html#123

Öffnet einen Ja-Nein-Dialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
 Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
 Entscheidung getroffen hat, plus die ID des Spielers.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">function</span> YesNoAction(_Yes, _PlayerID)
    <span class="keyword">if</span> _Yes <span class="keyword">then</span> GUI.AddNote(<span class="string">"Ja wurde gedrückt"</span>); <span class="keyword">end</span>
<span class="keyword">end</span>
API.DialogRequestBox(<span class="string">"Frage"</span>, <span class="string">"Möchtest du das wirklich tun?"</span>, YesNoAction, <span class="keyword">false</span>);</pre>


</ul>


### API.DialogSelectBox (_PlayerID, _Title, _Text, _Action, _List)
source/qsb_1_requester.lua.html#167

Öffnet einen Auswahldialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
 aus. Anschließend erhält das Callback den Index der selektierten Option und
 die ID des Spielers, der den Dialog bestätigt hat.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">function</span> OptionsAction(_Idx, _PlayerID)
    GUI.AddNote(_Idx.. <span class="string">" wurde ausgewählt!"</span>);
<span class="keyword">end</span>
<span class="keyword">local</span> List = {<span class="string">"Option A"</span>, <span class="string">"Option B"</span>, <span class="string">"Option C"</span>};
API.DialogSelectBox(<span class="string">"Auswahl"</span>, <span class="string">"Wähle etwas aus!"</span>, OptionsAction, List);</pre>


</ul>


### API.TextWindow (_Caption, _Content, _PlayerID)
source/qsb_1_requester.lua.html#44

Öffnet ein einfaches Textfenster mit dem angegebenen Text.

 Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
 Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.

 <h5>Multiplayer</h5>
 Im Multiplayer muss zwingend der Spieler angegeben werden, für den das
 Fenster angezeigt werden soll.






### Beispiel:
<ul>


<pre class="example"><span class="keyword">local</span> Text = <span class="string">"Lorem ipsum dolor sit amet, consetetur sadipscing elitr,"</span>..
             <span class="string">" sed diam nonumy eirmod tempor invidunt ut labore et dolore"</span>..
             <span class="string">" magna aliquyam erat, sed diam voluptua. At vero eos et"</span>..
             <span class="string">" accusam et justo duo dolores et ea rebum. Stet clita kasd"</span>..
             <span class="string">" gubergren, no sea takimata sanctus est Lorem ipsum dolor"</span>..
             <span class="string">" sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing"</span>..
             <span class="string">" elitr, sed diam nonumy eirmod tempor invidunt ut labore et"</span>..
             <span class="string">" dolore magna aliquyam erat, sed diam voluptua. At vero eos"</span>..
             <span class="string">" et accusam et justo duo dolores et ea rebum. Stet clita"</span>..
             <span class="string">" kasd gubergren, no sea takimata sanctus est Lorem ipsum"</span>..
             <span class="string">" dolor sit amet."</span>;
API.TextWindow(<span class="string">"Überschrift"</span>, Text);</pre>


</ul>


