#!/bin/bash
# Installs the Flutter version pinned in pubspec.yaml and fetches packages,
# so `flutter analyze` and `flutter test` work in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

FLUTTER_HOME="$HOME/.flutter-sdk"
VERSION=$(sed -n 's/^  flutter: *\([0-9][0-9.]*\).*/\1/p' pubspec.yaml | head -n 1)
if [ -z "$VERSION" ]; then
  echo "session-start: no pinned flutter version in pubspec.yaml" >&2
  exit 1
fi

installed_version() {
  grep -o '"frameworkVersion": *"[^"]*"' "$FLUTTER_HOME/bin/cache/flutter.version.json" 2>/dev/null \
    | sed 's/.*"\([^"]*\)"$/\1/' || true
}

if [ "$(installed_version)" != "$VERSION" ]; then
  echo "session-start: installing Flutter $VERSION" >&2
  BASE=https://storage.googleapis.com/flutter_infra_release/releases
  INFO=$(curl -sSfL "$BASE/releases_linux.json" | python3 -c "
import json, sys
d = json.load(sys.stdin)
r = [x for x in d['releases'] if x['version'] == '$VERSION' and x['channel'] == 'stable'][0]
print(r['archive'], r['sha256'])")
  read -r ARCHIVE SHA <<< "$INFO"
  TMP=$(mktemp -d)
  curl -sSfL -o "$TMP/flutter.tar.xz" "$BASE/$ARCHIVE"
  echo "$SHA  $TMP/flutter.tar.xz" | sha256sum -c - >&2
  rm -rf "$FLUTTER_HOME"
  mkdir -p "$FLUTTER_HOME"
  tar -xJf "$TMP/flutter.tar.xz" -C "$FLUTTER_HOME" --strip-components=1
  rm -rf "$TMP"
fi

git config --global --get-all safe.directory | grep -qx "$FLUTTER_HOME" \
  || git config --global --add safe.directory "$FLUTTER_HOME"
export PATH="$FLUTTER_HOME/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

flutter config --no-analytics --no-cli-animations >/dev/null 2>&1
flutter pub get >&2
