import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../a11y/carousel_actions.dart';
import '../auto_play/auto_play_driver.dart';
import '../controller/flutter_carousel_controller.dart';
import '../effects/carousel_effect.dart';
import '../effects/carousel_item_position.dart';
import '../indicators/carousel_indicator.dart';
import '../indicators/indicator_view.dart';
import '../indicators/slide_indicator_geometry.dart';
import '../physics/carousel_snap_physics.dart';
import '../types.dart';
import 'carousel_config.dart';
import 'infinite_index.dart';
import 'reason_tracker.dart';
import 'sizing.dart';

/// How long an autoplay or controller move takes by default.
const kCarouselMoveDuration = Duration(milliseconds: 500);

/// The curve of an autoplay or controller move by default.
const Curve kCarouselMoveCurve = Curves.easeInOutCubicEmphasized;

const _dragDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.trackpad,
};

/// What sizing, indicators and effects read from a running carousel.
abstract interface class CarouselView {
  /// Notifies on every scroll frame.
  Listenable get scroll;

  /// How many items the carousel has.
  int get itemCount;

  /// The current item.
  int get index;

  /// The fractional item position, in `[0, itemCount)`.
  double get position;

  /// Whether the carousel loops.
  bool get infinite;

  /// The scroll axis.
  Axis get axis;

  /// Measured item sizes, for content sizing.
  PageSizes get sizes;

  /// The current item, notifying when it changes.
  ValueListenable<int> get current;

  /// The screen-reader label for item [index].
  String slideLabel(int index);

  /// The ambient text direction.
  TextDirection get textDirection;

  /// The indicator's view of the position.
  SlideIndicatorGeometry get geometry;

  /// Where the item on [page] sits, for an effect.
  CarouselItemPosition itemPosition(int page, int index);

  /// Moves to item [index], reporting [reason].
  Future<void> goTo(int index, CarouselPageChangedReason reason);
}

/// The implementation both public carousels share.
class CarouselEngine extends StatefulWidget {
  /// Creates the engine; only the public widgets call this.
  const CarouselEngine({
    super.key,
    required this.config,
    required this.sizing,
    required this.itemCount,
    required this.itemBuilder,
    this.itemKeys,
  });

  /// The shared parameters.
  final CarouselConfig config;

  /// Fixed or content sizing.
  final CarouselSizing sizing;

  /// How many items there are.
  final int itemCount;

  /// Builds the item at an index.
  final CarouselItemBuilder itemBuilder;

  /// The items' keys when built from a list, so moved items keep their state.
  final List<Key?>? itemKeys;

  @override
  State<CarouselEngine> createState() => _CarouselEngineState();
}

