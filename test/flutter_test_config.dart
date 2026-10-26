import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file.
///
/// Loads Roboto and Material Icons from the Flutter SDK so golden images show
/// real text (the default test font draws every glyph as a box), and lets
/// goldens differ by a few pixels between this container and GitHub's runners.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadSdkFonts();
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      Uri.parse('${comparator.basedir}flutter_test_config.dart'),
    );
  }
  await testMain();
}

Future<void> _loadSdkFonts() async {
  final fontsDir = Directory(
    '${_flutterRoot()}/bin/cache/artifacts/material_fonts',
  );
  if (!fontsDir.existsSync()) {
    throw StateError('Flutter SDK fonts not found at ${fontsDir.path}');
  }
  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fontsDir.path}/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final style in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(read('Roboto-$style.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

String _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // flutter_tester lives in <root>/bin/cache/artifacts/engine/<platform>/.
  return File(Platform.resolvedExecutable)
      .parent
      .parent
      .parent
      .parent
      .parent
      .parent
      .path;
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  /// Fraction of pixels allowed to differ (font anti-aliasing noise).
  static const _maxDiff = 0.005;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _maxDiff) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
