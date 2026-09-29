import 'package:flutter/material.dart';

/// The violet from the package logo. Both themes grow from this one seed, so
/// light and dark stay in step.
const _seed = Color(0xFF9B8CFF);

/// The spacing scale every screen uses.
abstract final class Gaps {
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;

  /// A single column never grows wider than this, so it stays readable.
  static const double maxWidth = 720;

  /// Two panes never grow wider than this together.
  static const double maxWideWidth = 1200;

  /// From this width, options and preview sit side by side.
  static const double twoPane = 840;

  /// Below this height the pinned preview uses its compact form.
  static const double tallEnough = 700;

  /// The height the options need to be pinned whole with a usable list below,
  /// at a text scale of 1.
  static const double pinOptions = 560;
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Gaps.m),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Gaps.m),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}
