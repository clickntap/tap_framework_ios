#import "TapCamera.h"

@implementation TapCamera

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        session = [[AVCaptureSession alloc] init];
        AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
        if ([session canAddInput:cameraDeviceInput]) {
            [session addInput:cameraDeviceInput];
        }
        AVCaptureMetadataOutput* cameraDeviceOutput = [[AVCaptureMetadataOutput alloc] init];
        if ([session canAddOutput:cameraDeviceOutput]) {
            [session addOutput:cameraDeviceOutput];
        }
        [cameraDeviceOutput setMetadataObjectTypes:[cameraDeviceOutput availableMetadataObjectTypes]];
        [cameraDeviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self performSelector:@selector(setup) withObject:nil afterDelay:0];
    }
    return self;
}

-(void)dealloc {
    for(AVCaptureDeviceInput* input in  [session inputs]) {
        [session removeInput:input];
    }
    for(AVCaptureMetadataOutput* output in  [session outputs]) {
        [session removeOutput:output];
    }
    [previewLayer removeFromSuperlayer];
    [previewLayer setSession:nil];
}

-(void)setup {
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer.opacity = 0.6;
    previewLayer.opaque = NO;
    [self layoutSubviews];
    [self.layer addSublayer:previewLayer];
}

-(void)on {
    [session startRunning];
}

-(void)off {
    [session stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataMachineReadableCodeObject* metadataObject in metadataObjects) {
        if([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
            [metadata setObject:[NSString stringWithFormat:@"%@", [metadataObject type]] forKey:@"type"];
            [metadata setObject:[NSString stringWithFormat:@"%@", [metadataObject stringValue]] forKey:@"string"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cameraMetadataObject" object:metadata];
        }
    }
}

- (void)layoutSubviews {
    previewLayer.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
}

@end
