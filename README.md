# Clobotics intern nyhedsbrev

Dette er en enkel, redigerbar HTML-nyhedsbrevskabelon til intern projektkommunikation.

## Sådan redigerer du

1. Åbn filen `newsletter/index.html` i en teksteditor.
2. Find de kommenterede sektioner:
   - `<!-- REDIGER HER: ... -->`
   - Skift titel, tekst og links direkte i HTML.
3. Åbn også:
   - `newsletter/page1.html` for KIWI
   - `newsletter/page2.html` for IBIS
   - `newsletter/page3.html` for Upload tool
4. Gem filerne og genindlæs i browseren.

## Hurtige tip

- Skift `h2` for at ændre korttitler.
- Skift `p`-teksten for at ændre beskrivelser.
- Skift `href="pageX.html"` hvis du vil bruge andre sidetitler.

## Share read-only version

- Del kun filerne i `newsletter/public/` til brugere, der skal se nyhedsbrevet.
- Din redigerbare kilde forbliver i `newsletter/` (uden `public/`).
- Hvis du vil gøre det ekstra sikkert, host `newsletter/public/` på en intern webserver eller i SharePoint med visningstilgang.

## Visning

- Åbn `newsletter/index.html` i din browser for at se forsiden.
- Fra forsiden kan du klikke ind på hver underside.

## Enkel redigering via browser

- Åbn `newsletter/editor.html` i din browser for en simpel web-editor.
- Vælg siden, rediger JSON-indholdet og klik `Download` for at gemme en opdateret `content_*.json` fil.
- Erstat den tilsvarende `content_*.json` i `newsletter/` for at opdatere din lokale redigerbare version.
- Hvis du vil opdatere den delte visning, erstat også filen i `newsletter/public/`.

Bemærk: Nogle browsere blokerer `fetch` når du åbner filer direkte (file:///). Hvis indlæsning fejler, brug editoren som vejledning og rediger `content_*.json` direkte i en teksteditor.

## Automatisk synkronisering (nem løsning)

Hvis du vil undgå manuelt at kopiere filerne til `newsletter/public/`, kan du køre et lille PowerShell-watch-script, som kopierer ændringer automatisk:

1. Åbn PowerShell i mappen `newsletter`.
2. Kør:

```powershell
powershell -ExecutionPolicy Bypass -File .\sync_content.ps1
```

Scriptet laver en initial sync og holder en watcher kørende, så nye eller ændrede `content_*.json` automatisk kopieres til `newsletter/public/`.

Stop scriptet med Ctrl+C.
