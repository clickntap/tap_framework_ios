#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TapAppViewComponentState) {
    TapAppViewComponentStateOff,
    TapAppViewComponentStateOn
};

NS_ASSUME_NONNULL_BEGIN

@interface TapAppViewComponent : NSObject

-(void)setup;
-(void)setupAnimate;

@property (nonatomic,assign) UIView* view;
@property (nonatomic,assign) TapAppViewComponentState state;
@property (nonatomic,copy) NSDictionary* conf;
@property (nonatomic,copy) NSDictionary* animateConf;

@end

NS_ASSUME_NONNULL_END
