# Hisabi — حسابي

A personal expense tracker built with Flutter and Firebase.

---

## Prerequisites

Before running the project, make sure the following tools are installed on your machine.

### Required for both platforms

| Tool | Version | Download |
|---|---|---|
| Flutter SDK | 3.x (stable) | https://docs.flutter.dev/get-started/install |
| Dart SDK | ≥ 3.8.1 (bundled with Flutter) | — |
| Git | Any recent version | https://git-scm.com |

### Required for Android

| Tool | Notes |
|---|---|
| Android Studio | Includes Android SDK, emulator manager |
| Android SDK | API level 23 (Android 6.0) or higher |
| Java 11 | Usually bundled with Android Studio |

### Required for iOS (macOS only)

| Tool | Notes |
|---|---|
| Xcode 15+ | Install from the Mac App Store |
| CocoaPods | `sudo gem install cocoapods` |
| Apple Developer account | Free account works for device testing |

> iOS builds require a **Mac**. You cannot build for iOS on Windows or Linux.

---

## 1. Clone the Repository

```bash
git clone https://github.com/farhan-hasan/hisabi.git
cd hisabi
```

---

## 2. Verify Flutter Setup

Run Flutter's built-in diagnostic tool to confirm your environment is ready:

```bash
flutter doctor
```

All relevant checkmarks should be green before proceeding. Common fixes:

- **Android toolchain** — open Android Studio → SDK Manager → install Android SDK 34+
- **Xcode** (macOS) — run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` then `sudo xcodebuild -runFirstLaunch`
- **CocoaPods** (macOS) — run `sudo gem install cocoapods`

---

## 3. Install Dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`.

---

## 4. Running on Android

### Option A — Android Emulator

1. Open **Android Studio**.
2. Go to **Device Manager** (right sidebar or Tools menu).
3. Click **Create Device** and follow the wizard to create a virtual device running API 23 or higher.
4. Start the emulator.
5. Back in your terminal, confirm the device is listed:

```bash
flutter devices
```

6. Run the app:

```bash
flutter run
```

### Option B — Physical Android Device

1. On your phone, go to **Settings → About Phone** and tap **Build Number** 7 times to enable Developer Options.
2. Go to **Settings → Developer Options** and enable **USB Debugging**.
3. Connect the phone to your computer via USB and authorize the connection when prompted on the device.
4. Confirm the device is detected:

```bash
flutter devices
```

5. Run the app:

```bash
flutter run
```

### Android Requirements

| Requirement | Value |
|---|---|
| Minimum Android version | Android 6.0 (API 23) |
| Target Android version | Android 14 (API 34) |
| Architecture | arm64, arm, x86_64 |

---

## 5. Running on iOS (macOS only)

### Option A — iOS Simulator

1. Open Xcode and go to **Xcode → Open Developer Tool → Simulator**, or run:

```bash
open -a Simulator
```

2. Choose a device running iOS 13.0 or higher from the simulator menu.
3. Install CocoaPods dependencies (first time only):

```bash
cd ios
pod install
cd ..
```

4. Run the app:

```bash
flutter run
```

### Option B — Physical iPhone / iPad

1. Connect your device via USB.
2. Open `ios/Runner.xcworkspace` in Xcode (use `.xcworkspace`, not `.xcodeproj`).
3. In the **Runner** target → **Signing & Capabilities**, select your Apple Developer Team.
4. Trust your developer certificate on the device: **Settings → General → VPN & Device Management → Trust**.
5. Select your physical device in Xcode's device picker, then run from the terminal:

```bash
flutter run
```

Or press the **Run** button (▶) in Xcode directly.

### iOS Requirements

| Requirement | Value |
|---|---|
| Minimum iOS version | iOS 13.0 |
| Swift version | 5.0 |
| Xcode version | 15.0+ |

---

## 6. Targeting a Specific Device

If multiple devices are connected, list them:

```bash
flutter devices
```

Then pass the device ID explicitly:

```bash
flutter run -d <device-id>
```

Example:

```bash
flutter run -d emulator-5554       # Android emulator
flutter run -d iPhone\ 15\ Pro     # iOS simulator
```

---

## 7. Build Modes

| Command | Mode | Use case |
|---|---|---|
| `flutter run` | Debug | Development — hot reload enabled |
| `flutter run --profile` | Profile | Performance testing |
| `flutter run --release` | Release | Production-like build |

Hot reload is available in debug mode. After making code changes, press **r** in the terminal to reload, or **R** for a full restart.

---

## 8. Building a Release APK (Android)

```bash
flutter build apk --release
```

The output file will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

To install it directly on a connected device:

```bash
flutter install
```

---

## 9. Building for iOS (macOS only)

```bash
flutter build ios --release
```

To distribute via TestFlight or the App Store, open the `.xcworkspace` in Xcode and use **Product → Archive**.

---

## 10. Troubleshooting

### `flutter pub get` fails

Make sure your Flutter SDK is on the stable channel and up to date:

```bash
flutter channel stable
flutter upgrade
flutter pub get
```

### Android build fails — Gradle error

Try cleaning the build cache:

```bash
flutter clean
flutter pub get
flutter run
```

### iOS — CocoaPods errors

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

If `pod install` fails with permission errors:

```bash
sudo gem install cocoapods
cd ios && pod install
```

### iOS — "No signing certificate" error

Open `ios/Runner.xcworkspace` in Xcode. Under **Runner → Signing & Capabilities**, select your Apple ID as the Team. Xcode will auto-create a provisioning profile.

### Device not detected

- Android: ensure USB debugging is enabled and the cable supports data transfer (not charge-only).
- iOS: make sure you tapped **Trust** on the device when the prompt appeared.
- Run `flutter doctor` again to see specific issues.

### Firebase / Google Sign-In not working

The Firebase config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) are already included in the repository. No additional Firebase setup is needed to run the app.

If you see auth errors, make sure your device has a working internet connection and that the Google Play Services are up to date (Android).

---

## Project Info

| Field | Value |
|---|---|
| Package name | `com.farhanhasan.hisabi` |
| Version | 1.0.0+1 |
| State management | Riverpod |
| Navigation | GoRouter |
| Backend | Firebase (Auth + Firestore) |
