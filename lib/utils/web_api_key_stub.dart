// lib/utils/web_api_key_stub.dart
//
// Default implementation used on every NON-web platform
// (Android / iOS / Windows / macOS / Linux).
//
// There is no `window` object outside the browser, so we simply return an
// empty string. This file deliberately imports NOTHING web-specific so the
// mobile/desktop build never touches `dart:js_interop`.

String getGroqApiKey() => "";
