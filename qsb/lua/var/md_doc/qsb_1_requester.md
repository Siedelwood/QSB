### API.DefineLanguage (_Shortcut, _Name, _Fallback)

Fügt eine neue Sprache zur Auswahl hinzu.

### API.DialogInfoBox (_PlayerID, _Title, _Text, _Action)

Öffnet einen Info-Dialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 An die Action wird der Spieler übergeben, der den Dialog bestätigt hat.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.


### API.DialogLanguageSelection (_PlayerID)

Öffnet den Dialog für die Auswahl der Sprache.  Deutsch, Englisch und
 Französisch sind vorkonfiguriert.


### API.DialogRequestBox (_PlayerID, _Title, _Text, _Action, _OkCancel)

Öffnet einen Ja-Nein-Dialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 Um die Entscheigung des Spielers abzufragen, wird ein Callback benötigt.
 Das Callback bekommt eine Boolean übergeben, sobald der Spieler die
 Entscheidung getroffen hat, plus die ID des Spielers.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.


### API.DialogSelectBox (_PlayerID, _Title, _Text, _Action, _List)

Öffnet einen Auswahldialog.  Sollte bereits ein Dialog zu sehen sein, wird
 der Dialog der Dialogwarteschlange hinzugefügt.

 In diesem Dialog wählt der Spieler eine Option aus einer Liste von Optionen
 aus. Anschließend erhält das Callback den Index der selektierten Option und
 die ID des Spielers, der den Dialog bestätigt hat.

 <b>Hinweis</b>: Kann nicht aus dem globalen Skript heraus benutzt werden.


### API.TextWindow (_Caption, _Content, _PlayerID)

Öffnet ein einfaches Textfenster mit dem angegebenen Text.

 Die Länge des Textes ist nicht beschränkt. Überschreitet der Text die
 Größe des Fensters, wird automatisch eine Bildlaufleiste eingeblendet.

 <h5>Multiplayer</h5>
 Im Multiplayer muss zwingend der Spieler angegeben werden, für den das
 Fenster angezeigt werden soll.