class _CarouselEngineState extends State<CarouselEngine>
    implements CarouselBinding, CarouselView {
  late PageController _pages;
  final _retired = <PageController>[];
  final _reasons = ReasonTracker();
  FlutterCarouselController? _controller;
  var _index = 0;
  var _textDirection = TextDirection.ltr;
  var _viewport = Size.zero;

  @override
  final sizes = PageSizes();
  final _pagesKey = GlobalKey();
  // Marks the painted dots, so the tap band around the carousel finds them.
  final _dotsKey = GlobalKey();
  late final _current = ValueNotifier<int>(_index);

  @override
  ValueListenable<int> get current => _current;

  @override
  TextDirection get textDirection => _textDirection;

  @override
  String slideLabel(int index) =>
      (_config.semanticSlideLabel ?? _defaultSlideLabel)(index, itemCount);

  static String _defaultSlideLabel(int index, int count) =>
      'Slide ${index + 1} of $count';
  late final _autoPlay = AutoPlayDriver(
    onTick: _autoStep,
    onRunningChanged: _autoPlayChanged,
  );
  late final AppLifecycleListener _lifecycle;
  ValueListenable<TickerModeData>? _tickerMode;
  var _pointers = 0;
  var _settledIndex = 0;
  FocusNode? _ownFocus;

  FocusNode get _focusNode =>
      _config.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'Carousel'));

  CarouselConfig get _config => widget.config;

  @override
  int get itemCount => widget.itemCount;

  @override
  bool get infinite => _config.infinite && itemCount > 1;

  @override
  Axis get axis => _config.scrollDirection;

  @override
  Listenable get scroll => _pages;

  @override
  int get index => _index;

  @override
  void initState() {
    super.initState();
    _index = _clamp(_config.initialPage);
    _settledIndex = _index;
    _pages = _createPages(startPage(_index, itemCount, infinite: infinite));
    _attach(_config.controller);
    if (_config.edgeAlignment == CarouselEdgeAlignment.flush) _settleFlush();
    _autoPlay.configure(_config.autoPlay);
    _hold(AutoPlayPause.items, itemCount < 2);
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null) _onLifecycle(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hold(AutoPlayPause.route, ModalRoute.isCurrentOf(context) == false);
    _hold(
      AutoPlayPause.reducedMotion,
      MediaQuery.maybeDisableAnimationsOf(context) ?? false,
    );
    final tickerMode = TickerMode.getValuesNotifier(context);
    if (tickerMode != _tickerMode) {
      _tickerMode?.removeListener(_onTickerMode);
      _tickerMode = tickerMode..addListener(_onTickerMode);
      _onTickerMode();
    }
  }

  void _onTickerMode() =>
      _hold(AutoPlayPause.ticker, !_tickerMode!.value.enabled);

  void _onLifecycle(AppLifecycleState state) =>
      _hold(AutoPlayPause.lifecycle, state != AppLifecycleState.resumed);

  void _hold(AutoPlayPause reason, bool held) =>
      held ? _autoPlay.pause(reason) : _autoPlay.resume(reason);

  int _clamp(int index) => itemCount == 0 ? 0 : index.clamp(0, itemCount - 1);

  PageController _createPages(int page) => PageController(
    initialPage: page,
    keepPage: _config.keepPage,
    viewportFraction: _config.viewportFraction,
  );

  /// The item to show after the items change: the current item where its key
  /// survives, so it keeps its place and its state; otherwise the same index.
  int _follow(CarouselEngine old) {
    final keys = widget.itemKeys;
    final oldKeys = old.itemKeys;
    if (keys != null && oldKeys != null && _index < oldKeys.length) {
      final key = oldKeys[_index];
      final moved = key == null ? -1 : keys.indexOf(key);
      if (moved >= 0) return moved;
    }
    return _clamp(_index);
  }

  /// The page for [target] once the item count or looping changed. An infinite
  /// carousel stays in its cycle, so keyed copies keep their `_PageKey`.
  int _loopPage(CarouselEngine old, int target) {
    if (infinite && old.config.infinite && old.itemCount > 1) {
      return (_currentPage ~/ old.itemCount) * itemCount + target;
    }
    return startPage(target, itemCount, infinite: infinite);
  }

  @override
  void didUpdateWidget(CarouselEngine old) {
    super.didUpdateWidget(old);
    if (itemCount < old.itemCount) sizes.retain(itemCount);
    if (itemCount == 0) {
      _index = 0;
      _settledIndex = 0;
      _current.value = 0;
    }
    _autoPlay.configure(_config.autoPlay);
    _hold(AutoPlayPause.items, itemCount < 2);
    if (itemCount > old.itemCount) _autoPlay.resume(AutoPlayPause.ended);
    final autoPlay = _config.autoPlay;
    if (!(autoPlay?.pauseOnTouch ?? false)) {
      _autoPlay.resume(AutoPlayPause.touch);
    }
    if (!(autoPlay?.pauseOnHover ?? false)) {
      _autoPlay.resume(AutoPlayPause.hover);
    }
    if (!(autoPlay?.pauseOnFocus ?? false)) {
      _autoPlay.resume(AutoPlayPause.focus);
    }
    if (!(autoPlay?.stopAtEnd ?? false)) _autoPlay.resume(AutoPlayPause.ended);
    if (old.config.controller != _config.controller) {
      _detach();
      _attach(_config.controller);
    }
    final target = _follow(old);
    final loopChanged =
        old.itemCount != itemCount ||
        old.config.infinite != _config.infinite ||
        target != _index;
    // Looping on or off moves every page, and a position corrected in place
    // still clamps to the old extent until layout, so it gets new pages.
    final pagesChanged =
        old.config.viewportFraction != _config.viewportFraction ||
        old.config.keepPage != _config.keepPage ||
        old.config.infinite != _config.infinite;
    if (old.config.edgeAlignment != _config.edgeAlignment) _settleFlush();
    if (!loopChanged && !pagesChanged) return;
    final page = loopChanged
        ? _loopPage(old, target)
        : (infinite ? _currentPage : _index);
    if (pagesChanged) {
      _retired.add(_pages);
      _pages = _createPages(page);
    } else if (_pages.hasClients && _pages.position.hasContentDimensions) {
      // Layout would otherwise run at the old offset, past a shrunk list's end,
      // and drop the moved keyed pages before the clamp; set it without notifying.
      final position = _pages.position;
      position.correctPixels(
        _flush
            ? _flushTarget(page)
            : page * position.viewportDimension * _config.viewportFraction,
      );
    }
    // A new controller absorbs the old one's pixels, and a jump during build
    // would call onPageChanged mid-build, so the page is set after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final retired in _retired) {
        retired.dispose();
      }
      _retired.clear();
      if (!mounted || !_pages.hasClients) return;
      final token = _reasons.begin(CarouselPageChangedReason.controller);
      if (_flush) {
        _pages.jumpTo(_flushTarget(page));
        _onPageChanged(page);
      } else if (_currentPage != page) {
        // Until the next layout the extent is still the one from before the
        // change, so PageView would report a clamped page; report the target.
        _jumping = true;
        _pages.jumpToPage(page);
        _jumping = false;
        _onPageChanged(page);
      } else {
        // Shrinking items clamps the position during layout, which sends no
        // scroll notification, so PageView never reports the new page.
        _onPageChanged(_currentPage);
      }
      _announce();
      _reasons.end(token);
    });
  }

  @override
  void dispose() {
    _autoPlay.dispose();
    _lifecycle.dispose();
    _tickerMode?.removeListener(_onTickerMode);
    _detach();
    for (final retired in _retired) {
      retired.dispose();
    }
    _retired.clear();
    _ownFocus?.dispose();
    sizes.dispose();
    _current.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _attach(FlutterCarouselController? controller) {
    _controller = controller;
    if (controller != null) attachController(controller, this);
  }

  void _detach() {
    final controller = _controller;
    if (controller != null) detachController(controller, this);
    _controller = null;
  }

  double? get _page {
    if (!_pages.hasClients) return null;
    final position = _pages.position;
    return position.hasContentDimensions && position.hasPixels
        ? _pages.page
        : null;
  }

  // PageView rounds pixels / extent, which is off by up to a page near flush edges.
  int get _currentPage => _flush && _page != null
      ? position.round()
      : _page?.round() ?? _pages.initialPage;

  // Below a third of the viewport, several items share the leading edge's
  // settle offset and could never be current, so narrower pages centre.
  bool get _flush =>
      _config.edgeAlignment == CarouselEdgeAlignment.flush &&
      !infinite &&
      _config.viewportFraction > 1 / 3;

  // A PageController starts on whole pages, so page 0 sits at pixel 0 rather
  // than at the gap; move to the flush offset once the viewport is laid out.
  void _settleFlush() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && _flush && _pages.hasClients) {
      _pages.jumpTo(_flushTarget(_index));
    }
  });

  /// The offset item [i] settles at when flush: centred, but clamped so the
  /// first and last items meet the edges. padEnds is forced on, so page i sits
  /// at i * extent and the scroll ends at (itemCount - 1) * extent.
  double _flushTarget(int i) {
    final viewport = _pages.position.viewportDimension;
    final extent = viewport * _config.viewportFraction;
    // The sliver's own padding expression, so edges land on exactly 0 and the width.
    final gap = viewport * (1 - _config.viewportFraction) / 2;
    return (i * extent).clamp(
      gap,
      math.max(gap, (itemCount - 1) * extent - gap),
    );
  }

  /// The fractional item position when flush: piecewise-linear between the
  /// items' settle offsets, which near the edges are not a page apart.
  double _flushPosition() {
    final pixels = _pages.position.pixels;
    for (var i = 0; i < itemCount - 1; i++) {
      final a = _flushTarget(i);
      final b = _flushTarget(i + 1);
      if (b <= a) continue;
      if (pixels <= b || i == itemCount - 2) {
        return (i + (pixels - a) / (b - a)).clamp(0, itemCount - 1).toDouble();
      }
    }
    return 0;
  }

  @override
  double get position {
    if (_flush && _page != null) return _flushPosition();
    final page = _page;
    if (page == null) return _index.toDouble();
    return positionAt(_reachable(page), itemCount, infinite: infinite);
  }

  double _reachable(double page) {
    if (infinite || _config.padEnds) return page;
    final metrics = _pages.position;
    final extent = metrics.viewportDimension * _config.viewportFraction;
    if (extent <= 0) return page;
    return reachablePage(
      page,
      maxPage: metrics.maxScrollExtent / extent,
      itemCount: itemCount,
    );
  }

  @override
  bool get isAutoPlaying => _autoPlay.isRunning;

  @override
  set autoPlayStopped(bool value) {
    _hold(AutoPlayPause.stopped, value);
    if (!value) _autoPlay.resume(AutoPlayPause.ended);
  }

  void _autoPlayChanged() {
    final controller = _controller;
    if (controller == null) return;
    // Pauses flip during build (dependencies, updates); listeners that call
    // setState must hear about it after the frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => notifyController(controller),
      );
    } else {
      notifyController(controller);
    }
  }

  void _autoStep() {
    final config = _config.autoPlay;
    if (config == null || itemCount < 2 || !_pages.hasClients) return;
    final direction = _config.reverse ? -1 : 1;
    var target = _currentPage + direction;
    if (!infinite && (target < 0 || target >= itemCount)) {
      if (config.stopAtEnd) {
        _autoPlay.pause(AutoPlayPause.ended);
        return;
      }
      target = direction > 0 ? 0 : itemCount - 1;
    }
    unawaited(
      _move(
        target,
        CarouselPageChangedReason.timed,
        config.duration,
        config.curve,
      ),
    );
  }

  void _pointerGone(PointerEvent _) {
    if (--_pointers > 0) return;
    _pointers = 0;
    _autoPlay.resume(AutoPlayPause.touch);
  }

  @override
  Future<void> step(int delta, {Duration? duration, Curve? curve}) =>
      _stepBy(delta, CarouselPageChangedReason.controller, duration, curve);

  Future<void> _stepBy(
    int delta,
    CarouselPageChangedReason reason, [
    Duration? duration,
    Curve? curve,
  ]) {
    if (itemCount == 0) return Future.value();
    var target = _currentPage + delta;
    if (!infinite) target = target.clamp(0, itemCount - 1);
    return _move(target, reason, duration, curve);
  }

  bool get _canGoOn => itemCount > 1 && (infinite || _index < itemCount - 1);

  bool get _canGoBack => itemCount > 1 && (infinite || _index > 0);

  @override
  Future<void> animateTo(int index, {Duration? duration, Curve? curve}) {
    RangeError.checkValueInInterval(index, 0, itemCount - 1, 'index');
    return _move(
      _pageOf(index),
      CarouselPageChangedReason.controller,
      duration,
      curve,
    );
  }

  @override
  void jumpTo(int index) {
    RangeError.checkValueInInterval(index, 0, itemCount - 1, 'index');
    if (!_pages.hasClients) return;
    final token = _reasons.begin(CarouselPageChangedReason.controller);
    _flush
        ? _pages.jumpTo(_flushTarget(index))
        : _pages.jumpToPage(_pageOf(index));
    _reasons.end(token);
  }

  @override
  Future<void> goTo(int index, CarouselPageChangedReason reason) =>
      _move(_pageOf(index), reason, null, null);

  int _pageOf(int index) => pageFor(
    index,
    page: _currentPage,
    itemCount: itemCount,
    infinite: infinite,
  );

  Future<void> _move(
    int page,
    CarouselPageChangedReason reason,
    Duration? duration,
    Curve? curve,
  ) async {
    if (!_pages.hasClients) return;
    final token = _reasons.begin(reason);
    try {
      final offset = _flush ? _flushTarget(page.clamp(0, itemCount - 1)) : null;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        offset == null ? _pages.jumpToPage(page) : _pages.jumpTo(offset);
      } else if (offset == null) {
        await _pages.animateToPage(
          page,
          duration: duration ?? kCarouselMoveDuration,
          curve: curve ?? kCarouselMoveCurve,
        );
      } else {
        await _pages.animateTo(
          offset,
          duration: duration ?? kCarouselMoveDuration,
          curve: curve ?? kCarouselMoveCurve,
        );
      }
    } finally {
      _reasons.end(token);
    }
  }

  @override
  CarouselItemPosition itemPosition(
    int page,
    int index,
  ) => CarouselItemPosition(
    index: index,
    itemCount: itemCount,
    // Flush and padEnds false settle items off the page grid; position knows.
    offset: _flush || (!infinite && !_config.padEnds)
        ? page - position
        : page - (_page ?? _currentPage.toDouble()),
    axis: axis,
    textDirection: _textDirection,
    reverse: _config.reverse,
    viewportFraction: _config.viewportFraction,
    extent: axis == Axis.horizontal
        ? Size(_viewport.width * _config.viewportFraction, _viewport.height)
        : Size(_viewport.width, _viewport.height * _config.viewportFraction),
  );

  bool get _flipped =>
      (axis == Axis.horizontal && _textDirection == TextDirection.rtl) !=
      _config.reverse;

  @override
  SlideIndicatorGeometry get geometry => SlideIndicatorGeometry(
    itemCount: itemCount,
    position: position,
    infinite: infinite,
    axis: axis,
    flipped: _flipped,
  );

  /// Set while a jump reports its own page.
  var _jumping = false;

  void _onPageViewChanged(int page) {
    if (!_jumping) _onPageChanged(page);
  }

  void _onPageChanged(int page) {
    if (itemCount == 0) return;
    final index = itemAt(page, itemCount);
    if (index == _index) return;
    _index = index;
    _current.value = index;
    _config.onPageChanged?.call(index, _reasons.reason);
    final controller = _controller;
    if (controller != null) notifyController(controller);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    if ((n is ScrollStartNotification && n.dragDetails != null) ||
        (n is UserScrollNotification && n.direction != ScrollDirection.idle)) {
      _reasons.userScroll();
    }
    if (n is ScrollUpdateNotification) {
      _config.onScrolled?.call(position);
      // PageView's own page report is off near flush edges; report from position.
      if (_flush && position.round() != _index) {
        _onPageChanged(position.round());
      }
    }
    if (n is ScrollEndNotification) {
      _announce();
      final timed = _reasons.reason == CarouselPageChangedReason.timed;
      _autoPlay.settled(
        _index,
        restart: timed || (_config.autoPlay?.restartOnInteraction ?? true),
      );
      final next = _index + (_config.reverse ? -1 : 1);
      if ((_config.autoPlay?.stopAtEnd ?? false) &&
          !infinite &&
          (next < 0 || next >= itemCount)) {
        _autoPlay.pause(AutoPlayPause.ended);
      }
    }
    return false;
  }

  /// Announces the item a move settled on, once, for user and app moves; the
  /// pages passed on the way, and autoplay, would be chatter.
  void _announce() {
    final changed = _index != _settledIndex;
    _settledIndex = _index;
    if (!changed ||
        itemCount == 0 ||
        _reasons.reason == CarouselPageChangedReason.timed ||
        !(MediaQuery.maybeAccessibleNavigationOf(context) ?? false)) {
      return;
    }
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        slideLabel(_index),
        _textDirection,
      ),
    );
  }

  Widget? _buildPage(BuildContext context, int page) {
    if (itemCount == 0) return null;
    final index = itemAt(page, itemCount);
    Widget child = widget.sizing.wrapItem(
      widget.itemBuilder(context, index, page),
      index: index,
      alignment: _config.itemAlignment,
      view: this,
    );
    final effect = _config.effect;
    if (!effect.isStatic) {
      child = _EffectItem(
        view: this,
        page: page,
        index: index,
        effect: effect,
        child: child,
      );
    }
    if (_config.keepAlive) {
      child = _KeepAlivePage(engine: this, page: page, child: child);
    }
    final key = widget.itemKeys?[index];
    if (key == null) return child;
    return KeyedSubtree(
      key: _PageKey(key, infinite ? page ~/ itemCount : 0),
      child: child,
    );
  }

  int? _findPage(Key key) {
    if (key is! _PageKey) return null;
    final index = widget.itemKeys!.indexOf(key.item);
    return index < 0 ? null : key.cycle * itemCount + index;
  }

  @override
  Widget build(BuildContext context) {
    _textDirection = Directionality.of(context);
    final config = _config;
    final behavior =
        config.scrollBehavior ??
        ScrollConfiguration.of(context).copyWith(
          dragDevices: _dragDevices,
          scrollbars: false,
          overscroll: false,
        );
    final basePhysics =
        config.physics ??
        const CarouselSnapPhysics().applyTo(behavior.getScrollPhysics(context));
    final pageView = PageView.custom(
      key: config.pageViewKey,
      controller: _pages,
      scrollDirection: config.scrollDirection,
      reverse: config.reverse,
      physics: _flush
          ? _FlushEdgePhysics(
              viewportFraction: config.viewportFraction,
              parent: basePhysics,
            )
          : basePhysics,
      pageSnapping: !_flush && config.pageSnapping,
      onPageChanged: _flush ? null : _onPageViewChanged,
      childrenDelegate: SliverChildBuilderDelegate(
        _buildPage,
        childCount: infinite ? null : itemCount,
        findChildIndexCallback: widget.itemKeys == null ? null : _findPage,
      ),
      dragStartBehavior: config.dragStartBehavior,
      allowImplicitScrolling: config.allowImplicitScrolling,
      restorationId: config.restorationId,
      clipBehavior: config.clipBehavior,
      scrollBehavior: behavior,
      padEnds: _flush || config.padEnds,
    );
    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        assert(() {
          final horizontal = axis == Axis.horizontal;
          if (horizontal
              ? constraints.hasBoundedWidth
              : constraints.hasBoundedHeight) {
            return true;
          }
          throw FlutterError.fromParts([
            ErrorSummary(
              'A ${horizontal ? 'horizontal' : 'vertical'} carousel needs a '
              'bounded ${horizontal ? 'width' : 'height'}.',
            ),
            ErrorHint(
              'It was given unbounded constraints along its scroll axis, as '
              'inside a scroll view on the same axis. Give it a size with a '
              'SizedBox, or a parent that bounds that axis.',
            ),
          ]);
        }());
        _viewport = constraints.biggest;
        return pageView;
      },
    );
    body = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: body,
    );
    body = widget.sizing.wrapViewport(context, this, body);
    final autoPlay = config.autoPlay;
    final interactive = MouseRegion(
      onEnter: (_) =>
          _hold(AutoPlayPause.hover, autoPlay?.pauseOnHover ?? false),
      onExit: (_) => _autoPlay.resume(AutoPlayPause.hover),
      child: Listener(
        onPointerDown: (_) {
          _pointers++;
          _hold(AutoPlayPause.touch, autoPlay?.pauseOnTouch ?? false);
        },
        onPointerUp: _pointerGone,
        onPointerCancel: _pointerGone,
        child: _placeIndicator(body),
      ),
    );
    // A content-sized carousel can be narrower or shorter than its parent;
    // the box, its semantics and its dots then follow the pages, centred.
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: FocusableActionDetector(
        enabled: config.keyboardNavigation && itemCount > 1,
        focusNode: _focusNode,
        autofocus: config.autofocus,
        shortcuts: carouselShortcuts(axis: axis, flipped: _flipped),
        actions: {
          CarouselStepIntent: CarouselKeyAction<CarouselStepIntent>(
            _focusNode,
            (intent) =>
                _stepBy(intent.delta, CarouselPageChangedReason.keyboard),
          ),
          CarouselEdgeIntent: CarouselKeyAction<CarouselEdgeIntent>(
            _focusNode,
            (intent) => goTo(
              intent.last ? itemCount - 1 : 0,
              CarouselPageChangedReason.keyboard,
            ),
          ),
        },
        onFocusChange: (focused) => _hold(
          AutoPlayPause.focus,
          focused && (autoPlay?.pauseOnFocus ?? false),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: _current,
          builder: (context, index, child) => Semantics(
            container: true,
            label: config.semanticLabel ?? 'Carousel',
            value: itemCount == 0 ? null : slideLabel(index),
            increasedValue: _canGoOn
                ? slideLabel(itemAt(index + 1, itemCount))
                : null,
            decreasedValue: _canGoBack
                ? slideLabel(itemAt(index - 1, itemCount))
                : null,
            onIncrease: _canGoOn
                ? () => unawaited(_stepBy(1, CarouselPageChangedReason.manual))
                : null,
            onDecrease: _canGoBack
                ? () => unawaited(_stepBy(-1, CarouselPageChangedReason.manual))
                : null,
            textDirection: _textDirection,
            child: child,
          ),
          child: interactive,
        ),
      ),
    );
  }

  Widget _placeIndicator(Widget pages) {
    // The parent changes with the indicator (none, overlay, below); the key moves
    // the pages instead of remounting them, which would lose their state and
    // briefly attach the PageController to two scroll views.
    final body = KeyedSubtree(key: _pagesKey, child: pages);
    final indicator = _config.indicator;
    if (indicator == null || itemCount < 2) return body;
    final horizontal = axis == Axis.horizontal;
    final alignment =
        indicator.alignment ??
        (horizontal ? Alignment.bottomCenter : AlignmentDirectional.centerEnd);
    final dots = IndicatorView(
      key: indicator == const CarouselIndicator()
          ? const ValueKey('default_indicator')
          : null,
      indicator: indicator,
      view: this,
      alignment: alignment,
      dotsKey: _dotsKey,
    );
    final placed = switch (indicator.placement) {
      CarouselIndicatorPlacement.overlay => Stack(
        children: [
          body,
          Positioned.fill(
            child: Align(alignment: alignment, child: dots),
          ),
        ],
      ),
      CarouselIndicatorPlacement.below when horizontal => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          Align(alignment: alignment, child: dots),
        ],
      ),
      CarouselIndicatorPlacement.below => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: body),
          Align(alignment: alignment, child: dots),
        ],
      ),
    };
    return IndicatorTapBand(
      indicator: indicator,
      view: this,
      alignment: alignment,
      dotsKey: _dotsKey,
      child: placed,
    );
  }
}

