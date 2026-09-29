import 'package:flutter/material.dart';

import 'app_theme.dart';

class DemoSlide extends StatelessWidget {
  const DemoSlide({
    super.key,
    required this.index,
    this.lines = 0,
    this.axis = Axis.horizontal,
  });

  final int index;

  final int lines;

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tints = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.surfaceContainerHighest, scheme.onSurface),
      (scheme.inversePrimary, scheme.onSurface),
    ];
    final (background, foreground) = tints[index % tints.length];
    final text = Theme.of(context).textTheme;
    return Padding(
      // The gap between slides runs along the scroll axis.
      padding: axis == Axis.horizontal
          ? const EdgeInsets.symmetric(horizontal: Gaps.s / 2)
          : const EdgeInsets.symmetric(vertical: Gaps.s / 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Gaps.m),
        ),
        child: Padding(
          // The overlay dots sit on the bottom edge, or the trailing edge when
          // vertical; keep the content clear of their strip.
          padding: axis == Axis.horizontal
              ? const EdgeInsets.fromLTRB(
                  Gaps.m,
                  Gaps.m,
                  Gaps.m,
                  Gaps.l + Gaps.s,
                )
              : const EdgeInsetsDirectional.fromSTEB(
                  Gaps.m,
                  Gaps.m,
                  Gaps.l + Gaps.s,
                  Gaps.m,
                ),
          child: Column(
            mainAxisSize: lines == 0 ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${index + 1}',
                style: text.displaySmall?.copyWith(color: foreground),
              ),
              for (var i = 0; i < lines; i++)
                Text(
                  'Line ${i + 1} of slide ${index + 1}',
                  style: text.bodyMedium?.copyWith(color: foreground),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
