# Scales Changelog

## 0.1.3

**English**
- Classic (TBC Anniversary, Classic Era, Cata, Mists): the Scales rating now also appears in auction house, vendor, loot, mail and trade tooltips
- Bag arrows now also appear in Bagnon
- A Scales error can no longer break an item tooltip; other addons' hidden scan tooltips are left alone
- `/scales debug` shows which bag addon is used and the last tooltip error

**Deutsch**
- Classic (TBC Anniversary, Classic Era, Cata, Mists): Die Scales-Bewertung erscheint jetzt auch in Tooltips von Auktionshaus, Händler, Beute, Post und Handel
- Taschenpfeile erscheinen jetzt auch in Bagnon
- Ein Fehler in Scales kann keinen Item-Tooltip mehr kaputt machen; versteckte Scan-Tooltips anderer Addons bleiben unberührt
- `/scales debug` zeigt, welches Taschen-Addon genutzt wird, und den letzten Tooltip-Fehler

## 0.1.2

**English**
- EllesmereUI Bags: the upgrade arrows are now visible – they sit in the bottom right corner (like Pawn's arrow) instead of under the item level
- New command `/scales debug` shows what the bag integration sees, to help with bug reports

**Deutsch**
- EllesmereUI Bags: Die Upgrade-Pfeile sind jetzt sichtbar – sie sitzen unten rechts (wie der Pawn-Pfeil) statt unter der Gegenstandsstufe
- Neuer Befehl `/scales debug` zeigt, was die Taschen-Anbindung sieht, als Hilfe für Fehlermeldungen

## 0.1.1

**English**
- Bag arrows now also appear in EllesmereUI Bags (bags and bank)
- Character window: the stats are shown on two lines, so no value is split from its name any more
- Options window is wider, so all texts fit

**Deutsch**
- Taschenpfeile erscheinen jetzt auch in EllesmereUI Bags (Taschen und Bank)
- Charakterfenster: Die Werte stehen auf zwei Zeilen, kein Wert wird mehr von seinem Namen getrennt
- Das Optionsfenster ist breiter, damit alle Texte hineinpassen

## 0.1.0

**English**
- First release for Retail (Midnight), WoW: Forever, Mists of Pandaria Classic, Cataclysm Classic, TBC Anniversary and Classic Era
- Simulates your character automatically: damage per second for damage dealers, healing per second for healers, effective health and mitigation for tanks
- Every item tooltip shows whether it is an upgrade or a downgrade compared to what you are wearing, in percent and as a DPS/HPS/EHP change
- Green arrow up on upgrades and red arrow down on downgrades in your bags (each can be turned off)
- Minimap button (drag to move, left click: window, right click: options); in Retail also in the addon compartment
- Compare all your specializations like Pawn: the tooltip shows one extra line per ticked spec, so you see at a glance whether an item is better for damage, healing or tanking
- Spec bar in the window: click a specialization to see its simulation and item ratings; the tick box decides whether it appears in tooltips
- Gold arrow in your bags for items that are an upgrade for another ticked spec
- Options window: tooltip rating, bag arrows and minimap button on or off
- English and German; the language follows your game client or can be chosen in the options or with `/scales language en|de|auto`
- Trinket effects (Use, Equip, Chance on hit) are estimated for your role
- Armor you cannot wear is marked; in Retail, items of the wrong armor type never count as upgrades
- Window with `/scales` and a live preview while hovering items
- Recalculates after combat instead of during combat, so it never interferes with fights

**Deutsch**
- Erste Version für Retail (Midnight), WoW: Forever, Mists of Pandaria Classic, Cataclysm Classic, TBC Anniversary und Classic Era
- Simuliert deinen Charakter automatisch: Schaden pro Sekunde für Schadensklassen, Heilung pro Sekunde für Heiler, effektive Lebenspunkte und verhinderten Schaden für Tanks
- Jeder Item-Tooltip zeigt, ob das Item besser oder schlechter ist als deine angelegte Ausrüstung, in Prozent und als DPS-/HPS-/EHP-Änderung
- Grüner Pfeil nach oben an Verbesserungen und roter Pfeil nach unten an Verschlechterungen in den Taschen (beides abschaltbar)
- Minimap-Button (zum Verschieben ziehen, Linksklick: Fenster, Rechtsklick: Optionen); in Retail auch im Addon-Fach
- Alle Spezialisierungen vergleichen wie bei Pawn: Der Tooltip zeigt pro angehakter Spezialisierung eine eigene Zeile, so siehst du sofort, ob ein Item für Schaden, Heilung oder Tanken besser ist
- Spezialisierungs-Leiste im Fenster: Klick auf eine Spezialisierung zeigt deren Simulation und Item-Wertungen; das Häkchen legt fest, ob sie im Tooltip erscheint
- Goldener Pfeil in den Taschen für Items, die für eine andere angehakte Spezialisierung besser sind
- Optionsfenster: Bewertung im Tooltip, Taschenpfeile und Minimap-Button an oder aus
- Deutsch und Englisch; die Sprache folgt dem Spielclient oder lässt sich in den Optionen bzw. mit `/scales sprache de|en|auto` wählen
- Effekte von Schmuckstücken (Benutzen, Anlegen, Trefferchance) werden passend zu deiner Rolle geschätzt
- Nicht tragbare Rüstung wird markiert; in Retail zählt eine falsche Rüstungsklasse nie als Verbesserung
- Fenster mit `/scales` und Live-Vorschau beim Überfahren von Items
- Rechnet nach dem Kampf neu statt währenddessen und stört so nie im Kampf
