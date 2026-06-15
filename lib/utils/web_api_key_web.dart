// lib/utils/web_api_key_web.dart
//
// WEB-ONLY implementation. This file is selected by the conditional import in
// `web_api_key.dart` only when `dart.library.js_interop` is available
// (i.e. compiling for the web). It is NEVER part of the Android/iOS build.
//
// It reads `window.groqApiKey`, which is injected in web/index.html.

import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('window.groqApiKey')
external JSString? get _groqApiKey;

String getGroqApiKey() {
  try {
    return _groqApiKey?.toDart ?? "";
  } catch (e) {
    debugPrint("⚠️ Cannot read API key from window.groqApiKey: $e");
    return "";
  }
}
