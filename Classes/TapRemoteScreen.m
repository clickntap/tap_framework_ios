#import "TapRemoteScreen.h"

@implementation TapRemoteScreen

- (id)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        isPen = NO;
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        isPen = touch.force;
        [self touchInfo:touch type:1];
        break;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self touchInfo:touch type:2];
        break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self touchInfo:touch type:3];
        break;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self touchInfo:touch type:4];
        break;
    }
}

-(void)touchInfo:(UITouch*) touch type:(int)n {
    CGPoint touchPosition = [touch locationInView:self];
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject:[NSNumber numberWithFloat:touchPosition.x] forKey:@"x"];
    [info setObject:[NSNumber numberWithFloat:touchPosition.y] forKey:@"y"];
    [info setObject:[NSNumber numberWithFloat:self.frame.size.width] forKey:@"w"];
    [info setObject:[NSNumber numberWithFloat:self.frame.size.height] forKey:@"h"];
    [info setObject:[NSNumber numberWithInt:n] forKey:@"type"];
    [info setObject:[NSNumber numberWithBool:isPen] forKey:@"pen"];
    [info setObject:@"remote-touch" forKey:@"what"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"remoteScreenTouch" object:info];
}

@end
