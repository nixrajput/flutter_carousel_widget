import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'app_theme.dart';

enum Effect {
  none,
  enlarge,
  fade,
  parallax,
  depth,
  zoomOut,
  stack,
  coverflow,
  cube,
  flip,
  rotate,
}

enum Painter { slide, still, wave, fill }

@immutable
class PlaygroundOptions {
  const PlaygroundOptions({
    this.expandable = false,
    this.effect = Effect.enlarge,
    this.strength = 1,
    this.viewportFraction = 0.8,
    this.infinite = true,
    this.padEnds = true,
    this.reverse = false,
    this.vertical = false,
    this.rtl = false,
    this.autoPlay = true,
    this.variedIntervals = false,
    this.painter = Painter.slide,
    this.below = false,
    this.flush = false,
    this.softSpring = false,
  });

  final bool expandable;
  final Effect effect;
  final double strength;
  final double viewportFraction;
  final bool infinite;
  final bool padEnds;
  final bool reverse;
  final bool vertical;
  final bool rtl;
  final bool autoPlay;
  final bool variedIntervals;
  final Painter painter;
  final bool below;
  final bool flush;
  final bool softSpring;

  PlaygroundOptions copyWith({
    bool? expandable,
    Effect? effect,
    double? strength,
    double? viewportFraction,
    bool? infinite,
    bool? padEnds,
    bool? reverse,
    bool? vertical,
    bool? rtl,
    bool? autoPlay,
    bool? variedIntervals,
    Painter? painter,
    bool? below,
    bool? flush,
    bool? softSpring,
  }) => PlaygroundOptions(
    expandable: expandable ?? this.expandable,
    effect: effect ?? this.effect,
    strength: strength ?? this.strength,
    viewportFraction: viewportFraction ?? this.viewportFraction,
    infinite: infinite ?? this.infinite,
    padEnds: padEnds ?? this.padEnds,
    reverse: reverse ?? this.reverse,
    vertical: vertical ?? this.vertical,
    rtl: rtl ?? this.rtl,
    autoPlay: autoPlay ?? this.autoPlay,
    variedIntervals: variedIntervals ?? this.variedIntervals,
    painter: painter ?? this.painter,
    below: below ?? this.below,
    flush: flush ?? this.flush,
    softSpring: softSpring ?? this.softSpring,
  );

  /// [k] runs from 0.5 to 1.5; 1 gives each preset's defaults (Task 9).
  static CarouselEffect effectFor(Effect effect, [double k = 1]) =>
      switch (effect) {
        Effect.none => CarouselEffect.none,
        Effect.enlarge => CarouselEffect.enlarge(factor: 0.25 * k),
        Effect.fade => CarouselEffect.fade(
          minOpacity: (1 - 0.7 * k).clamp(0.0, 1.0),
        ),
        Effect.parallax => CarouselEffect.parallax(depth: 0.3 * k),
        Effect.depth => CarouselEffect.depth(minScale: 1 - 0.25 * k),
        Effect.zoomOut => CarouselEffect.zoomOut(minScale: 1 - 0.15 * k),
        Effect.stack => CarouselEffect.stack(offset: 24 * k),
        Effect.coverflow => CarouselEffect.coverflow(angle: math.pi / 4 * k),
        Effect.cube => CarouselEffect.cube(perspective: 0.002 * k),
        Effect.flip => CarouselEffect.flip(perspective: 0.002 * k),
        Effect.rotate => CarouselEffect.rotate(angle: math.pi / 12 * k),
      };

  CarouselIndicator indicator(ColorScheme scheme) {
    final style = SlideIndicatorStyle(
      activeColor: scheme.primary,
      inactiveColor: scheme.outline,
      animated: true,
    );
    return CarouselIndicator(
      painter: switch (painter) {
        Painter.slide => CircularSlideIndicator(style: style),
        Painter.still => CircularStaticIndicator(style: style),
        Painter.wave => CircularWaveIndicator(style: style),
        Painter.fill => SequentialFillIndicator(style: style),
      },
      placement: below
          ? CarouselIndicatorPlacement.below
          : CarouselIndicatorPlacement.overlay,
    );
  }

