# Play Data Safety — PetGo

Answers for Play Console → App content → Data safety. This app is **local-only** (no backend).

## Data collection & sharing
- **Does your app collect or share any of the required user data types?** → **No.**
  - All user data stays on-device (SharedPreferences / bundled JSON). "Collection" in Play's
    definition means data leaving the device; nothing leaves the device.
- **Is all user data encrypted in transit?** → N/A (no data transmitted).
- **Do you provide a way for users to request data deletion?** → Data is local; uninstalling the app removes it. No server data to delete.

## Security practices
- Data is not transferred off the device.
- No third-party SDKs that collect data.
- No ads SDK.

## Result
Data safety section shows: **No data collected · No data shared.**
