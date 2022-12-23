# Einleitung

Dieses Projekt befasst sich ausschließlich mit der Questbibliothek des Spiels 
"DIE SIEDLER - Aufstieg eines Königreiches". Ziel ist es, dem Benutzer eine 
frei konfigurierbare Bibliothek in die Hände zu geben, um das allgemeine Niveau 
der Maps in der Community zu heben.

Des Weiteren soll das entstehende Produkt um benutzerdefinierte Module erweitert 
werden können, sodass der Mapper die absolute Gestaltungsfreiheit hat.

# Entwicklung

Um die QSB zu entwickeln, muss das Repository zuerst geklont werden. Dafür wird 
die Versionsverwaltung Git benötigt.
Eine Windows-Version von Git kann hier heruntergeladen werden:

`https://git-scm.com/download/win`

Git-Bash muss dann entsprechend dem PATH hinzugefügt werden.

### Klonen des Repository

Das Repository kann ganz normal über Git geklont werden.

```
$ git clone https://github.com/totalwarANGEL1993/Revision.git
```

### Lua installieren

Damit die Tools funktionieren, wird eine Lua-Installation benötigt. Es wird die
gleiche Version vorausgesetzt, die auf das Spiel verwendet. Lua kann hier für
Windows heruntergeladen werden:

`https://www.softpedia.com/get/Programming/Coding-languages-Compilers/Lua-for-Windows.shtml#download`

Lua muss dann entsprechend dem PATH hinzugefügt werden.

### Contribute

Eine Änderung wird eingestellt, in dem im Tab Pull Requests eine solche 
erstellt wird.

### QSB bauen

Die QSB kann mit dem Skript `build` gebaut werden. Das Skript baut die Dateien 
zusammen und legt sie im Verzeichnis `qsb/lua/var/build` ab. Zum bauen wird 
die Bash-Konsole von Git-Bash verwendet.

Befehl dazu:

```
$ qsb/exe/build
```

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