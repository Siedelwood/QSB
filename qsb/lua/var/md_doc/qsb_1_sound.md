# Module <code>qsb_1_sound</code>
Ermöglicht die Steuerung der Laufstärke und Ausgabe von Sounds.
 <b>Vorausgesetzte Module:</b>
 <ul>
 <li><a href="qsb.html">(0) Basismodul</a></li>
 </ul>

### API.Play2DSound (_Sound, _PlayerID)
source/qsb_1_sound.lua.html#118

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






### Beispiel:
<ul>


<pre class="example">API.Play2DSound(<span class="string">"ui/menu_left_gold_pay"</span>);</pre>


</ul>


### API.Play3DSound (_Sound, _X, _Y, _Z, _PlayerID)
source/qsb_1_sound.lua.html#161

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






### Beispiel:
<ul>


<pre class="example">API.Play3DSound(<span class="string">"Animals/cow_disease"</span>, <span class="number">8500</span>, <span class="number">35800</span>, <span class="number">2000</span>);</pre>


</ul>


### API.PlayVoice (_File)
source/qsb_1_sound.lua.html#329

Gibt eine MP3-Datei als Stimme wieder.  Diese Funktion kann auch benutzt
 werden um Geräusche abzuspielen.






### Beispiel:
<ul>


<pre class="example">API.PlayVoice(<span class="string">"music/puhdys_alt_wie_ein_baum.mp3"</span>);</pre>


</ul>


### API.SoundRestore ()
source/qsb_1_sound.lua.html#311

Stellt den Sound wieder her, sofern ein Backup erstellt wurde.





### Beispiel:
<ul>


<pre class="example">API.SoundRestore();</pre>


</ul>


### API.SoundSave ()
source/qsb_1_sound.lua.html#295

Erstellt ein Backup der Soundeinstellungen, wenn noch keins erstellt wurde.





### Beispiel:
<ul>


<pre class="example">API.SoundSave();</pre>


</ul>


### API.SoundSetAtmoVolume (_Volume)
source/qsb_1_sound.lua.html#257

Setzt die Lautstärke der Umgebung.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.






### Beispiel:
<ul>


<pre class="example">API.SoundSetAtmoVolume(<span class="number">100</span>);</pre>


</ul>


### API.SoundSetMusicVolume (_Volume)
source/qsb_1_sound.lua.html#215

Setzt die Lautstärke der Musik.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.






### Beispiel:
<ul>


<pre class="example">API.SoundSetMusicVolume(<span class="number">100</span>);</pre>


</ul>


### API.SoundSetUIVolume (_Volume)
source/qsb_1_sound.lua.html#278

Setzt die Lautstärke des Interface.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.






### Beispiel:
<ul>


<pre class="example">API.SoundSetUIVolume(<span class="number">100</span>);</pre>


</ul>


### API.SoundSetVoiceVolume (_Volume)
source/qsb_1_sound.lua.html#236

Setzt die Lautstärke der Stimmen.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.






### Beispiel:
<ul>


<pre class="example">API.SoundSetVoiceVolume(<span class="number">100</span>);</pre>


</ul>


### API.SoundSetVolume (_Volume)
source/qsb_1_sound.lua.html#194

Setzt die allgemeine Lautstärke.  Die allgemeine Lautstärke beeinflusst alle
 anderen Laufstärkeregler.

 <b>Hinweis:</b> Es wird automatisch ein Backup der Einstellungen angelegt
 wenn noch keins angelegt wurde.






### Beispiel:
<ul>


<pre class="example">API.SoundSetVolume(<span class="number">100</span>);</pre>


</ul>


### API.StartEventPlaylist (_Playlist, _PlayerID)
source/qsb_1_sound.lua.html#62

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






### Beispiel:
<ul>


<pre class="example">API.StartEventPlaylist(gvMission.PlaylistRootPath ..<span class="string">"my_playlist.xml"</span>);</pre>


</ul>


### API.StopEventPlaylist (_Playlist, _PlayerID)
source/qsb_1_sound.lua.html#83

Beendet eine Event Playlist.





### Beispiel:
<ul>


<pre class="example">API.StopEventPlaylist(<span class="string">"config/sound/my_playlist.xml"</span>);</pre>


</ul>


### API.StopVoice ()
source/qsb_1_sound.lua.html#346

Stoppt alle als Stimme abgespielten aktiven Sounds.





### Beispiel:
<ul>


<pre class="example">API.StopVoice();</pre>


</ul>


