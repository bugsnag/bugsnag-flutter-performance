#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GeneratedPluginRegistrant registerWithRegistry:self];

    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* nativeChannel = [FlutterMethodChannel methodChannelWithName:@"com.bugsnag.mazeRunner/platform"
              binaryMessenger:controller.engine.binaryMessenger
    ];

    [nativeChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        [self onMethod :call :result];
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)onMethod:(FlutterMethodCall*) call
               :(FlutterResult) result {
    NSLog(@"FlutterMethodCallHandler: %@ %@", call.method, call.arguments);
    
    if([@"getCommand" isEqualToString:call.method]) {
        result([self getCommandWithUrl:call.arguments[@"commandUrl"]]);
    }
}

-(NSString *)getCommandWithUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return ret;
}

@end
