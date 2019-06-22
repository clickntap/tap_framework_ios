#import "TapAppViewComponent.h"

@implementation TapAppViewComponent

@synthesize view, state, conf, animateConf;

-(void)setup {
    if(animateConf != nil) {
        UIView* view = self.view;
        CGRect frame = view.frame;
        if(animateConf[@"left"] != nil) {
            frame.origin.x = [animateConf[@"left"] floatValue];
        }
        if(animateConf[@"top"] != nil) {
            frame.origin.y = [animateConf[@"top"] floatValue];
        }
        if(animateConf[@"opacity"] != nil) {
            view.alpha = [animateConf[@"opacity"] floatValue];
        }
        view.frame = frame;
    }
}

-(void)setupAnimate {
    if(animateConf != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [self setup];
        [UIView commitAnimations];
    }
}

@end
