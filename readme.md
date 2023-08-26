# Einleitung

Dieses Projekt befasst sich mit der Questbibliothek (QSB) der Siedelwood-Community für das Spiel "DIE SIEDLER - Aufstieg eines Königreiches".
Ziel ist es allen Mappern der Community eine umfangreiche Sammlung an Quests und Funktionen anzubieten, die bei Fehlern zeitnah korrigiert werden und dabei möglichst beste Kompatibilität mit bisherigen damit entwickelten Maps bietet.

Die Hier entwickelte QSB gibt es in drei Varianten:
- die Kern-QSB (qsb.lua), in der nur die minimalsten Features enthalten sind bei der alle Module vom Mapper nach bedarf selbst hinzugeladen werden können.
- die Gesamt-QSB (qsb_all.lua), welche die Kern-QSB sowie alle Module beinhaltet.
- die Kompatibilitäts-QSB (qsb_comp.lua), welche die Gesamt-QSB und zusätzliche Aliase enthält, um eine möglichst vollständige Kompatibilität mit der früheren QSB 2.14.9 zu gerwährleisten.

# Entwicklung

Wenn du ein Addon für die QSB entwickeln möchtest, schau dir unser [QSB-Addon Tutorial](./qsb/lua/addons/readme.md) an.

Um zu erfahren, wie du an der Entwicklung der QSB teilnehmen kannst schau dir gern unsere Seite zum [Mitmachen an der QSB](./CONTRIBUTING.md) an.

# Die QSB selbst bauen

Die QSB wird bei jeder veröffentlichten Version von uns gebaut und als release zur Verfügung gestellt. Wenn du gerne Dinge anpassen möchtest und deine Version bauen möchtest kannst du dir die [Bauanleitung](./qsb/exe/readme.md) ansehen.

# Changelog

Eine Detailierte Änderungshistorie seit der ersten aktuellen Beta der QSB3 gibt es [hier](./changelog.md).