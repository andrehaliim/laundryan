import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver: saves screenshots sent by the integration test to
/// `screenshots/<name>.png`.
Future<void> main() {
  return integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
