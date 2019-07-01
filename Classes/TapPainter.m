#import "TapPainter.h"

@implementation Line

- (id)initWithColor:(UIColor*)color size:(int)size {
    if (self = [super init]) {
        points = [[NSMutableArray alloc] init];
        pointsWaitingForUpdatesByEstimationIndex = [[NSMutableArray alloc] init];
        committedPoints = [[NSMutableArray alloc] init];
        lineColor = color;
        lineSize = size;
    }
    return self;
}

- (NSMutableArray*)points {
    return points;
}

- (CGRect)addPointOfType:(PointType)pointType forTouch:(UITouch *)touch {
    LinePoint *previousPoint = [points lastObject];
    NSInteger previousSequenceNumber = -1;
    if (previousPoint != nil) {
        previousSequenceNumber = [points indexOfObject:previousPoint];
    }
    LinePoint *point = [[LinePoint alloc] initWithTouch:touch sequenceNumber:previousSequenceNumber + 1 pointType:pointType];
    [points addObject:point];
    CGRect updateRect = [self updateRectForLinePoint:point optionalPreviousPoint:previousPoint];
    return updateRect;
}

- (CGRect)removePointsWithType:(PointType)type {
    CGRect updateRect = CGRectNull;
    LinePoint *priorPoint = nil;
    NSMutableArray *newPoints = [[NSMutableArray alloc] init];
    for (LinePoint *point in points) {
        if ([point pointType] != type) {
            [newPoints addObject:point];
        } else {
            CGRect rect = [self updateRectForLinePoint:point];
            if (priorPoint != nil) {
                CGRectUnion(rect, [self updateRectForLinePoint:priorPoint]);
            }
        }
        priorPoint = point;
    }
    points = [[NSMutableArray alloc] initWithArray:newPoints];
    return updateRect;
}

- (void)drawInContext:(CGContextRef)context {
    LinePoint *priorPoint = nil;
    
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    for (LinePoint *point in points) {
        if (priorPoint == nil) {
            priorPoint = point;
            continue;
        }
        CGPoint location = point.preciseLocation;
        CGPoint priorLocation = priorPoint.preciseLocation;
        CGContextMoveToPoint(context, priorLocation.x, priorLocation.y);
        CGContextAddLineToPoint(context, location.x, location.y);
        CGContextSetLineWidth(context, point.magnitude * lineSize);
        CGContextStrokePath(context);
        priorPoint = point;
    }
}

- (CGRect)updateRectForLinePoint:(LinePoint *)point {
    CGRect rect = CGRectMake(point.location.x, point.location.y, 0, 0);
    CGFloat magnitude = -5 * point.magnitude - 2;
    rect = CGRectInset(rect, magnitude, magnitude);
    return rect;
}

- (CGRect)updateRectForLinePoint:(LinePoint *)point optionalPreviousPoint:(LinePoint *)previousPoint {
    CGRect rect = CGRectMake(point.location.x, point.location.y, 0, 0);
    CGFloat pointMagnitude = point.magnitude;
    if (previousPoint != nil) {
        pointMagnitude = fmax(pointMagnitude, previousPoint.magnitude);
    }
    CGFloat magnitude = 5 * pointMagnitude - 2.0;
    rect = CGRectInset(rect, magnitude, magnitude);
    return rect;
}

- (CGRect)updateRectForExistingPoint:(LinePoint *)point {
    CGRect rect = [self updateRectForLinePoint:point];
    NSInteger arrayIndex = [points indexOfObject:point];
    if (arrayIndex > 0) {
        rect = CGRectUnion(rect, [self updateRectForLinePoint:point optionalPreviousPoint:[points objectAtIndex:arrayIndex - 1]]);
    }
    return rect;
}

@end

@implementation LinePoint

@synthesize pointType, location, magnitude, estimationUpdateIndex, sequenceNumber, type, preciseLocation, force;

