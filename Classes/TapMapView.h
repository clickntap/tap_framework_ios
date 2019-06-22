#import <MapKit/MapKit.h>
#import "TapWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapMapView : UIView<MKMapViewDelegate> {
    MKMapView* map;
    TapWebView* parent;
}

- (id)initWithParent:(TapWebView*)parentWebView;

-(void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated;
-(void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
-(MKCoordinateRegion)regionThatFits:(MKCoordinateRegion)region;
-(void)addAnnotation:(id<MKAnnotation>)annotation;
-(void)clean;
-(MKMapView*)map;

@property (nonatomic,copy) NSDictionary* conf;

@end

NS_ASSUME_NONNULL_END
