#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TapCamera : UIView<AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession* session;
    AVCaptureVideoPreviewLayer *previewLayer;
}

-(void)on;
-(void)off;

@end
