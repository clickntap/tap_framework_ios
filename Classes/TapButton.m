#import "TapButton.h"
#import <QuartzCore/QuartzCore.h>

/***************************************************************
 ** TapButtonView **********************************************
 ***************************************************************/

@implementation TapButtonView

@synthesize info;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.info = dictionary;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.alpha = 0.8;
    [UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)needsSetupUi {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needsSetupUi" object:nil];
}

@end

/***************************************************************
 ** TapButton **************************************************
 ***************************************************************/

@implementation TapButton

- (id)initWithUnicode:(NSString *)unicode color:(UIColor *)color {
    int size = 46;
    if (self = [self initWithUnicode:unicode color:color size:size]) {
    }
    return self;
}

- (id)initWithUnicode:(NSString *)unicode color:(UIColor *)color size:(int)size {
    if (self = [super initWithFrame:CGRectMake(0, 0, size, size)]) {
        float scale = 0.4;
        self.backgroundColor = [UIColor clearColor];
        icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        icon.backgroundColor = [UIColor clearColor];
        icon.textColor = color;
        icon.text = unicode;
        icon.textAlignment = NSTextAlignmentCenter;
        icon.font = [UIFont fontWithName:@"FontAwesome" size:size * scale];
        [self addSubview:icon];
    }
    return self;
}

- (void)update:(NSString *)unicode color:(UIColor *)color {
    icon.text = unicode;
    icon.textColor = color;
}

@end
