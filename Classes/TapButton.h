#import <UIKit/UIKit.h>

/***************************************************************
 ** TapButtonView **********************************************
 ***************************************************************/

@interface TapButtonView : UIButton {
    NSDictionary *info;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)needsSetupUi;

@property(nonatomic, copy) NSDictionary *info;

@end

/***************************************************************
 ** TapButton **************************************************
 ***************************************************************/

@interface TapButton : TapButtonView {
    UILabel *icon;
}

- (id)initWithUnicode:(NSString *)unicode color:(UIColor *)color;
- (id)initWithUnicode:(NSString *)unicode color:(UIColor *)color size:(int)size;
- (void)update:(NSString *)unicode color:(UIColor *)color;

@end
