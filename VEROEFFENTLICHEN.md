# Scales veröffentlichen

Wie bei GoldKompass: Statt die ZIP von Hand zu packen, baut GitHub sie automatisch und lädt sie zu CurseForge
(und auf Wunsch zu Wago) hoch. Diese Datei, `CLAUDE.md` und die Ordner `.github` und `.claude` landen nicht in der ZIP.

## Einmalig einrichten

1. **GitHub-Repository** `Rottgar85/Scales` anlegen und diesen Ordner als Inhalt hochladen.
   Die Datei `.pkgmeta` muss direkt im Hauptverzeichnis des Repositorys liegen.
2. **CurseForge-Projekt anlegen** (curseforge.com → Create Project → World of Warcraft → Addon, Name „Scales“).
   Alle Texte zum Einfügen (Kurzbeschreibung, Kategorien, Beschreibung Englisch/Deutsch) stehen in
   `docs/CURSEFORGE.md`, das Logo ist `docs/logo.png`.
   Die Projekt-ID steht danach rechts auf der Projektseite unter „About Project“.
   In **allen** `.toc`-Dateien `## X-Curse-Project-ID: 000000` durch diese ID ersetzen.
   Für Wago zusätzlich: `## X-Wago-ID: abcdef12` (deine Wago-ID)
3. **API-Schlüssel als GitHub-Secrets hinterlegen** (Repository → Settings → Secrets and variables → Actions):
   - `CF_API_KEY`: auf curseforge.com unter Konto → API Tokens erzeugen
   - `WAGO_API_TOKEN`: auf addons.wago.io unter Account → API Keys (nur wenn du Wago nutzt)
   Das GitHub-Token ist automatisch vorhanden.

## Ohne GitHub: ZIP von Hand hochladen

`tools/build-zip.ps1` baut `Scales-<Version>.zip` mit denselben Ausschlüssen wie `.pkgmeta`.
Auf curseforge.com → Projekt → „Upload File“ die ZIP wählen, alle Spielversionen aus der Tabelle unten
angeben, Release-Typ „Release“ und den Abschnitt der Version aus `CHANGELOG.md` als Changelog einfügen.

## Neue Version veröffentlichen

1. In **allen** `.toc`-Dateien die `## Version:` erhöhen und in `CHANGELOG.md` eintragen, was neu ist
   (zuerst English, dann Deutsch). Der Agent `scales-release` erledigt das.
2. Änderungen hochladen (commit und push).
3. Einen Tag mit der Version setzen und hochladen, zum Beispiel:
   `git tag v0.1.0` und dann `git push origin v0.1.0`
4. Unter „Actions“ im Repository siehst du, wie die ZIP gebaut und hochgeladen wird.
   Die fertige ZIP liegt danach auch unter „Releases“.

## Spielversionen

| Version | TOC | Interface |
|---|---|---|
| Retail (Midnight) | `Scales_Mainline.toc` | 120105 |
| WoW: Forever | `Scales_Forever.toc` | 16001 |
| Mists of Pandaria Classic | `Scales_Mists.toc` | 50504 |
| Cataclysm Classic | `Scales_Cata.toc` | 40402 |
| TBC Anniversary | `Scales_TBC.toc` | 20506 |
| Classic Era | `Scales_Vanilla.toc` | 11509 |

`Scales.toc` ist der Rückfall mit allen Nummern. Nach jedem Patch die Nummern prüfen
(im Spiel: `/dump select(4, GetBuildInfo())`, oder den Agenten `wow-api-checker` fragen).
