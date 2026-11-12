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

## Firebase Authentication and field sync

The app supports Firebase Email/Password and Google sign-in. Signed-in field
profiles sync in real time through Cloud Firestore under
`users/{uid}/appData/fieldProfiles`; local SharedPreferences remains the guest
store and an offline cache. Existing locally saved fields are copied to the
first Firebase account that signs in on that device when that account has no
saved Firestore profile. New account data is stored in a per-user local cache.
New installs start with an empty field profile; farmers must enter their field
details before weather, advisory, calendar, or yield features can use them.

1. Create a Firebase project and register the Android app
   (`com.example.palayplan`), iOS app (`com.example.palayplan`), and a web app
   if needed.
2. Enable **Email/Password** and **Google** under Firebase Authentication
   sign-in providers and create the Cloud Firestore database. From the
   repository root, run the setup script. It checks Firebase CLI
   authentication and deploys the included user-scoped security rules:

   ```bash
   .\setup-firebase.ps1 -ProjectId YOUR_FIREBASE_PROJECT_ID
   ```

   The rules are in [`firestore.rules`](../firestore.rules) and allow each
   signed-in user to access only their own field profile document. All other
   Firestore documents are denied by default. The script does not create
   Firebase projects or configure Authentication providers; complete those
   steps in Firebase Console first.

3. Copy `firebase.env.example.json` to the ignored `firebase.env.json`, then
   replace its placeholder values with each app's Firebase API key/app ID and
   the project's sender ID and project ID. Do not commit the populated file.
   Restrict each Firebase API key to the intended app and required APIs. Run
   with:

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
5. If other clients need server-side Firebase token verification, set
   `FIREBASE_CREDENTIALS_PATH` in `backend/.env` to a Firebase Admin
   service-account JSON file. Keep that server credential out of source control
   and never put it in the Flutter app.

After configuration, the app opens the sign-in screen until authenticated.
Firebase Authentication manages account identity directly. The backend
continues to provide weather, advisory, and yield-prediction APIs.

## Offline use

Signed-in field profiles sync through Firestore and are cached locally;
guest field profiles and preferences remain stored locally on the device. The
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
in-app privacy policy, or sign out. Field profiles are stored in Firestore for
signed-in users and locally for guests; language preferences and cached
forecast and advisory responses are stored locally. On
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

The GitHub Actions workflow at `.github/workflows/build-apk.yml` builds APKs
using the PalayPlan Render API by default. To use another deployment, set the
repository's `API_BASE_URL` variable to its base URL.
The workflow runs on
pushes to `main`/`master`, pull requests, and version tags; a manual run is also
available from the Actions tab. Download the APK from the completed workflow
run's **Artifacts** section. Version-tag builds also attach the APK to the
corresponding GitHub Release.
Configure the restricted Android Firebase API key as the repository Actions
secret `FIREBASE_API_KEY_ANDROID`; the workflow passes it to Android builds
without storing it in source. Pull-request builds can run without this secret,
but Firebase-backed sign-in and sync will not be configured in those builds.
