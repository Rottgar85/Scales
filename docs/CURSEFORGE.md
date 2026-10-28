# CurseForge – Texte zum Einfügen

Alles hier wird beim Anlegen des Projekts auf curseforge.com (Create Project → World of Warcraft → Addon) eingefügt.
Diese Datei landet nicht in der ZIP.

## Formularfelder

| Feld | Wert |
|---|---|
| Project Name | `Scales` |
| Summary (max. 255 Zeichen) | `Simulates your character (DPS / HPS / tank mitigation) and marks every item like Pawn: green arrow up for upgrades, red arrow down for downgrades – for all your specs. English and German.` |
| Main Category | Bags & Inventory |
| Additional Categories | Tooltip, Class, Combat |
| Game Versions | Retail 12.0, WoW Forever, Mists of Pandaria Classic, Cataclysm Classic, Burning Crusade Anniversary, Classic Era |
| License | All Rights Reserved (wie GoldKompass) oder MIT, wenn andere den Code nutzen dürfen sollen |
| Project Logo | `docs/logo.png` (256×256, CurseForge skaliert selbst) |
| Source / Issues (optional) | `https://github.com/Rottgar85/Scales` und `.../issues`, sobald das Repo existiert |

Die Kategorien heißen auf CurseForge manchmal leicht anders – nimm die nächstpassende.

## Beschreibung (Description, Markdown)

Den Block unten komplett kopieren:

---

