#import <tap_framework_ios/TapPlayer.h>
#import  <MobileVLCKit/MobileVLCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLCPlayer : TapPlayer {
    VLCMediaPlayer *mediaPlayer;
}

@end

NS_ASSUME_NONNULL_END
