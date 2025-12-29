/// Utility functions.
library;

import 'dart:convert';
import 'exceptions.dart';

/// Normalize text by trimming and collapsing whitespace.
String normalizeText(String text) => text.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Normalize URL by trimming.
String normalizeUrl(String url) => url.trim();

/// Normalize date string.
String normalizeDate(String date) => date.trim();

/// Expand proxy alias 'tb' to Tor Browser proxy.
String? expandProxyTbAlias(String? proxy) {
  if (proxy == 'tb') {
    return 'socks5h://127.0.0.1:9150';
  }
  return proxy;
}

/// JSON encode an object.
String jsonEncode(Object? obj) {
  try {
    return const JsonEncoder.withIndent('  ').convert(obj);
  } catch (e) {
    throw DDGSException('JSON encode error: $e');
  }
}

/// JSON decode a string.
dynamic jsonDecode(String str) {
  try {
    return json.decode(str);
  } catch (e) {
    throw DDGSException('JSON decode error: $e');
  }
}

/// Extract vqd value from HTML bytes for DuckDuckGo.
String? extractVqd(String htmlContent, String query) {
  // Try pattern: vqd="..."
  var match = RegExp('vqd="([^"]+)"').firstMatch(htmlContent);
  if (match != null) {
    return match.group(1);
  }

  // Try pattern: vqd=...&
  match = RegExp('vqd=([^&]+)&').firstMatch(htmlContent);
  if (match != null) {
    return match.group(1);
  }

  return null;
}
