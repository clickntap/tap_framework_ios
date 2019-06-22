#import "TapApp.h"
#import "TapUtils.h"
#import <Colorkit/Colorkit.h>

@implementation TapApp

@synthesize options;

+ (id)sharedInstance {
    static TapApp *sharedApp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApp = [[self alloc] init];
    });
    return sharedApp;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

-(void)setApp:(NSDictionary *)options {
    NSMutableDictionary* conf = [[NSMutableDictionary alloc] initWithDictionary:options];
    self.options = conf;
    if([[[TapApp sharedInstance] option:@"developer"] intValue] == 1) {
        NSLog(@"%@", [TapUtils json:self.options]);
    }
    soundId = 0;
    backgroundTime = [[NSDate date] timeIntervalSince1970];
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    UIColor* backgroundColor = [[TapApp sharedInstance] optionAsColor:@"backgroundColor"];
    window.backgroundColor = backgroundColor;
    controller = [[TapAppController alloc] init];
    navigationController = [[TapAppNavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBarHidden = YES;
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sound:) name:@"sound" object:nil];
 }

-(void)setOption:(NSString*)optionName value:(NSObject*)optionValue {
    NSMutableDictionary* newOptions = [[NSMutableDictionary alloc] initWithDictionary:options];
    [newOptions setObject:optionValue forKey:optionName];
    self.options = options;
}

-(NSString*)option:(NSString*)optionName {
    return [options objectForKey:optionName];
}

-(float)optionAsFloat:(NSString*)optionName {
    return [[self option:optionName] floatValue];
}

-(UIColor*)optionAsColor:(NSString*)optionName {
    return [UIColor colorWithHexString:[self option:optionName]];
}

-(int)optionAsInt:(NSString*)optionName {
    return [[self option:optionName] intValue];
}

-(void)sound:(NSNotification*)notification {
    [self playSound:notification.object];
}

-(void)playSound:(NSString*)sound {
    if(soundId) {
        AudioServicesDisposeSystemSoundID(soundId);
    }
    AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:sound withExtension:@"m4a"], &soundId);
    AudioServicesPlaySystemSound(soundId);
}

- (void)didRegisterForRemoteNotifications:(NSData *)deviceToken {
    NSMutableString *token = [NSMutableString string];
    const unsigned char *dataBuffer = [deviceToken bytes];
    for (int i=0; i<[deviceToken length]; ++i) {
        [token appendFormat:@"%02X", (unsigned int)dataBuffer[i]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"pushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[TapApp sharedInstance] setOption:@"pushToken" value:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"optionsChanged" object:nil];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", err);
}

-(void)applicationDidEnterBackground {
    backgroundTime = [[NSDate date] timeIntervalSince1970];
}

-(void)applicationWillEnterForeground {
    double time = [[NSDate date] timeIntervalSince1970];
    double limit = 60*5;
    if([[[TapApp sharedInstance] option:@"developer"] intValue] == 1) {
        limit = 0;
    }
    if(time-backgroundTime > limit) {
        [self setApp:options];
    }
}

-(TapAppNavigationController*)navigationController {
    return navigationController;
}

@end
