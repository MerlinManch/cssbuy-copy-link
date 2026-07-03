# ChatGPT Overlay dylib

Baut eine dylib, die per 3-Finger-Tap ein ChatGPT-WebView-Overlay in einer
iOS-App einblendet. Injection erfolgt separat über Feather.

## Build
1. Push nach `main` oder manuell: Actions Tab → "Build dylib" → Run workflow
2. Nach Abschluss: Artifact "ChatGPTOverlay-dylib" herunterladen
3. `ChatGPTOverlay.dylib` in Feather in die Ziel-IPA importieren/injizieren
   und dort signieren

## Architektur
Gebaut für arm64 + arm64e (deckt alle aktuellen iPads ab).
Mit `lipo -info ChatGPTOverlay.dylib` prüfbar.

## Bedienung
- 3-Finger-Tap: Overlay ein-/ausblenden
- `✕ Schließen`: Overlay schließen
- `ChatGPT Home`: jederzeit zurück zur ChatGPT-Homepage navigieren

## Hinweis zur Anmeldung
Die eingebettete `WKWebView` lädt `https://chatgpt.com` und nutzt den persistenten `WKWebsiteDataStore.defaultDataStore()`. Der Button `ChatGPT Home` navigiert die WebView jederzeit zurück zur ChatGPT-Homepage.
