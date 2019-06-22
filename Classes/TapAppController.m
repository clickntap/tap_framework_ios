#import "TapAppController.h"
#import "TapUtils.h"
#import "TapApp.h"
#import "TapAppViewComponent.h"
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import <Colorkit/Colorkit.h>
#import <ZipArchive/ZipArchive.h>
#import <AFNetworking/AFNetworking.h>

@implementation TapAppController

-(void)loadUi {
    [super loadUi];
    webApp = [[TapWebView alloc] init];
    [self.view addSubview:webApp];
    UIColor* backgroundColor = [[TapApp sharedInstance] optionAsColor:@"backgroundColor"];
    self.view.backgroundColor = backgroundColor;
    UIColor* spinnerColor = [[TapApp sharedInstance] optionAsColor:@"color"];
    spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    spinner.lineCap = kCALineCapSquare;
    spinner.lineWidth = 1;
    spinner.tintColor = spinnerColor;
    [self.view addSubview:spinner];
    [self resetUi];
}

- (void)resetUi {
    [spinner startAnimating];
    if([[[TapApp sharedInstance] option:@"developer"] intValue] == 1) {
        [webApp loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?id=%@", [[TapApp sharedInstance] option:@"baseUrl"], [[TapApp sharedInstance] option:@"projectId"] ]]]];
        [spinner stopAnimating];
    } else {
        [self checkUi];
    }
}

- (void)checkUi {
    NSString* url = [[TapApp sharedInstance] option:@"appUrl"];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    NSURLSessionDataTask *dataTask = [[self afmanager] dataTaskWithRequest:request uploadProgress:^(NSProgress * uploadProgress) {
    } downloadProgress:^(NSProgress * downloadProgress) {
    } completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
        if(error == nil && responseObject != nil) {
            NSString* uiArchive = [[NSUserDefaults standardUserDefaults] objectForKey:@"monoedit-ui-archive"];
            if([uiArchive isEqualToString:responseObject[@"archive"]]) {
                [self->spinner stopAnimating];
                [self->webApp loadFileURL:[TapUtils docFileUrl:@"app.html"] allowingReadAccessToURL:[TapUtils docUrl]];
           } else {
                NSURL *fileUrl = [TapUtils docFileUrl:@"ui.zip"];
                [[NSFileManager defaultManager] removeItemAtPath:[fileUrl path] error:nil];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:responseObject[@"archive"]]];
                NSURLSessionDownloadTask* downloadTask = [[self afmanager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    return fileUrl;
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    ZipArchive* zipArchive = [[ZipArchive alloc] initWithFileManager:[NSFileManager defaultManager]];
                    [zipArchive UnzipOpenFile:[filePath path]];
                    for(NSString* file in [zipArchive getZipFileContents]) {
                        NSURL *fileUrl = [TapUtils docFileUrl:file];
                        [[NSFileManager defaultManager] removeItemAtPath:[fileUrl path] error:nil];
                    }
                    [zipArchive UnzipFileTo:[[TapUtils docUrl] path] overWrite:YES];
                    [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"archive"] forKey:@"monoedit-ui-archive"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self->spinner stopAnimating];
                    [self->webApp loadFileURL:[TapUtils docFileUrl:@"app.html"] allowingReadAccessToURL:[TapUtils docUrl]];
               }];
                [downloadTask resume];
            }
        } else {
           [self->spinner stopAnimating];
           [self->webApp loadFileURL:[TapUtils docFileUrl:@"app.html"] allowingReadAccessToURL:[TapUtils docUrl]];
         }
   }];
[dataTask resume];
}

- (void)dealloc {
    [webApp close];
}

- (void)setupUi:(CGSize)size {
    [super setupUi:size];
    float safeAreaLeft = 0;
    float safeAreaTop = 0;
    float safeAreaRight = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaLeft = self.view.safeAreaInsets.left;
        safeAreaTop = self.view.safeAreaInsets.top;
        safeAreaRight = self.view.safeAreaInsets.right;
        safeAreaBottom = self.view.safeAreaInsets.bottom;
    }
    if([[[TapApp sharedInstance] option:@"fullScreen"] intValue] == 1) {
        webApp.frame = CGRectMake(0, 0, size.width, size.height);
        [webApp broadcastjs:[NSString stringWithFormat:@"appSafeArea(%f,%f,%f,%f)", safeAreaLeft,safeAreaTop, safeAreaRight, safeAreaBottom]];
    } else {
        webApp.frame = CGRectMake(0, safeAreaTop, size.width, size.height-safeAreaBottom-safeAreaTop);
        [webApp broadcastjs:[NSString stringWithFormat:@"appSafeArea(%f,%f,%f,%f)", safeAreaLeft, 0.0f, safeAreaRight, 0.0f]];
    }
    [webApp broadcastjs:[NSString stringWithFormat:@"appWindowSize(%f,%f)", size.width, size.height]];
    spinner.center = CGPointMake(size.width / 2, size.height / 2);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return ([[TapApp sharedInstance] optionAsInt:@"statusBar"] == 0) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
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

@end
