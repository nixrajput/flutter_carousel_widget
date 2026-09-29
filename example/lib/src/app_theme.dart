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

  /// The panes never grow wider than this together, even on an ultrawide.
  static const double maxWideWidth = 1440;

  /// From this width the options get a panel beside the preview.
  static const double twoPane = 840;

  /// From this width a short screen puts the panel beside the preview too:
  /// the panel and a usable preview fit side by side.
  static const double shortTwoPane = 560;

  /// Below this height of the page's body, a stacked preview takes half.
  static const double smallBody = 600;

  /// Below this height, a landscape phone, a pinned preview over the options
  /// would leave them no room.
  static const double shortHeight = 480;

  /// Room at a list's trailing edge for its scrollbar, so no card sits
  /// under it.
  static const double scrollbarGutter = 16;

  /// The options panel's width range beside the preview.
  static const double panelMin = 320;
  static const double panelMax = 400;
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
