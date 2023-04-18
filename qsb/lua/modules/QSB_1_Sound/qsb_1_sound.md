### API.Play2DSound (_Sound, _PlayerID)

Spielt einen 2D-Sound aus dem Spiel ab.

 Ein 2D-Sound ist nicht positionsgebunden und ist immer zu hören, egal an
 welcher Stelle auf der Map sich die Kamera befindet.

 Wenn eigene Sounds verwendet werden sollen, müssen sie im WAV-Format
 vorliegen und in die zwei Verzeichnisse für niedrige und hohe Qualität
 kopiert werden.

 Verzeichnisstruktur für eigene Sounds:
 <pre>map_xyz.s6xmap.unpacked
|-- sounds/high/ui/*
|-- sounds/low/ui/*
|-- maps/externalmap/map_xyz/*
|-- ...</pre>


### API.Play3DSound (_Sound, _X, _Y, _Z, _PlayerID)

Spielt einen 3D-Sound aus dem Spiel ab.

 Ein 3D-Sound wird an einer bestimmten Position abgespielt und ist nur in
 einem begrenzten Bereich um die Position höhrbar.

 Wenn eigene Sounds verwendet werden sollen, müssen sie im WAV-Format
 vorliegen und in die zwei Verzeichnisse für niedrige und hohe Qualität
 kopiert werden.

 Verzeichnisstruktur für eigene Sounds:
 <pre>map_xyz.s6xmap.unpacked
|-- sounds/high/ui/*
|-- sounds/low/ui/*
|-- maps/externalmap/map_xyz/*
|-- ...</pre>


### API.PlayVoice (_File)

Gibt eine MP3-Datei als Stimme wieder.  Diese Funktion kann auch benutzt
 werden um Geräusche abzuspielen.


### API.SoundRestore ()

Stellt den Sound wieder her, sofern ein Backup erstellt wurde.

### API.SoundSetAtmoVolume (_Volume)

Setzt die Lautstärke der Umgebung.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.


### API.SoundSetMusicVolume (_Volume)

Setzt die Lautstärke der Musik.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.


### API.SoundSetUIVolume (_Volume)

Setzt die Lautstärke des Interface.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.


### API.SoundSetVoiceVolume (_Volume)

Setzt die Lautstärke der Stimmen.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.


### API.SoundSetVolume (_Volume)

Setzt die allgemeine Lautstärke.  Die allgemeine Lautstärke beeinflusst alle
 anderen Laufstärkeregler.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.


### API.StartEventPlaylist (_Playlist, _PlayerID)

Startet eine Playlist, welche als XML angegeben ist.

 Eine als XML definierte Playlist wird nicht als Voice abgespielt sondern
 als Music. Als Musik werden MP3-Dateien verwendet. Diese können entweder
 im Spiel vorhanden sein oder im Ordner <i>music/</i> im Root-Verzeichnis
 des Spiels gespeichert werden. Die Playlist gehört ebenfalls ins Root-
 Verzeichnis nach <i>config/sound/</i>.

 Verzeichnisstruktur für eigene Musik:
 <pre>map_xyz.s6xmap.unpacked
|-- music/*
|-- config/sound/*
|-- maps/externalmap/map_xyz/*
|-- ...</pre>

 In der QSB sind bereits die Variablen <i>gvMission.MusicRootPath</i> und
 <i>gvMission.PlaylistRootPath</i> mit den entsprechenden Pfaden vordefiniert.

 Wenn du eigene Musik verwendest, achte darauf, einen möglichst eindeutigen
 Namen zu verwenden. Und natürlich auch auf Urheberrecht!

 Beispiel für eine Playlist:
 <pre>
&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;PlayList&gt;
 &lt;PlayListEntry&gt;
   &lt;FileName&gt;Music\some_music_file.mp3&lt;/FileName&gt;
   &lt;Type&gt;Loop&lt;/Type&gt;
 &lt;/PlayListEntry&gt;
 &lt;!-- Hier können weitere Einträge folgen. --&gt;
&lt;/PlayList&gt;
</pre>
 Als Typ können "Loop" oder "Normal" gewählt werden. Normale Musik wird
 einmalig abgespielt. Ein Loop läuft endlos weiter.

 Außerdem kann zusätzlich zum Typ eine Abspielwahrscheinlichkeit mit
 angegeben werden:
 <pre>&lt;Chance&gt;10&lt;/Chance&gt;</pre>
 Es sind Zahlen von 1 bis 100 möglich.


### API.StopEventPlaylist (_Playlist, _PlayerID)

Beendet eine Event Playlist.

### API.StopVoice ()

Stoppt alle als Stimme abgespielten aktiven Sounds.

