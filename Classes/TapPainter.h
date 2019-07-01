#import "TapView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PointType) { Standard, Coalesced, Predicted, NeedsUpdate, Updated, Cancelled, Finger };

@interface Line : NSObject {
    NSMutableArray *points;
    NSMutableArray *pointsWaitingForUpdatesByEstimationIndex;
    NSMutableArray *committedPoints;
    UIColor* lineColor;
    int lineSize;
}

- (NSMutableArray*)points;
- (CGRect)removePointsWithType:(PointType)type;
- (CGRect)addPointOfType:(PointType)type forTouch:(UITouch *)touch;
- (void)drawInContext:(CGContextRef)context;
- (id)initWithColor:(UIColor*)color size:(int)n;

@end

@interface LinePoint : NSObject {
    PointType pointType;
    CGPoint location;
    CGPoint preciseLocation;
    CGFloat magnitude;
    CGFloat force;
    NSNumber *estimationUpdateIndex;
    NSInteger sequenceNumber;
    UITouchType type;
}
- (id)initWithTouch:(UITouch *)touch sequenceNumber:(NSInteger)sequenceNumber pointType:(PointType)pointType;

@property PointType pointType;
@property CGPoint location;
@property CGPoint preciseLocation;
@property CGFloat magnitude;
@property CGFloat force;
@property NSNumber *estimationUpdateIndex;
@property NSInteger sequenceNumber;
@property UITouchType type;

@end


@interface Painter : TapView {
    NSMutableArray *lines;
    NSMutableArray *finishedLines;
    NSMapTable *activeLines;
    NSMapTable *pendingLines;
    UIColor* lineColor;
    int lineSize;
}

- (void)clear;

@property UIColor* lineColor;
@property int lineSize;

@end

@interface TapPainter : TapView {
    Painter* painter;
}

- (Painter*)painter;

@end

NS_ASSUME_NONNULL_END
