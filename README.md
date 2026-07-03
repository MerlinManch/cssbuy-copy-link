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


## Passkeys / Anmeldung
Passkey-Popups funktionieren in eingebetteten `WKWebView`s oft nicht zuverlässig.
Nutze im Overlay den Button "Login/Safari", um ChatGPT in `SFSafariViewController`
zu öffnen und dich dort mit Passkey anzumelden.
