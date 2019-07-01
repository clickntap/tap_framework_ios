#import "TapView.h"

@implementation TapView

- (void)layoutSubviews {
    if (!CGSizeEqualToSize(previousSize, self.frame.size)) {
        previousSize = self.frame.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewSizeChanged" object:self];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImage*)grab {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
