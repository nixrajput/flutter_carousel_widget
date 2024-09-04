import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/src/enums/center_page_enlarge_strategy.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_state.dart';
import 'package:flutter_carousel_widget/src/indicators/circular_slide_indicator.dart';
import 'package:flutter_carousel_widget/src/utils/flutter_carousel_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterCarousel Unit Tests', () {
    test('Default values of CarouselOptions should be as expected', () {
      final options = CarouselOptions();

      expect(options.height, null);
      expect(options.aspectRatio, null);
      expect(options.viewportFraction, 0.8);
      expect(options.initialPage, 0);
      expect(options.enableInfiniteScroll, false);
      expect(options.reverse, false);
      expect(options.autoPlay, false);
      expect(options.autoPlayInterval, const Duration(seconds: 5));
      expect(
          options.autoPlayAnimationDuration, const Duration(milliseconds: 300));
      expect(options.autoPlayCurve, Curves.easeInCubic);
      expect(options.enlargeCenterPage, false);
      expect(options.enlargeFactor, 0.25);
      expect(options.controller, null);
      expect(options.onPageChanged, null);
      expect(options.onScrolled, null);
      expect(options.physics, isA<BouncingScrollPhysics>());
      expect(options.scrollDirection, Axis.horizontal);
      expect(options.pauseAutoPlayOnTouch, true);
      expect(options.pauseAutoPlayOnManualNavigate, true);
      expect(options.pauseAutoPlayInFiniteScroll, false);
      expect(options.pageViewKey, null);
      expect(options.keepPage, true);
      expect(options.enlargeStrategy, CenterPageEnlargeStrategy.scale);
      expect(options.disableCenter, false);
      expect(options.showIndicator, true);
      expect(options.floatingIndicator, true);
      expect(options.indicatorMargin, 8.0);
      expect(options.slideIndicator, isA<CircularSlideIndicator>());
      expect(options.clipBehavior, Clip.antiAlias);
      expect(options.scrollBehavior, null);
      expect(options.pageSnapping, true);
      expect(options.padEnds, true);
      expect(options.dragStartBehavior, DragStartBehavior.start);
      expect(options.allowImplicitScrolling, false);
      expect(options.restorationId, null);
    });

    test('CarouselOptions should accept and return custom values', () {
      final options = CarouselOptions(
        height: 300,
        aspectRatio: 2.0,
        viewportFraction: 0.9,
        initialPage: 2,
        enableInfiniteScroll: true,
        reverse: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 500),
        autoPlayCurve: Curves.easeInOut,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        scrollDirection: Axis.vertical,
        pageSnapping: false,
        showIndicator: false,
        floatingIndicator: false,
        disableCenter: true,
      );

      expect(options.height, 300);
      expect(options.aspectRatio, 2.0);
      expect(options.viewportFraction, 0.9);
      expect(options.initialPage, 2);
      expect(options.enableInfiniteScroll, true);
      expect(options.reverse, true);
      expect(options.autoPlay, true);
      expect(options.autoPlayInterval, const Duration(seconds: 3));
      expect(
          options.autoPlayAnimationDuration, const Duration(milliseconds: 500));
      expect(options.autoPlayCurve, Curves.easeInOut);
      expect(options.enlargeCenterPage, true);
      expect(options.enlargeFactor, 0.3);
      expect(options.scrollDirection, Axis.vertical);
      expect(options.pageSnapping, false);
      expect(options.showIndicator, false);
      expect(options.floatingIndicator, false);
      expect(options.disableCenter, true);
    });

    test(
        'CarouselOptions copyWith should return new instance with updated values',
        () {
      final options = CarouselOptions();

      final newOptions = options.copyWith(
        height: 400,
        aspectRatio: 1.5,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 10),
      );

      expect(newOptions.height, 400);
      expect(newOptions.aspectRatio, 1.5);
      expect(newOptions.autoPlay, true);
      expect(newOptions.autoPlayInterval, const Duration(seconds: 10));

      // Ensure unchanged values are still the same
      expect(newOptions.viewportFraction, options.viewportFraction);
      expect(newOptions.initialPage, options.initialPage);
    });

    test('CarouselState initialization', () {
      final options = CarouselOptions();
      final carouselState = CarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );

      expect(carouselState.options, options);
      expect(carouselState.initialPage, 0);
      expect(carouselState.realPage, 10000);
      expect(carouselState.pageController, isNull);
      expect(carouselState.itemCount, isNull);
    });

    test('CarouselState item count', () {
      final options = CarouselOptions();
      final carouselState = CarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );

      carouselState.itemCount = 5;
      expect(carouselState.itemCount, 5);
    });

    test('CarouselControllerImpl initialization, set state and ready completer',
        () async {
      // Create the controller
      final controller = CarouselControllerImpl();

      // Verify initial state
      expect(controller.ready, false);

      // Create a mock CarouselState and assign it to the controller's state
      final options = CarouselOptions();
      final state = CarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );

      // Assigning state to complete the future
      controller.state = state;

      // Verify that onReady completes and controller is ready
      await controller.onReady;
      expect(controller.ready, true);
      expect(controller.onReady, completes);
    });

    test('CarouselControllerImpl jumpToPage', () {
      final options = CarouselOptions();
      final controller = CarouselControllerImpl();
      final state = CarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );
      controller.state = state;
      controller.jumpToPage(2);
      expect(state.realPage, 10000);
    });

    test('getRealIndex basic calculation', () {
      final realIndex = getRealIndex(10005, 10000, 5);
      expect(realIndex, 0); // 10005 - 10000 % 5 = 5 % 5 = 0
    });

    test('getRealIndex negative index', () {
      final realIndex = getRealIndex(9999, 10000, 5);
      expect(realIndex, 4); // (9999 - 10000) % 5 = -1 % 5 = 4
    });

    test('getRealIndex invalid item count', () {
      final realIndex = getRealIndex(10005, 10000, null);
      expect(realIndex, 0);
      final realIndex2 = getRealIndex(10005, 10000, 0);
      expect(realIndex2, 0);
    });
  });
}
