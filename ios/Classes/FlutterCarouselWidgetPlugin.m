#import "FlutterCarouselWidgetPlugin.h"
#if __has_include(<flutter_carousel_widget/flutter_carousel_widget-Swift.h>)
#import <flutter_carousel_widget/flutter_carousel_widget-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_carousel_widget-Swift.h"
#endif

@implementation FlutterCarouselWidgetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCarouselWidgetPlugin registerWithRegistrar:registrar];
}
@end
