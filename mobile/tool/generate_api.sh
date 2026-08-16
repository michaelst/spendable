#!/usr/bin/env bash
#
# Regenerates the Dart client from the committed OpenAPI spec. Run after any API change:
#
#   mix openapi && mobile/tool/generate_api.sh
#
# The output is committed so API changes are reviewable as a diff and normal CI needs no Java.
set -euo pipefail

VERSION=v7.16.0
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# The generator only replaces files it emits, so a stale model would survive a rename.
rm -rf "$ROOT/mobile/api"

docker run --rm --user "$(id -u):$(id -g)" -v "$ROOT:/local" \
  "openapitools/openapi-generator-cli:$VERSION" generate \
  --input-spec /local/priv/static/openapi.json \
  --generator-name dart-dio \
  --output /local/mobile/api \
  --additional-properties=pubName=spendable_api,pubLibrary=spendable_api

cd "$ROOT/mobile/api"
rm -rf .openapi-generator test doc .travis.yml analysis_options.yaml
flutter pub get
dart run build_runner build

# Neither is part of the client: the app's own lockfile is what governs resolution.
rm -rf .dart_tool pubspec.lock
