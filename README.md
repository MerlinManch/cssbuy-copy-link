# ChatGPT Overlay Tweak

Injiziert einen 3-Finger-Tap-Trigger in die eigene iOS-App, der ein
ChatGPT-WebView-Overlay einblendet.

## Setup
1. Repo **privat** halten (enthält ggf. sensible App-Struktur).
2. In `Makefile` unter `INSTALL_TARGET_PROCESSES` den echten Binary-Namen
   der Ziel-App eintragen (nicht die Bundle-ID, sondern den Dateinamen
   der Executable im .app-Bundle).
3. Original-IPA als GitHub Release-Asset hochladen und die Download-URL
   notieren.
4. Actions Tab → "Build and Inject dylib" → Run workflow → URL einfügen.
5. Nach Abschluss: Artifact "patched-ipa" herunterladen.
6. IPA in Feather importieren, signieren, installieren.

## Testen
App öffnen → mit 3 Fingern gleichzeitig auf den Screen tippen →
Overlay mit "✕ Schließen"-Button und ChatGPT-WebView sollte erscheinen.

## Troubleshooting
- Crash beim Start → Architektur-Mismatch prüfen (`lipo -info`)
- Gesture reagiert nicht → Delay im %ctor erhöhen oder auf
  `UIApplicationDidBecomeActiveNotification` umstellen
- Zertifikatswarnung → Einstellungen → VPN & Geräteverwaltung → vertrauen
