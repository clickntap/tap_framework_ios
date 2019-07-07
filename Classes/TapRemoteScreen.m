#import "TapRemoteScreen.h"
#import <AFNetworking/AFNetworking.h>

@implementation TapRemoteScreen

@synthesize ip, port;

- (id)init {
    if (self = [super init]) {
        //        self.userInteractionEnabled = YES;
        //        isPen = NO;
        self.clipsToBounds = YES;
        videoScreen = [[UIView alloc] init];
        np = [[NodePlayer alloc] init];
        [np setPlayerView:videoScreen];
        screen = [[UIImageView alloc] init];
        [self addSubview:videoScreen];
        [self addSubview:screen];
        screen.alpha = 0;
    }
    return self;
}

- (void)layoutSubviews {
    CGSize size = self.frame.size;
    videoScreen.frame = screen.frame = CGRectMake(0, 0, size.width, size.height);
}

-(void)setIp:(NSString*)ip port:(int)port {
    self.ip = ip;
    self.port = port;
    [np setInputUrl:[NSString stringWithFormat:@"rtsp://%@/", ip]];
    [np start];
}

-(void)lock {
    [self changeLock:YES];
}

-(void)unlock {
    [self changeLock:NO];
}

-(void)uploadImage:(UIImage*)image {
    NSString *url = [NSString stringWithFormat:@"http://%@:%d/%@", self.ip, self.port, @"upload"];
    NSLog(@"%@", url);
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:url
                                                                                             parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"image" fileName:@"image.png" mimeType:@"image/png"];
                                                                              }
                                                                                                  error:nil];
    NSURLSessionUploadTask *uploadTask = [[self afmanager] uploadTaskWithStreamedRequest:request
                                               progress:^(NSProgress *_Nonnull uploadProgress) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                   });
                                               }
                                      completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                                        }];
    [uploadTask resume];
}

-(void)changeLock:(BOOL)locked {
    NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
    NSURL *fileURL = [directory URLByAppendingPathComponent:@"remote_screen.jpg"];
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    NSString *url = [NSString stringWithFormat:@"http://%@:%d/%@", self.ip, self.port, locked?@"lock":@"unlock"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask* downloadTask = [[self afmanager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
        UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:fileURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
           if(locked) {
                self->screen.image = image;
                self->screen.alpha = 1;
            } else {
                [self performSelector:@selector(hideImage) withObject:nil afterDelay:1];
            }
        });
    }];
    [downloadTask resume];
}

-(void)hideImage {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self->screen.alpha = 0;
    [UIView commitAnimations];
}

- (AFURLSessionManager *)afmanager {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [securityPolicy setValidatesDomainName:NO];
    manager.securityPolicy = securityPolicy;
    return manager;
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        isPen = touch.force;
//        [self touchInfo:touch type:1];
//        break;
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        [self touchInfo:touch type:2];
//        break;
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        [self touchInfo:touch type:3];
//        break;
//    }
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        [self touchInfo:touch type:4];
//        break;
//    }
//}
//
//-(void)touchInfo:(UITouch*) touch type:(int)n {
//    CGPoint touchPosition = [touch locationInView:self];
//    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
//    [info setObject:[NSNumber numberWithFloat:touchPosition.x] forKey:@"x"];
//    [info setObject:[NSNumber numberWithFloat:touchPosition.y] forKey:@"y"];
//    [info setObject:[NSNumber numberWithFloat:self.frame.size.width] forKey:@"w"];
//    [info setObject:[NSNumber numberWithFloat:self.frame.size.height] forKey:@"h"];
//    [info setObject:[NSNumber numberWithInt:n] forKey:@"type"];
//    [info setObject:[NSNumber numberWithBool:isPen] forKey:@"pen"];
//    [info setObject:@"remote-touch" forKey:@"what"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"remoteScreenTouch" object:info];
//}

@end
