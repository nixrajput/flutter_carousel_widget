import 'package:flutter/widgets.dart';

/// Page snapping with a tunable spring.
///
/// `PageView` wraps its physics in [PageScrollPhysics], whose spring comes
/// from its parent, so the spring set here is the one every snap uses.
class CarouselSnapPhysics extends ScrollPhysics {
  /// Creates snap physics. `null` [snapSpring] keeps Flutter's spring (mass
  /// 0.5, stiffness 100, damping ratio 1.1).
  const CarouselSnapPhysics({this.snapSpring, super.parent});

  /// The spring each snap follows.
  final SpringDescription? snapSpring;

  @override
  CarouselSnapPhysics applyTo(ScrollPhysics? ancestor) => CarouselSnapPhysics(
    snapSpring: snapSpring,
    parent: buildParent(ancestor),
  );

  @override
  SpringDescription get spring => snapSpring ?? super.spring;
}
