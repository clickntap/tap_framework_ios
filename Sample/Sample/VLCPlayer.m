#import "VLCPlayer.h"

@implementation VLCPlayer

- (id)init {
    if (self = [super init]) {
        mediaPlayer = [[VLCMediaPlayer alloc] init];
    }
    return self;
}

-(void)setView:(UIView*)view {
    mediaPlayer.drawable = view;
}

-(void)setSource:(NSString*)source {
    mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:source]];
}

-(void)play {
    [mediaPlayer play];
}

@end
