# AgroKaf

Offline mobile app that detects coffee **"muerte descendente" (Phoma)** from a
photo of a leaf, built for coffee farmers in Taminango, Nariño (Colombia).

Undergraduate thesis project — Dirkin Yohan Ojeda Rodríguez, Universidad
Cooperativa de Colombia.

> Esta herramienta es un apoyo y no reemplaza el diagnóstico de un técnico o
> agrónomo.

## Key facts

- **100 % offline.** The release build has no `INTERNET` permission; the AI
  model runs on the phone with LiteRT (TensorFlow Lite).
- **Private by design (Ley 1581 de 2012).** Consent screen before any data is
  collected, encrypted local database (SQLCipher), photos stored privately
  without EXIF/GPS, "delete all my data", no analytics, no cloud backups.
- **Model v2.0.0:** MobileNetV3Large (transfer learning), float16 TFLite,
  3 classes `healthy` / `other` / `phoma`. `other` is a **rejection class**
  (other diseases such as rust and leaf miner, or images that are not coffee
  leaves). Trained in `../training/agrokaf_model.ipynb`.
- **Platforms:** Android 7.0+ (API 24) first; iOS-compatible code base.

## Requirements

| Tool | Version used |
|---|---|
| Flutter | 3.47 (stable), Dart 3.12 |
| Android SDK | 36, NDK 28.2.13676358, CMake 3.22.1 |
| A phone with USB debugging, or an emulator | Android 7.0+ |

## Setup

```bash
flutter pub get
```

### 1. Add the model files

Copy the three files produced by the training notebook (Google Drive
`MyDrive/agrokaf/artifacts/` or `agrokaf_flutter_assets.zip`) into
`assets/model/`:

```
assets/model/
├── labels.txt          # healthy, other, phoma (model output order)
├── model_fp16.tflite   # the classifier
└── model_info.json     # preprocessing contract + test metrics
```

Without them the app still runs and shows "Modelo no disponible".

### 2. Run

```bash
flutter run
```

### 3. Build a release APK

One APK per CPU architecture (much smaller than a universal APK; install
`app-arm64-v8a-release.apk` on modern phones):

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`.

**Signing.** Without `android/key.properties` the release build is signed
with the debug key (fine for installing on your own phone). To sign for real
distribution, create a keystore and `android/key.properties` (both are
git-ignored):

```properties
storePassword=...
keyPassword=...
keyAlias=agrokaf
storeFile=C:/path/to/agrokaf-release.jks
```

### 4. Regenerate icon and native splash (only if the images change)

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

Source images are in `assets/branding/`.

## AI preprocessing contract

Read from `assets/model/model_info.json` and implemented in
`lib/features/analysis/data/image_preprocessor.dart`:

1. Decode the image and apply its EXIF orientation; convert to RGB.
2. Resize the **whole** image to 224×224 with **bilinear** interpolation
   (stretch: no center crop, no letterbox), reproducing TensorFlow's
   `tf.image.resize` (half-pixel centers) used during training.
3. Float32 tensor `[1, 224, 224, 3]` with **raw pixel values 0–255** (no
   division by 255: the model normalizes internally).
4. Output: softmax `[1, N]` in `labels.txt` order (N = 3 for model v2).
   Labels are always matched **by name**, never by position.
5. If the top probability is below **0.70** the result is
   "Resultado no concluyente — toma otra foto".

### Results shown to the user

| Model output (top class, >= 0.70) | Result in the app |
|---|---|
| `healthy` | Hoja sana |
| `phoma` | Posible muerte descendente |
| `other` | No corresponde a muerte descendente (neutral gray; the app does **not** diagnose other diseases) |
| any class below 0.70 | Resultado no concluyente — toma otra foto |

The result screen shows the probability of every class. Analyses saved with
the 2-class v1 model (no `other` probability) still display correctly: the
database migrates from schema 1 to 2 by adding a nullable `other_prob`
column.

**Compatibility.** The app accepts the 2-class (`healthy`, `phoma`) and the
3-class (`healthy`, `other`, `phoma`) models. If `labels.txt` contains a class
name it does not know, it shows **"Modelo incompatible"** instead of
analysing; if the files are missing it shows **"Modelo no disponible"**.

The interpreter is loaded once at startup and inference runs in a background
isolate. A quick photo-quality check (brightness and blur, Laplacian
variance) warns before analysing; thresholds live in
`lib/core/constants/analysis_config.dart`.

## Architecture

Feature-first, Riverpod for state, go_router with a redirect driven by the
persisted app state (onboarding → privacy consent → profile → home).

```
lib/
├── core/            theme (AppTheme, colors, spacing, typography), reusable
│                    widgets, services (DatabaseService, ImageService,
│                    SettingsService, SecureKeyStore, PhotoPickerService),
│                    app state, router, constants
└── features/
    ├── splash/      startup: database + model loading
    ├── onboarding/  3 pages, one shared page widget
    ├── privacy/     consent screen + full privacy policy (Ley 1581)
    ├── profile/     profile setup/edit, validation, photo
    ├── home/        greeting, analyze card, stats, recent, photo tips
    ├── analysis/    ClassifierService (LiteRT), preprocessing, quality
    │                check, preview/crop, result
    ├── history/     list, filters, search, detail, delete
    └── settings/    settings, about (model metrics), delete all data
```

## Data protection summary

| Measure | Where |
|---|---|
| Consent (date + policy version) before collecting data | `features/privacy` |
| SQLCipher database, random 256-bit key in Android Keystore / iOS Keychain | `core/services/database_service.dart`, `secure_key_store.dart` |
| Photos re-encoded without EXIF/GPS, max 1280 px, private folder | `core/services/image_service.dart` |
| Permissions only when used, with explanation and "denied" handling | `core/widgets/photo_source_sheet.dart` |
| Delete all data (DB, photos, keys, caches) | Ajustes → Eliminar todos mis datos |
| `allowBackup="false"`, no `INTERNET` permission in release | `android/app/src/main/AndroidManifest.xml` |

Before publishing, set the privacy contact e-mail in
`lib/core/constants/app_info.dart` (`privacyContactEmail`).

## Tests

```bash
flutter analyze
```

```bash
flutter test
```

Covered: preprocessing contract (TensorFlow bilinear values, RGB, raw 0–255,
stretch), the real `.tflite` running with the Dart preprocessing, threshold
and label mapping (including `other` and incompatible label files), the
schema 1 -> 2 migration with old analyses, the preview -> result flow with
the real model, photo quality, EXIF/GPS removal, database repositories
(real SQLite via FFI), router redirects, profile validation, WCAG contrast of
every color pair, and widget tests of the key screens including Flutter's
accessibility guidelines and 2× text size.

SQLCipher encryption itself requires the native Android/iOS library and is
therefore verified on a device, not in host tests.
