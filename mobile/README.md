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
dart format --set-exit-if-changed --line-length 110 lib test
flutter analyze
flutter test
```

## Setup this repo cannot do for you

Both are external to the codebase and sign-in fails on device without them.

- **Sign in with Apple** needs the capability enabled on `fiftysevenmedia.Spendable` in the Apple
  Developer portal. `ios/Runner/Runner.entitlements` already declares it.
- **Google Sign-In** needs an iOS OAuth client in Google Cloud Console. Pass its id as
  `--dart-define=GOOGLE_IOS_CLIENT_ID=...`, add the same value to the server's
  `GOOGLE_IOS_CLIENT_ID` env var so the audience check accepts it, and add its reversed form to
  `ios/Runner/Info.plist` as a `CFBundleURLTypes` scheme - the OAuth callback has nowhere to land
  otherwise.
