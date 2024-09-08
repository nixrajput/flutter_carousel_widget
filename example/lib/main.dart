import 'package:flutter/material.dart';

import 'app_themes.dart';
import 'views/custom_indicator.dart';
import 'views/enlarge.dart';
import 'views/expandable.dart';
import 'views/fullscreen.dart';
import 'views/home.dart';
import 'views/indicator_halo.dart';
import 'views/manual.dart';
import 'views/multiple_items.dart';
import 'views/page_change_reason.dart';
import 'views/standard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlutterCarouselDemo());
}

class FlutterCarouselDemo extends StatelessWidget {
  const FlutterCarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const CarouselDemoHome(),
        '/standard': (ctx) => const StandardCarouselDemo(),
        '/enlarge': (ctx) => const EnlargeStrategyCarouselDemo(),
        '/manual': (ctx) => const ManuallyControlledCarouselDemo(),
        '/fullscreen': (ctx) => const FullscreenCarouselDemo(),
        '/custom_indicator': (ctx) => const CustomIndicatorCarouselDemo(),
        '/indicator_halo': (ctx) => const HaloIndicatorCarouselDemo(),
        '/multiple_items': (ctx) => const MultipleItemsCarouselDemo(),
        '/expandable': (ctx) => const ExpandableCarouselDemo(),
        '/page_changed_reason': (ctx) => const PageChangedReasonCarouselDemo(),
      },
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
