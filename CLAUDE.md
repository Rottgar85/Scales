# Scales

WoW-Addon (Lua 5.1), das den Charakter analytisch simuliert (DPS/HPS/EHP) und wie Pawn Upgrades an Items anzeigt. Unterstützt Retail (12.x Midnight), WoW: Forever (`WOW_PROJECT_CAMELOT`, nutzt die Classic-Regeln), Mists Classic, Cata Classic, TBC/Anniversary und Classic Era – je eine `.toc` pro Version, `Scales.toc` als Fallback mit allen Interface-Nummern.

In Midnight und Forever können Werte im Kampf „Secret Values“ sein: Charakterwerte nur über `C.Num()` lesen, neu simuliert wird erst nach dem Kampf (`Core/Init.lua`).

Dieser Ordner ist gleichzeitig der installierte Addon-Ordner (`_retail_\Interface\AddOns\Scales`): Änderungen sind nach `/reload` sofort im Spiel.

## Aufbau

- `Locales/` – `enUS.lua` legt `ns.L` an (mit Fallback auf den Key), `deDE.lua` überschreibt. Wird zuerst geladen.
- `Core/Compat.lua` – `ns.C`: alle Versionsunterschiede der API. Neue versionsabhängige Aufrufe gehören hierher.
- `Data/` – Stat-Gewichte pro Archetyp und Spec-Zuordnung (`StatWeights.lua`), Rüstungsklassen (`ArmorTypes.lua`).
- `Core/Specs.lua` – alle Specs der Klasse mit Name/Symbol/Gewichten (`ns.Specs.List()`), welche Specs im Tooltip verglichen werden (`ScalesCharDB.tooltipSpecs`). Vergleichsfunktionen in `Compare.lua` nehmen optional `weights`; ohne Angabe gilt die aktive Spec. Caches sind pro Gewichtstabelle.
- `Core/Stats.lua` (Item- und Charakterwerte), `Core/Simulator.lua` (Modell), `Core/Compare.lua` (Item-Bewertung, Schmuckstücke), `Core/Init.lua` (Events, SavedVariables, Slash-Befehle – wird zuletzt geladen).
- `UI/Style.lua` – gemeinsames Aussehen im Stil von GoldKompass (dunkles Panel, 2-px-Rand in Cyan, Kopfleiste mit Logo und Goldlinie, eigene Buttons/Checkboxen). Neue Fenster immer darüber bauen.
- `UI/` – Tooltip (TooltipDataProcessor + Setter-Hooks wie Pawn, für Classic), Taschen-Pfeile (Blizzard + Painter je Taschen-Addon in `BagOverlay.lua`: EllesmereUI, Bagnon/BagBrother, ElvUI, Baganator, AdiBags, BetterBags; `/scales debug` zeigt den Stand), Hauptfenster `/scales`, Optionen, Minimap-Button + Retail-Addon-Fach.
- `Media/` – `Logo.tga` (256×256) und Taschenpfeile (64×64), erzeugt mit den PowerShell-Skripten in `tools/` (32-bit-TGA, unkomprimiert). `docs/logo.png` ist das Bild für CurseForge.

Neue Dateien in **allen** `.toc`-Dateien eintragen, in derselben Reihenfolge.

## Agenten

- `wow-addon-dev` – Funktionen bauen und Fehler beheben.
- `scales-reviewer` – nach Änderungen auf Syntax, nil-Fehler, Taint und Versionsprobleme prüfen (es gibt lokal kein Lua; luacheck läuft nur in GitHub Actions).
- `wow-api-checker` – API/Events/Interface-Nummern gegen warcraft.wiki.gg und wow-ui-source prüfen.
- `scales-release` – Version und CHANGELOG für ein CurseForge-Release vorbereiten.

## Veröffentlichen

Wie GoldKompass: Tag `vX.Y.Z` pushen → GitHub Actions + BigWigs-Packager → CurseForge. Siehe `VEROEFFENTLICHEN.md`. Version steht fest in allen `.toc` (`## Version:`), CHANGELOG zweisprachig (English, dann Deutsch).
