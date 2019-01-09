#import <UIKit/UIKit.h>

@interface TapController : UIViewController {
    UIView * backgroundView;
}

- (void)loadUi;
- (void)setupUi:(CGSize)size;
- (void)needsSetupUi;
- (void)resetUi;

@end
