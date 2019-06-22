#import "TapWebVideoView.h"
#import "TapApp.h"
#import "TapUtils.h"

@implementation TapWebVideoView

@synthesize videoUrl;

-(void)show {
    n = 0;
    [self findVideo];
}

-(void)findVideo {
    n++;
    if(n < 10) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self->webView evaluateJavaScript:self.conf[@"result"] completionHandler:^(id result, NSError *error) {
                self.videoUrl = result;
                if(self.videoUrl == nil) {
                    [self performSelector:@selector(findVideo) withObject:nil afterDelay:0.5];
                } else {
                    if(self->playerLayer == nil) {
                        self->spinnerBackground.alpha = 0;
                        NSURL *videoURL = [NSURL URLWithString:self.videoUrl];
                        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                        self->playerLayer = [[AVPlayerViewController alloc] init];
                        [self->playerLayer setPlayer:player];
                        self->playerLayer.view.alpha = 0;
                        if(self.conf[@"fill"] != nil && [self.conf[@"fill"] intValue] == 1) {
                            self->playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        }
                        [self addSubview: [self->playerLayer view]];
                        [player play];
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:0.5];
                        self->playerLayer.view.alpha = 1;
                        [UIView commitAnimations];
                        [self->webView removeFromSuperview];
                        self->webView = nil;
                        self->playerOutput = [[AVPlayerItemVideoOutput alloc] init];
                        [self->playerLayer.player.currentItem addOutput:self->playerOutput];
                        [self->playerLayer.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
                    }
                }
            }];
        }];
    } else {
        [parent js:self.conf[@"onError"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewComponentRemove" object:self];
    }
}

- (void)close {
    [super close];
    [self->playerLayer.player.currentItem removeOutput:self->playerOutput];
    [self->playerLayer.player.currentItem removeObserver:self forKeyPath:@"status"];
}

-(void)dealloc {
    NSLog(@"DEALLOC %@", self);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self->parent js:self.conf[@"onSuccess"]];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(playerLayer != nil) {
        playerLayer.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

-(void)snapshot {
    CMTime currentTime = self->playerLayer.player.currentItem.currentTime;
    CVPixelBufferRef buffer = [self->playerOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    UIImage *newImage = [TapUtils imageWithImage:image scaledToSize:image.size];
    NSArray * shareItems = @[newImage];
    UIActivityViewController * controller = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [[[TapApp sharedInstance] navigationController] presentViewController:controller animated:YES completion:nil];
}

@end
