// lib/utils/web_api_key.dart
//
// Cross-platform accessor for the Groq API key.
//
// On the web build this delegates to `web_api_key_web.dart`, which uses
// `dart:js_interop` to read `window.groqApiKey` injected in web/index.html.
//
// On every other platform (Android / iOS / Desktop) the conditional import
// resolves to `web_api_key_stub.dart`, which simply returns an empty string.
// This keeps `dart:js_interop` completely out of the mobile/desktop build
// (it is unavailable on the Dart VM and breaks the Android release build).

export 'web_api_key_stub.dart'
    if (dart.library.js_interop) 'web_api_key_web.dart';
