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
- `Login/System`: ChatGPT in einem System-Authentifizierungskontext öffnen

## Passkeys / Anmeldung
Passkeys funktionieren in `WKWebView` nur unter engen Bedingungen. Der wichtigste
Punkt: Eine App kann nicht beliebige fremde Logins wie ChatGPT/OpenAI in ihrer
eigenen WebView passkeyfähig machen. Apple verlangt für WebAuthn/Passkeys eine
Verknüpfung der App mit der Relying-Party-Domain über Associated Domains
(`webcredentials:`) und eine passende `apple-app-site-association`-Datei auf der
Domain.

Für ChatGPT/OpenAI ist das in einer injizierten Dritt-App praktisch keine Lösung:
Die App kann keine Associated Domain für `chatgpt.com` oder OpenAI-Login-Domains
besitzen. Wenn Erweiterte Kontosicherheit im OpenAI-Konto aktiviert ist, sind
Passkeys oder Security Keys zudem Pflicht; Passwort-, E-Mail- und SMS-Login sind
dann deaktiviert.

Darum öffnet der Button `Login/System` den aktuellen ChatGPT-Link mit
`ASWebAuthenticationSession`. Dieser System-Webkontext ist für Auth-Flows mit
Drittanbietern geeigneter als eine eingebettete `WKWebView`; Passkeys stehen dort
wie in Safari zur Verfügung.

Wichtig: iOS stellt die Safari-/`ASWebAuthenticationSession`-Cookies nicht so zur
Verfügung, dass eine injizierte App sie inklusive `HttpOnly`-/Session-Cookies in
eine `WKWebView` kopieren könnte. Die WebView nutzt deshalb den persistenten
`WKWebsiteDataStore.defaultDataStore()` und wird nach der Rückkehr aus dem
System-Login neu geladen. Dadurch bleiben Cookies erhalten, die innerhalb dieser
`WKWebView` gesetzt werden; ein vollständiges Übernehmen der OpenAI-Session aus
dem System-Login in die WebView ist aber von iOS/OpenAI nicht erlaubt.

Für eigene Domains kann `WKWebView` mit Passkeys funktionieren, wenn alle Punkte
zusammenpassen:

1. In Xcode unter `Target → Signing & Capabilities → Associated Domains` eine
   Domain wie `webcredentials:example.com` hinzufügen.
2. Auf `https://example.com/.well-known/apple-app-site-association` eine AASA-Datei
   mit der eigenen Team-ID und Bundle-ID hosten:

   ```json
   {
     "webcredentials": {
       "apps": [
         "TEAMID.com.deinefirma.deineapp"
       ]
     }
   }
   ```

3. Die `WKWebView` muss exakt diese HTTPS-Domain laden; keine lokale Datei, kein
   Custom Scheme und kein anderes Hostname-Mapping.
4. Im Web läuft normales WebAuthn-JavaScript (`navigator.credentials.create` und
   `navigator.credentials.get`), während Challenge, User-ID, RP-ID und
   Verifikation serverseitig korrekt nach WebAuthn/FIDO2 umgesetzt werden.

Faustregel: Eigene Domain plus eigene App kann mit `WKWebView` funktionieren. Für
OpenAI/ChatGPT, Apple, Google, Microsoft oder andere Drittanbieter-Logins sollte
ein System-Webkontext wie `ASWebAuthenticationSession` oder Safari verwendet
werden.
