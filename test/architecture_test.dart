@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/ imports no Material or Cupertino', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File && file.path.endsWith('.dart'))
          for (final line in file.readAsLinesSync())
            if (RegExp(
              r'''^import 'package:flutter/(material|cupertino)\.dart''',
            ).hasMatch(line))
              '${file.path}: $line',
    ];
    expect(offenders, isEmpty);
  });
}