- (id)initWithTouch:(UITouch *)touch sequenceNumber:(NSInteger)_sequenceNumber pointType:(PointType)_pointType {
    if (self = [super init]) {
        self.sequenceNumber = _sequenceNumber;
        self.type = touch.type;
        self.pointType = _pointType;
        self.location = [touch locationInView:[touch view]];
        self.preciseLocation = [touch preciseLocationInView:[touch view]];
        self.force = [touch force];
        self.magnitude = fmax(force * 2, 0.1);
    }
    return self;
}

@end

@implementation Painter

@synthesize lineColor;
@synthesize lineSize;

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = [UIColor whiteColor];
        self.lineSize = 1;
        [self clear];
    }
    return self;
}

- (void)undo {
    if ([lines count] > 0) {
        [lines removeLastObject];
    }
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self drawTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self drawTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self drawTouches:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

- (void)clear {
    lines = [[NSMutableArray alloc] init];
    finishedLines = [[NSMutableArray alloc] init];
    activeLines = [NSMapTable strongToStrongObjectsMapTable];
    pendingLines = [NSMapTable strongToStrongObjectsMapTable];
    [self setNeedsDisplay];
}

- (void)touchesEstimatedPropertiesUpdated:(NSSet *)touches {
}

- (void)drawTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGRect updateRect = CGRectNull;
    for (UITouch *touch in touches) {
        if(touch.maximumPossibleForce != 0) {
            Line *line = [activeLines objectForKey:touch];
            if (line == nil) {
                line = [[Line alloc] initWithColor:self.lineColor size:self.lineSize];
                [activeLines setObject:line forKey:touch];
                [lines addObject:line];
            }
            updateRect = CGRectUnion(updateRect, [line removePointsWithType:Predicted]);
            NSArray *coalescedTouches = [event coalescedTouchesForTouch:touch];
            CGRect coalescedRect = [self addPointsOfType:Coalesced forTouches:coalescedTouches line:line currentUpdateRect:updateRect];
            updateRect = CGRectUnion(updateRect, coalescedRect);
            NSArray *predictedTouches = [event predictedTouchesForTouch:touch];
            CGRect predictedRect = [self addPointsOfType:Predicted forTouches:predictedTouches line:line currentUpdateRect:updateRect];
            updateRect = CGRectUnion(updateRect, predictedRect);
        } else {
            NSMutableArray* newLines = [[NSMutableArray alloc] init];
            for(Line* line in lines) {
                BOOL skip = NO;
                for(LinePoint* point in [line points]) {
                    CGPoint p2 = point.location;
                    CGPoint p1 = [touch locationInView:self];
                    CGFloat xDist = (p2.x - p1.x);
                    CGFloat yDist = (p2.y - p1.y);
                    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
                    if(distance < 50) {
                        skip = YES;
                    }
                }
                if(!skip) {
                    [newLines addObject:line];
                }
            }
            lines = newLines;
        }
    }
    [self setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"painterChanged" object:nil];
}

- (CGRect)addPointsOfType:(PointType)type forTouches:(NSArray *)touches line:(Line *)line currentUpdateRect:(CGRect)updateRect {
    CGRect accumulatedRect = CGRectNull;
    for (int idx = 0; idx < [touches count]; idx++) {
        UITouch *touch = [touches objectAtIndex:idx];
        if (touch.type == UITouchTypeStylus) {
            accumulatedRect = CGRectUnion(accumulatedRect, [line addPointOfType:type forTouch:touch]);
        }
    }
    return CGRectUnion(accumulatedRect, updateRect);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    for (Line *line in lines) {
        [line drawInContext:context];
    }
}

@end

@implementation TapPainter

- (id)init {
    if (self = [super init]) {
        painter = [[Painter alloc] init];
        [self addSubview:painter];
    }
    return self;
}

- (void)layoutSubviews {
    if (!CGSizeEqualToSize(previousSize, self.frame.size)) {
        previousSize = self.frame.size;
        painter.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
        [painter clear];
    }
}

-(Painter*)painter {
    return painter;
}

@end
