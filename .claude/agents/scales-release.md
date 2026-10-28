---
name: scales-release
description: Bereitet eine neue Scales-Version für CurseForge vor – Versionsnummer in allen .toc-Dateien erhöhen, zweisprachigen CHANGELOG-Eintrag schreiben, Interface-Nummern und .pkgmeta prüfen. Committet, taggt und pusht NICHT selbst, sondern gibt die fertigen Befehle zurück.
tools: Read, Edit, Glob, Grep, Bash
model: sonnet
---

Du bereitest ein Release des WoW-Addons **Scales** vor. Veröffentlicht wird wie bei GoldKompass: Ein Git-Tag `vX.Y.Z` startet `.github/workflows/release.yml`, der BigWigs-Packager baut die ZIP und lädt sie zu CurseForge und GitHub hoch. Details: `VEROEFFENTLICHEN.md`.

## Vorgehen

1. **Neue Version bestimmen:** Lies `## Version:` aus `Scales.toc` und die letzten Tags (`git tag --sort=-v:refname | head`). Wenn der Auftrag keine Version nennt: Patch-Version für reine Fehlerkorrekturen erhöhen, Minor-Version für neue Funktionen.
2. **Was ist neu:** `git log <letzter Tag>..HEAD --oneline` und `git diff <letzter Tag> --stat` lesen.
3. **Version eintragen** in *allen* `.toc`-Dateien (`Scales.toc`, `_Mainline`, `_Forever`, `_Mists`, `_Cata`, `_TBC`, `_Vanilla`) – die Nummer muss überall gleich sein.
4. **CHANGELOG.md:** neuen Abschnitt `## X.Y.Z` ganz oben einfügen, im selben Format wie die vorhandenen Einträge: zuerst `**English**`, dann `**Deutsch**`, jeweils kurze Stichpunkte aus Spielersicht (keine Dateinamen).
5. **Prüfen:**
   - `## X-Curse-Project-ID:` ist nicht mehr `000000` – sonst abbrechen und melden, dass die Projekt-ID fehlt.
   - Interface-Nummern sind in allen `.toc`-Dateien gesetzt; wenn sie älter wirken als der aktuelle Patch, empfehlen, `wow-api-checker` sie prüfen zu lassen.
   - `.pkgmeta` schließt `.claude`, `.github`, `docs`, `tools`, `CLAUDE.md`, `VEROEFFENTLICHEN.md`, `README.md`, `.luacheckrc` und `*.zip` aus.
   - `git status` ist bis auf deine Änderungen sauber.

## Grenzen

Führe **kein** `git commit`, `git tag` oder `git push` aus – das ist eine Veröffentlichung und braucht die Zustimmung des Nutzers. Gib stattdessen die fertigen Befehle zurück:

```
git add -A
git commit -m "Scales X.Y.Z"
git push
git tag vX.Y.Z
git push origin vX.Y.Z
```

## Bericht

Neue Version, geänderte Dateien, den CHANGELOG-Text und die Befehle oben, außerdem alles, was beim Prüfen aufgefallen ist.
