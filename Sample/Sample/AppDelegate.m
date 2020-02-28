#import "AppDelegate.h"
#import <tap_framework_ios/TapApp.h>
#import <tap_framework_ios/TapUtils.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    if(launchOptions != nil) {
        [options setObject:launchOptions forKey:@"launchOptions"];
    }
    [[TapApp sharedInstance] setApp:options];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TapApp sharedInstance] applicationDidEnterBackground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[TapApp sharedInstance] applicationWillEnterForeground];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[TapApp sharedInstance] didRegisterForRemoteNotifications:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [[TapApp sharedInstance] didFailToRegisterForRemoteNotificationsWithError:err];
}
@end
