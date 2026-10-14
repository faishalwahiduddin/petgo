# Release Signing — id.faishal.petgo

> **Status:** `android/app/build.gradle.kts` is **already wired** — it loads an upload
> keystore from `android/key.properties` when present, and falls back to **debug
> signing** (which Play will NOT accept) when absent.
> **Remaining step:** create the keystore + `key.properties` below — or run
> `tools/gen-upload-keystores.sh` once for all apps.
> **Never commit the keystore or key.properties** (git-ignored in `android/.gitignore`
> and `store/signing/.gitignore`).

## 1. Create an upload keystore
```bash
keytool -genkey -v -keystore ~/keystores/petgo-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias petgo
```

## 2. `android/key.properties` (git-ignored)
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=petgo
storeFile=/Users/rumah/keystores/petgo-upload.jks
```

## 3. Build & verify
```bash
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab
# confirm it is signed with YOUR key (not the debug key "Android Debug"):
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | head -5
```
Prefer **Play App Signing** (Google manages the app signing key; your keystore is the upload key).
