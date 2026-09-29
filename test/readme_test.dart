@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final readme = File('README.md').readAsStringSync();
  final body = readme.replaceAll(RegExp(r'```[\s\S]*?```'), '');

  String slug(String heading) => heading
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9 -]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  final headings = RegExp(
    r'^##+ (.+)$',
    multiLine: true,
  ).allMatches(body).map((m) => slug(m.group(1)!)).toSet();
  final toc = RegExp(
    r'^\s*- \[[^\]]+\]\(#([^)]+)\)',
    multiLine: true,
  ).allMatches(body).map((m) => m.group(1)!).toSet();

  test('the table of contents and the headings agree', () {
    expect(toc.difference(headings), isEmpty, reason: 'dead TOC entries');
    expect(
      headings.difference(toc).difference({'table-of-contents'}),
      isEmpty,
      reason: 'headings missing from the TOC',
    );
  });

  test('every Dart block compiles: it appears in readme_snippets.dart', () {
    final snippets = File('test/readme_snippets.dart').readAsStringSync();
    final blocks = RegExp(r'```dart\n([\s\S]*?)```')
        .allMatches(readme)
        .map((m) => m.group(1)!)
        .where((b) => !b.startsWith('// 3.x'));
    expect(blocks, isNotEmpty);
    for (final block in blocks) {
      expect(snippets.contains(block.trimRight()), isTrue, reason: block);
    }
  });

  test('every relative link points at a file in the repo', () {
    final targets = RegExp(r'\]\(([^)#\s]+)\)')
        .allMatches(body)
        .map((m) => m.group(1)!)
        .where((t) => !t.contains('://') && !t.startsWith('mailto:'));
    for (final target in targets) {
      expect(File(target).existsSync(), isTrue, reason: target);
    }
  });

  test('no em-dashes, and the claim row counts are true', () {
    expect(readme.contains('\u2014'), isFalse);
    final tests = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .map(
          (f) => RegExp(
            r'^\s*(test|testWidgets)\(',
            multiLine: true,
          ).allMatches(f.readAsStringSync()).length,
        )
        .reduce((a, b) => a + b);
    // matrix_test.dart declares one testWidgets and runs it for 64 combinations.
    const matrixCases = 64;
    expect(readme, contains('<b>${tests - 1 + matrixCases} tests</b>'));
    expect(readme, contains('<b>10 effects</b>'));
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final deps = RegExp(
      r'^dependencies:\n((?:  .*\n)+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1)!;
    expect(
      RegExp(
        r'^  (\w+):',
        multiLine: true,
      ).allMatches(deps).map((m) => m.group(1)).toList(),
      ['flutter'],
      reason: 'the README claims 0 third-party dependencies',
    );
    expect(readme, contains('<b>0 third-party dependencies</b>'));
  });
}
