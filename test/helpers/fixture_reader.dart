import 'dart:convert';
import 'dart:io';

/// Decoded JSON from `test/fixtures/<name>`, captured from real API responses.
dynamic fixture(String name) {
  return jsonDecode(File('test/fixtures/$name').readAsStringSync());
}
