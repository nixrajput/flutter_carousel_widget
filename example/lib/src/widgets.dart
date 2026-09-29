import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A titled card. Every block on the page is one, so spacing stays uniform.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.flush = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Lets list rows run edge to edge inside the card.
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.m, Gaps.m, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Gaps.s / 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Padding(
            padding: flush
                ? const EdgeInsets.only(top: Gaps.s, bottom: Gaps.s)
                : const EdgeInsets.all(Gaps.m),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Device, light or dark, as three icon segments.
class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<ThemeMode>(
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: const [
      ButtonSegment(
        value: ThemeMode.system,
        icon: Icon(Icons.brightness_auto_outlined),
        tooltip: 'Device theme',
      ),
      ButtonSegment(
        value: ThemeMode.light,
        icon: Icon(Icons.light_mode_outlined),
        tooltip: 'Light theme',
      ),
      ButtonSegment(
        value: ThemeMode.dark,
        icon: Icon(Icons.dark_mode_outlined),
        tooltip: 'Dark theme',
      ),
    ],
    selected: {mode},
    onSelectionChanged: (s) => onChanged(s.single),
  );
}
