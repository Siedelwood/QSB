# Einleitung

Dieses Projekt befasst sich mit der Questbibliothek QSB der Siedelwood-Community für das Spiel "DIE SIEDLER - Aufstieg eines Königreiches".
Ziel ist es, allen Mappern der Community eine umfangreiche Sammlung an Quests und Funktionen anzubieten, die bei Fehlern zeitnah korrigiert werden und dabei möglichst beste Kompatibilität mit bisherigen damit entwickelten Maps bietet.

Die Hier entwickelte QSB gibt es in drei Varianten:
- die Kern-QSB (qsb.lua), in der nur die minimalsten Features enthalten sind bei der alle Module vom Mapper nach bedarf selbst hinzugeladen werden können.
- die Gesamt-QSB (qsb_all.lua), welche die Kern-QSB sowie alle Module beinhaltet.
- die Kompatibilitäts-QSB (qsb_comp.lua), welche die Gesamt-QSB und zusätzliche Aliase enthält, um eine möglichst vollständige Kompatibilität mit der früheren QSB 2.14.9 zu gerwährleisten.

# Entwicklung

Um zu erfahren, wie du an der Entwicklung der QSB teilnehmen kannst schau dir gern unsere Seite zum [Mitmachen an der QSB](./CONTRIBUTING.md) an.

### Dokumentation bauen

Damit die HTML-Dokumentation gebaut werden kann, wird der HTML-Parser von
msva benötig. Dieser kann mittels LuaRocks installiert werden.

```
$ luarocks install htmlparser
```

Sollte das nicht funktionieren, kann der HTML-Parser auch direkt in das
Bibliotheksverzeichnis geschoben werden. Der Lua Quellcode kann unter dem
folgenden Link heruntergeladen werden:

`https://github.com/msva/lua-htmlparser/tree/master/src`

Der Inhalt des Ordners muss nach `lib\lua` im Installationsverzeichnis
von Lua for Windows kopiert werden.