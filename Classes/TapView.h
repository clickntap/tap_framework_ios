#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapView : UIView {
    CGSize previousSize;
}

-(UIImage*)grab;

@end

NS_ASSUME_NONNULL_END
