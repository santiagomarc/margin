# Margin

Study notes and PDF markup for Android tablets: write with your finger, highlight, and cover answers with tape you can tap to reveal.

Built for a Huawei MediaPad T3 (Android 7). See [`docs/PLAN.md`](docs/PLAN.md) for the full plan and build schedule.

## Install on the tablet

1. On the tablet, turn on **Settings → Security → Unknown sources**.
2. In Chrome, sign in to GitHub and open this repo's [Releases](https://github.com/santiagomarc/margin/releases).
3. Download the APK from the newest release and open it to install. Later builds install over the old one and keep your notes.

Never uninstall the app to fix an install error: uninstalling deletes all notebooks.

## Development

Requires Flutter 3.47.8 (pinned in `pubspec.yaml`).

```sh
flutter pub get
flutter analyze
flutter test
dart run build_runner build   # after changing lib/db/
```

Cloud sessions install Flutter automatically through `.claude/hooks/session-start.sh`.

## Builds and signing

GitHub Actions (`.github/workflows/ci.yml`) runs analysis and tests on every pull request and push to `main`, then builds a release APK. Pushes to `main` publish the APK as a GitHub Release.

Release APKs are signed with one permanent key, stored in two repository secrets:

| Secret | Contents |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | The keystore file (`PKCS12`, alias `margin`), base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | Its password (same for store and key) |

Keep a private copy of both. If the key is lost, new APKs can't update the installed app.
