#import "TapWebView.h"
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapWebVideoView : TapWebView {
    AVPlayerViewController* playerLayer;
    AVPlayerItemVideoOutput* playerOutput;
    int n;
}

-(void)snapshot;

@property (nonatomic,copy) NSString* videoUrl;

@end

NS_ASSUME_NONNULL_END
