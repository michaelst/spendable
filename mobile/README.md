# Spendable for iOS

A Flutter client for the Spendable API. The Dart client under `api/` is generated from
`../priv/static/openapi.json` and committed, so changing an endpoint means regenerating both in
the same PR.

## Running

```sh
mise install                 # provisions the pinned Flutter
flutter pub get
flutter run --dart-define=SPENDABLE_API_URL=http://localhost:4000
```

`SPENDABLE_API_URL` defaults to `https://spendable.money`.

## Regenerating the API client

```sh
mix openapi && mobile/tool/generate_api.sh
```

Needs Docker. CI fails if either the spec or the client has drifted.

## Gates

```sh
dart run build_runner build
dart format --line-length 110 $(find lib test -name '*.dart' ! -name '*.g.dart')
flutter analyze
flutter test
```

Generated `.g.dart` files are committed exactly as build_runner writes them - do not format them,
or every regeneration will show up as a diff.

## Setup this repo cannot do for you

Both are external to the codebase and sign-in fails on device without them.

- **Sign in with Apple** needs the capability enabled on `fiftysevenmedia.Spendable` in the Apple
  Developer portal. `ios/Runner/Runner.entitlements` already declares it.
- **Google Sign-In** works on device from `ios/Runner/Info.plist`, which carries the iOS client id
  and its reversed form as a URL scheme. The **server** needs the same value in its
  `GOOGLE_IOS_CLIENT_ID` env var, or it rejects the app's ID tokens on audience - `scripts/install.sh`
  prompts for it.
