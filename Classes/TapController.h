#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapController : UIViewController

- (void)loadUi;
- (void)setupUi:(CGSize)size;
- (void)needsSetupUi;
- (void)resetUi;

@end

NS_ASSUME_NONNULL_END
