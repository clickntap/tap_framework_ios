#import "AppDelegate.h"
#import <tap_framework_ios/TapApp.h>
#import <tap_framework_ios/TapUtils.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    if(launchOptions != nil) {
        [options setObject:launchOptions forKey:@"launchOptions"];
    }
    [options setObject:@"http://monoedit.clickntap.com/preview.app" forKey:@"baseUrl"];
    [options setObject:@"http://monoedit.clickntap.com/api/version/sod/release" forKey:@"appUrl"];
    [options setObject:@"0" forKey:@"developer"];
    
    [options setObject:@"#ffffff" forKey:@"backgroundColor"];
    [options setObject:@"#46a29a" forKey:@"color"];
    [options setObject:@"0" forKey:@"statusBar"];
    [options setObject:@"65" forKey:@"projectId"];
    [options setObject:@"0" forKey:@"fullScreen"];
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