/// A page key made of the item's own key and which copy of it this is, so an
/// infinite carousel showing an item twice never has two equal keys. Being
/// its own type, it never equals a key the app made.
class _PageKey extends ValueKey<(Key, int)> {
  const _PageKey(Key item, int cycle) : super((item, cycle));

  Key get item => value.$1;
  int get cycle => value.$2;
}

class _EffectItem extends StatelessWidget {
  const _EffectItem({
    required this.view,
    required this.page,
    required this.index,
    required this.effect,
    required this.child,
  });

  final CarouselView view;
  final int page;
  final int index;
  final CarouselEffect effect;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: view.scroll,
    builder: (context, child) =>
        effect.apply(context, view.itemPosition(page, index), child!),
    child: child,
  );
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({
    required this.engine,
    required this.page,
    required this.child,
  });

  final _CarouselEngineState engine;
  final int page;
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  // An infinite carousel makes new pages every lap; keep only one lap's worth
  // around the current page, or every page ever shown stays in memory.
  @override
  bool get wantKeepAlive {
    final engine = widget.engine;
    return !engine.infinite ||
        (widget.page - engine._currentPage).abs() < engine.itemCount;
  }

  @override
  void initState() {
    super.initState();
    widget.engine._current.addListener(updateKeepAlive);
  }

  @override
  void dispose() {
    widget.engine._current.removeListener(updateKeepAlive);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Snaps to each page's centred offset, clamped so the first and last pages
/// sit flush with the viewport's edges.
class _FlushEdgePhysics extends ScrollPhysics {
  const _FlushEdgePhysics({required this.viewportFraction, super.parent});

  final double viewportFraction;

  @override
  _FlushEdgePhysics applyTo(ScrollPhysics? ancestor) => _FlushEdgePhysics(
    viewportFraction: viewportFraction,
    parent: buildParent(ancestor),
  );

  double _gap(ScrollMetrics m) =>
      m.viewportDimension * (1 - viewportFraction) / 2;

  double _min(ScrollMetrics m) => m.minScrollExtent + _gap(m);

  double _max(ScrollMetrics m) =>
      math.max(_min(m), m.maxScrollExtent - _gap(m));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final min = _min(position);
    final max = _max(position);
    if (value < position.pixels && position.pixels <= min) {
      return value - position.pixels;
    }
    if (max <= position.pixels && position.pixels < value) {
      return value - position.pixels;
    }
    if (value < min && min < position.pixels) return value - min;
    if (position.pixels < max && max < value) return value - max;
    return 0;
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) => super
      .adjustPositionForNewDimensions(
        oldPosition: oldPosition,
        newPosition: newPosition,
        isScrolling: isScrolling,
        velocity: velocity,
      )
      .clamp(_min(newPosition), _max(newPosition));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final extent = position.viewportDimension * viewportFraction;
    if (extent <= 0) return null;
    final tolerance = toleranceFor(position);
    double at(double page) =>
        (page * extent).clamp(_min(position), _max(position));
    final page = position.pixels / extent;
    final double target;
    if (velocity.abs() > tolerance.velocity) {
      target = at((page + (velocity > 0 ? 0.5 : -0.5)).roundToDouble());
    } else {
      // At rest the nearest settle offset wins; near a flush edge that is not
      // the nearest whole page.
      final below = at(page.floorToDouble());
      final above = at(page.ceilToDouble());
      target = position.pixels - below <= above - position.pixels
          ? below
          : above;
    }
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}
