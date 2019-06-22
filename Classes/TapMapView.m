#import "TapMapView.h"

@implementation TapMapView

@synthesize conf;

- (id)initWithParent:(TapWebView*)parentWebView {
    if (self = [super init]) {
        parent = parentWebView;
        [self setup];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

-(void)setup {
    map = [[MKMapView alloc] init];
    map.delegate = self;
    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;
    [self addSubview:map];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needsSetupUi" object:nil];
}

-(MKMapView*)map {
    return map;
}

-(void)clean {
    [map removeAnnotations:[map annotations]];
}

- (void)layoutSubviews {
    CGSize size = self.frame.size;
    map.frame = CGRectMake(0, 0, size.width, size.height);
}

-(void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated {
    [map setRegion:region animated:animated];
}

-(void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [map setCenterCoordinate:coordinate animated:animated];
}

-(MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region {
    return [map regionThatFits:region];
}

-(void)addAnnotation:(id<MKAnnotation>)annotation {
    [map addAnnotation:annotation];
}

@end
