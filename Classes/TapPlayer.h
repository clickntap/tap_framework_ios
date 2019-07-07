#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapPlayer : NSObject {
}

-(void)setView:(UIView*)view;
-(void)setSource:(NSString*)source;
-(void)play;

@end

NS_ASSUME_NONNULL_END
