# Android release preparation

## Build
1. Install Godot 4.5.1 with matching export templates, OpenJDK 17 and Android SDK. Follow https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html
2. Install Android platform 36 and supported build tools; set Java SDK and Android SDK paths in Godot Editor Settings.
3. Open `game/project.godot`, install Android Gradle build template via Project > Install Android Build Template. The Android preset enables Gradle AAB export, ARM64, API 36, minimum API 26 and disables internet permission.
4. Confirm package ID `com.tezcatt.coffeeshop` is the intended permanent ID. Create and privately back up an upload keystore; configure release signing locally. Never commit keystores/passwords.
5. Create `game/build/`, export Android with debug unchecked to `build/tezcatt-coffee.aab`. No release signing credentials are supplied in this repository.

## Required release evidence
- Verify target API against current Play Console requirements: https://support.google.com/googleplay/android-developer/answer/11926878
- Validate 16 KB page-size compatibility of the exported native libraries and run on a 16 KB Android environment: https://developer.android.com/guide/practices/page-sizes
- Test actual ARM64 Android phones: touch/keyboard numeric entry, landscape/notch safe areas, interruption, resume, corrupted saves, sold-out days, long sessions and low-memory conditions. Measure frame rate, memory and heat. Current HUD needs this screen-size review before release.
- Produce final icon, feature graphic, genuine device screenshots, store description and support contact. Complete content rating, ads declaration, target audience, privacy policy and Data Safety from the actual release. This implementation contains no analytics, ads, billing, network or account system.
- Run internal testing and any account-specific closed testing required by Play Console. Upload to production only after those gates pass and owner authorizes publication.

## Source attribution gate
The original Python file states “Copyright 2022 Clydebank Media, All Rights Reserved.” Repository ownership alone does not establish commercial rights to that material. Verify the original learning-source license or permission before distributing an adaptation. The new procedural meshes use no third-party asset downloads. Godot engine license/notices must accompany exported releases per https://godotengine.org/license/.

## Current status
Headless logic and scene tests pass. No signed AAB, Android device run, rendered visual approval or Play submission has been completed. Android SDK and release signing are not available in this workspace. The generated characters are stylized geometric models with procedural walk animation, not rigged imported character assets.