  CarouselAutoPlay? get carouselAutoPlay => autoPlay
      ? CarouselAutoPlay(
          interval: const Duration(seconds: 3),
          intervalFor: variedIntervals
              ? (i) => Duration(seconds: i.isEven ? 2 : 5)
              : null,
        )
      : null;

  ScrollPhysics? get physics => softSpring
      ? CarouselSnapPhysics(
          snapSpring: SpringDescription.withDampingRatio(
            mass: 0.5,
            stiffness: 50,
            ratio: 1,
          ),
        )
      : null;
}

class OptionsPanel extends StatelessWidget {
  const OptionsPanel({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final PlaygroundOptions options;
  final ValueChanged<PlaygroundOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget toggle(
      String label,
      bool value,
      PlaygroundOptions Function(bool) next,
    ) => FilterChip(
      label: Text(label),
      selected: value,
      onSelected: (v) => onChanged(next(v)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('FlutterCarousel')),
            ButtonSegment(value: true, label: Text('Expandable')),
          ],
          selected: {options.expandable},
          onSelectionChanged: (s) =>
              onChanged(options.copyWith(expandable: s.single)),
        ),
        const SizedBox(height: Gaps.m),
        DropdownMenu<Effect>(
          label: const Text('Effect'),
          expandedInsets: EdgeInsets.zero,
          initialSelection: options.effect,
          dropdownMenuEntries: [
            for (final e in Effect.values)
              DropdownMenuEntry(value: e, label: e.name),
          ],
          onSelected: (e) => onChanged(options.copyWith(effect: e)),
        ),
        const SizedBox(height: Gaps.m),
        DropdownMenu<Painter>(
          label: const Text('Indicator'),
          expandedInsets: EdgeInsets.zero,
          initialSelection: options.painter,
          dropdownMenuEntries: [
            for (final p in Painter.values)
              DropdownMenuEntry(value: p, label: p.name),
          ],
          onSelected: (p) => onChanged(options.copyWith(painter: p)),
        ),
        const SizedBox(height: Gaps.s),
        Text('Effect strength ${options.strength.toStringAsFixed(2)}'),
        Slider(
          value: options.strength,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          onChanged: options.effect == Effect.none
              ? null
              : (v) => onChanged(options.copyWith(strength: v)),
        ),
        Text(
          'Viewport fraction ${options.viewportFraction.toStringAsFixed(2)}',
        ),
        Slider(
          value: options.viewportFraction,
          min: 0.4,
          max: 1,
          divisions: 12,
          onChanged: (v) => onChanged(options.copyWith(viewportFraction: v)),
        ),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          children: [
            toggle(
              'Autoplay',
              options.autoPlay,
              (v) => options.copyWith(autoPlay: v),
            ),
            toggle(
              'Varied intervals',
              options.variedIntervals,
              (v) => options.copyWith(variedIntervals: v),
            ),
            toggle(
              'Infinite',
              options.infinite,
              (v) => options.copyWith(infinite: v),
            ),
            toggle(
              'Pad ends',
              options.padEnds,
              (v) => options.copyWith(padEnds: v),
            ),
            toggle(
              'Flush edges',
              options.flush,
              (v) => options.copyWith(flush: v),
            ),
            toggle(
              'Reverse',
              options.reverse,
              (v) => options.copyWith(reverse: v),
            ),
            toggle(
              'Vertical',
              options.vertical,
              (v) => options.copyWith(vertical: v),
            ),
            toggle(
              'Right to left',
              options.rtl,
              (v) => options.copyWith(rtl: v),
            ),
            toggle(
              'Indicator below',
              options.below,
              (v) => options.copyWith(below: v),
            ),
            toggle(
              'Soft snap spring',
              options.softSpring,
              (v) => options.copyWith(softSpring: v),
            ),
          ],
        ),
      ],
    );
  }
}
