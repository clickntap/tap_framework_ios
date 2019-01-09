#import "TapView.h"

@implementation TapView

- (void)layoutSubviews {
    if (!CGSizeEqualToSize(previousSize, self.frame.size)) {
        previousSize = self.frame.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewSizeChanged" object:self];
    }
}

@end