![Scales](https://raw.githubusercontent.com/Rottgar85/Scales/main/docs/logo.png)

**English** · [Deutsch weiter unten](#deutsch)

## Know at a glance whether an item is better

Scales simulates your character and shows on every item whether it is an upgrade – just like Pawn, but with a real character model behind it:

- **Damage dealers:** damage per second
- **Healers:** healing per second
- **Tanks:** effective health and damage mitigation

Everything updates automatically when your gear, stats, spec or level change. No button to press, no export, no website.

### Item ratings
- Every tooltip shows **Upgrade / Downgrade** in percent and the change in DPS, HPS or effective health
- **Arrows in your bags:** green up = upgrade, red down = downgrade, gold up = upgrade for another of your specs
- Works with the Blizzard bags, ElvUI, Bagnon, Baganator, AdiBags, BetterBags and EllesmereUI Bags
- Rings, trinkets and dual wield are compared against your weaker item; two-handers against main hand plus off hand
- Trinket effects are estimated for your role
- Armor you cannot wear is marked

### All specs at once
Like Pawn, the tooltip shows one line per specialization – you see immediately whether that new item is better for damage, healing or tanking. In the character window you can click every spec to see its values and choose which specs appear in tooltips.

### Character window `/scales`
Your simulated DPS / HPS / mitigation, your key stats and a rating for every equipped item, plus a live preview when you hover an item.

### Works everywhere
Retail (Midnight) · WoW: Forever · Mists of Pandaria Classic · Cataclysm Classic · TBC Anniversary · Classic Era

English and German (switch with `/scales language en|de|auto`). Minimap button and, in Retail, the addon compartment.

### Commands
`/scales` window · `/scales options` options · `/scales spec 1-4` set spec · `/scales reset` automatic spec · `/scales arrows` bag arrows · `/scales minimap` minimap button

### Good to know
Scales uses a fast analytical model, not a full rotation simulation like SimulationCraft or Raidbots. It is built for quick gear decisions while playing.

---

<a name="deutsch"></a>
**Deutsch**

## Auf einen Blick sehen, ob ein Item besser ist

Scales simuliert deinen Charakter und zeigt an jedem Item, ob es eine Verbesserung ist – wie Pawn, aber mit einem echten Charaktermodell dahinter:

- **Schadensklassen:** Schaden pro Sekunde
- **Heiler:** Heilung pro Sekunde
- **Tanks:** effektive Lebenspunkte und verhinderter Schaden

Alles aktualisiert sich automatisch, wenn sich Ausrüstung, Werte, Spezialisierung oder Stufe ändern. Kein Knopfdruck, kein Export, keine Webseite.

### Item-Bewertung
- Jeder Tooltip zeigt **Verbesserung / Verschlechterung** in Prozent und die Änderung bei DPS, HPS oder effektiven Lebenspunkten
- **Pfeile in den Taschen:** grün nach oben = Verbesserung, rot nach unten = Verschlechterung, gold nach oben = Verbesserung für eine andere deiner Spezialisierungen
- Funktioniert mit den Blizzard-Taschen, ElvUI, Bagnon, Baganator, AdiBags, BetterBags und EllesmereUI Bags
- Ringe, Schmuckstücke und zwei Einhandwaffen werden mit dem schwächeren Item verglichen, Zweihandwaffen mit Haupt- plus Nebenhand
- Schmuckstück-Effekte werden passend zur Rolle geschätzt
- Nicht tragbare Rüstung wird markiert

### Alle Spezialisierungen auf einmal
Wie bei Pawn zeigt der Tooltip eine Zeile pro Spezialisierung – du siehst sofort, ob das neue Item für Schaden, Heilung oder Tanken besser ist. Im Charakterfenster kannst du jede Spezialisierung anklicken und festlegen, welche im Tooltip erscheinen.

### Charakterfenster `/scales`
Dein simulierter DPS-, HPS- oder Mitigationswert, die wichtigsten Werte und eine Wertung für jedes angelegte Item, dazu eine Live-Vorschau beim Überfahren eines Items.

### Läuft überall
Retail (Midnight) · WoW: Forever · Mists of Pandaria Classic · Cataclysm Classic · TBC Anniversary · Classic Era

Deutsch und Englisch (umschalten mit `/scales sprache de|en|auto`). Minimap-Button und in Retail das Addon-Fach.

### Befehle
`/scales` Fenster · `/scales options` Optionen · `/scales spec 1-4` Spezialisierung setzen · `/scales reset` Spezialisierung automatisch · `/scales arrows` Taschenpfeile · `/scales minimap` Minimap-Button

### Gut zu wissen
Scales nutzt ein schnelles analytisches Modell, keine vollständige Rotations-Simulation wie SimulationCraft oder Raidbots. Es ist für schnelle Ausrüstungs-Entscheidungen beim Spielen gemacht.

---

## Screenshots

Fertig zugeschnitten in `docs/screenshots/` (nur Item-Kopf und Scales-Teil, ohne andere Addons und ohne
Charaktername). Auf curseforge.com → Projekt 1770935 → **Images** → „Upload Image“, jeweils mit Titel und
Beschreibung:

| Datei | Title | Description |
|---|---|---|
| `01-tooltip-upgrade.png` | Upgrade in the tooltip / Verbesserung im Tooltip | Green arrow, +% versus your equipped item and the DPS change – plus one line for each of your other specs. · Grüner Pfeil, Prozent ggü. angelegt und DPS-Änderung – dazu eine Zeile pro weiterer Spezialisierung. |
| `02-tooltip-downgrade.png` | Downgrade at a glance / Verschlechterung auf einen Blick | Red arrow when an item is worse for your active spec and for the other specs. · Roter Pfeil, wenn ein Item für die aktive und die anderen Spezialisierungen schlechter ist. |
| `03-window.png` | Character window / Charakterfenster | Simulated DPS, HPS or mitigation, key stats and a rating for every equipped item. Click a spec to see its values. · Simulierte DPS/HPS/Mitigation, wichtigste Werte und eine Wertung pro Item. Klick auf eine Spezialisierung zeigt deren Werte. |
| `04-window-options.png` | Options / Optionen | Tooltip rating, green/red/gold bag arrows, minimap button and language (Auto / English / Deutsch). · Bewertung im Tooltip, grüne/rote/goldene Taschenpfeile, Minimap-Button und Sprache. |

Als „Featured“ (Vorschaubild der Projektseite) eignet sich `01-tooltip-upgrade.png`.

Ein Bild mit Pfeilen in den Taschen fehlt noch: ab Version 0.1.1 erscheinen sie auch in EllesmereUI Bags.
