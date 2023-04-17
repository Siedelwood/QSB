# Die Scripte

Es gibt insgesamt vier Scripte die für das bauen der QSB relevant sind:
- 'build_source' erzeugt die drei Varianten der QSB, die Module und die Addons.
- 'build_doc' erzeugt aus den ldoc Abschnitten im Code eine Dokumentation für die QSB.
- 'minify_source' erzeugt eine minifyte Version der QSB.
Hier werden  nur Teile des Script entfernt oder verkürzt damit die Datei kleiner ist.
- 'compile_source' erzeugt aus der minified QSB den lua Bytecode.
Dieser ermöglicht ein schnelleres laden einer Map, da der lua Code nicht mehr zum Spielstart kompiliert werden muss.

Von diesen 4 Scripten ist mir das erste relevant, wenn es nur darum geht die gemachten Änderungen oder eingeführten Features zu testen.
Das Bauen der Dokumentation und hinzufügen einer kompilierten Version wird mit jedem offiziellen Release von und durchgeführt und in der Release-zip zur Verfügung gestellt.

# Technische Voraussetzungen

Da die aufgelisteten Scripte bash Scripte sind muss es als Voraussetzung möglich sein diese laufen zu lassen.
Auf Linux sollte das von vornerein gehen. Für Windows empfiehlt es sich eine kompatible Konsole zu installieren (bspw. Gitbash).

Für alle Schritte (außer dem Bauen der QSB) ist eine lua Installation auf dem Rechner notwendig, da die Bash-Scripte intern auch lua-Scripte ausführen.
