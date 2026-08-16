#!/usr/bin/env bash
set -euo pipefail

# Pigeon is run from a global activation rather than a dev dependency: it pins an older `analyzer`
# than build_runner does, and the two cannot share a lockfile. Nothing it emits needs the package
# at runtime, so the constraint only matters here.
cd "$(dirname "$0")/.."

VERSION=26.3.3

dart pub global activate pigeon "$VERSION" >/dev/null

dart pub global run pigeon --input pigeons/wallet.dart
