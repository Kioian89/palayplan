# palayplan

Smart agro-weather and rice yield planning application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Authentication

The app supports Firebase Email/Password and Google sign-in. Authentication is
enabled when Firebase options are supplied; without them the existing guest
startup flow remains available.

1. Create a Firebase project, register the Android app (`com.example.palayplan`),
   iOS app (`com.example.palayplan`), and a web app if needed.
2. Enable **Email/Password** and **Google** under Firebase Authentication
   sign-in providers.
3. Copy `firebase.env.example.json` to the ignored `firebase.env.json`, then
   replace its values with each app's Firebase API key/app ID and the project's
   sender ID and project ID. Run with:

   ```bash
   flutter run --dart-define-from-file=firebase.env.json \
     --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```

   Use your backend URL instead of the example emulator URL where appropriate.
4. For Android Google sign-in, download `google-services.json` to
   `android/app/`; the Google Services Gradle plugin is applied when this file
   exists. For iOS, add `GoogleService-Info.plist` to the Runner target and add
   its `REVERSED_CLIENT_ID` as a URL scheme in the iOS Runner target. For web,
   set `GOOGLE_SIGN_IN_WEB_CLIENT_ID` in the local JSON file and authorize the
   app's domain in Google/Firebase settings.
5. On the backend, set `FIREBASE_CREDENTIALS_PATH` in `backend/.env` to a
   Firebase Admin service-account JSON file. Keep that server credential out
   of source control and never put it in the Flutter app.

After configuration, the app opens the sign-in screen until authenticated.
Firebase ID tokens are verified by the backend at `GET /auth/me`.

## Offline use

The field profile and preferences are stored locally on the device. The
Android/iOS disease scanner runs with the bundled TFLite model and does not
need a network connection. Forecasts and advisories refresh from the backend
when online; the most recently fetched results for the active field are cached
locally and shown with their last-updated time when the network is unavailable.
The sign-in screen also offers guest access for local/offline use. A first-time
offline user will not have forecast or advisory data until the app has synced
while connected. Yield prediction and account sign-in still require a network.
Use an HTTPS backend URL for release builds; cleartext HTTP is enabled only in
the Android debug manifest for local development.

## Settings and privacy

Open Settings from the home screen to change the app language, review the
in-app privacy policy, or sign out. Field profile and language preferences,
along with cached forecast and advisory responses, are stored locally. On
Android and iOS, rice-leaf photos are analyzed on-device and are not uploaded
by the scan flow. The privacy policy describes the current app's data flows
and provides guidance for privacy and data-deletion requests.

Farmers can choose a municipality or pin the field's exact position on the map.
The map uses OpenStreetMap tiles. Device location permission is requested only
if the farmer chooses **Use current location**; the app does not track location
in the background. The selected coordinates are stored with the field profile
and sent with forecast and advisory requests.

## Android APK updates

The Settings screen can check the latest published GitHub Release and offer its
APK for download. Publish each Android release with a semantic version tag
(for example, `v0.1.1`) and attach the release APK. The app compares that tag
with its installed version and opens the APK download in the browser; Android
will ask the user to confirm installation. The app does not install updates
silently. iOS updates must be distributed separately through the App Store.

To publish an update, increment `version` in `pubspec.yaml`, build with
`flutter build apk --release`, then attach
`build/app/outputs/flutter-apk/app-release.apk` to a GitHub Release whose tag
matches that version (for example, `v0.1.1`).
