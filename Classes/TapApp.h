#import "TapAppController.h"
#import "TapAppNavigationController.h"
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapApp : NSObject {
    TapAppNavigationController* navigationController;
    TapAppController* controller;
    SystemSoundID soundId;
    double backgroundTime;
    NSDictionary* options;
}

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSDictionary* options;

-(void)setApp:(NSDictionary *)options;
-(void)didRegisterForRemoteNotifications:(NSData *)token;
-(void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(NSString*)option:(NSString*)optionName;
-(void)setOption:(NSString*)optionName value:(NSObject*)optionValue;
-(float)optionAsFloat:(NSString*)optionName;
-(UIColor*)optionAsColor:(NSString*)optionName;
-(int)optionAsInt:(NSString*)optionName;
-(TapAppNavigationController*)navigationController;

+(id)sharedInstance;

@end

NS_ASSUME_NONNULL_END
