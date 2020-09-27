#import "NotifierPlugin.h"
#if __has_include(<notifier/notifier-Swift.h>)
#import <notifier/notifier-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "notifier-Swift.h"
#endif

@implementation NotifierPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNotifierPlugin registerWithRegistrar:registrar];
}
@end
