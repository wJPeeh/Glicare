// Driver do integration_test responsável por gravar em disco as screenshots
// capturadas por integration_test/screenshot_test.dart.
//
// Rodar com:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final dir = Directory('screenshots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes);
      // ignore: avoid_print
      print('Screenshot salva: ${file.path}');
      return true;
    },
  );
}
