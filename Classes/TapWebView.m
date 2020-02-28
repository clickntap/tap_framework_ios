#import "TapWebView.h"
#import "TapMapView.h"
#import "TapMapAnnotation.h"
#import "TapApp.h"
#import "TapUtils.h"
#import "TapWebVideoView.h"
#import "TapAppViewComponent.h"
#import "TapRemoteScreen.h"
#import "TapPainter.h"
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import <Colorkit/Colorkit.h>
#import <AFNetworking/AFNetworking.h>
#import <EventKit/EventKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <PassKit/PassKit.h>
#include <mach/mach_time.h>

@implementation WKFullScreenWebView

-(UIEdgeInsets)safeAreaInsets {
    return UIEdgeInsetsZero;
}

@end

@implementation TapWebView

@synthesize conf, photoSettings;

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
    camera = nil;
    services = [[NSMutableArray alloc] init];
    self.clipsToBounds = YES;
    viewComponents = [[NSMutableArray alloc] init];
    images = [[NSMutableDictionary alloc] init];
    webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    webViewConfiguration.allowsInlineMediaPlayback = true;
    webViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    [webViewConfiguration.userContentController addScriptMessageHandler:self name:@"app"];
    webView = [[WKFullScreenWebView alloc] initWithFrame:CGRectZero configuration:webViewConfiguration];
    [self addSubview:webView];
    webView.clipsToBounds = YES;
    webView.navigationDelegate = self;
    webView.scrollView.bounces = NO;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    webView.autoresizesSubviews = true;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.alpha= 0;
    UIColor* spinnerColor = [[TapApp sharedInstance] optionAsColor:@"color"];
    UIColor* backgroundColor = [[TapApp sharedInstance] optionAsColor:@"backgroundColor"];
    UIColor* spinnerBackgroundColor = [backgroundColor colorWithAlphaComponent:0.5];
    spinnerBackground = [[UIView alloc] init];
    [self addSubview:spinnerBackground];
    spinnerBackground.backgroundColor = spinnerBackgroundColor;
    spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    spinner.lineCap = kCALineCapSquare;
    spinner.lineWidth = 1;
    spinner.tintColor = spinnerColor;
    [spinnerBackground addSubview:spinner];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    //    [webView.scrollView addGestureRecognizer:swipeLeft];
    //    [webView.scrollView addGestureRecognizer:swipeRight];
    //    [webView.scrollView addGestureRecognizer:swipeUp];
    //    [webView.scrollView addGestureRecognizer:swipeDown];
    //    [self addGestureRecognizer:swipeLeft];
    //    [self addGestureRecognizer:swipeRight];
    //    [self addGestureRecognizer:swipeUp];
    //    [self addGestureRecognizer:swipeDown];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(js:) name:@"js" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewComponentRemove:) name:@"viewComponentRemove" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraMetadataObject:) name:@"cameraMetadataObject" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteScreenTouch:) name:@"remoteScreenTouch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(painterChanged) name:@"painterChanged" object:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error: %@", error);
}

- (void)remoteScreenTouch:(NSNotification*)notification {
    NSDictionary* touch = notification.object;
    if(appPeerID != nil) {
        NSData* messageData = [[TapUtils json:touch] dataUsingEncoding:NSUTF8StringEncoding];
        [mcSession sendData:messageData toPeers:@[appPeerID] withMode:MCSessionSendDataReliable error:nil];
    }
}

- (void)painterChanged {
    TapPainter* painter = nil;
    TapRemoteScreen* remoteScreen = nil;
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
            painter = (TapPainter *)viewComponent.view;
        }
        if([viewComponent.conf[@"component"] isEqualToString:@"remote-screen"]) {
            remoteScreen = (TapRemoteScreen *)viewComponent.view;
        }
    }
    if(painter != nil && remoteScreen != nil) {
        [self safePainterUploadImage];
    }
    [self js:@"appPainterChanged()"];
}

-(void)safePainterUploadImage {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(painterUploadImage) withObject:nil afterDelay:0.5];
}

-(void)painterUploadImage {
    TapPainter* painter = nil;
    TapRemoteScreen* remoteScreen = nil;
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
            painter = (TapPainter *)viewComponent.view;
        }
        if([viewComponent.conf[@"component"] isEqualToString:@"remote-screen"]) {
            remoteScreen = (TapRemoteScreen *)viewComponent.view;
        }
    }
    UIImage* image = [painter grab];
    [remoteScreen performSelectorOnMainThread:@selector(uploadImage:) withObject:image waitUntilDone:NO];
}

- (void)swipeLeft {
    if(parent) {
        [parent js:@"appSwipeLeft()"];
    } else {
        [self js:@"appSwipeLeft()"];
    }
}

- (void)swipeRight {
    if(parent) {
        [parent js:@"appSwipeRight()"];
    } else {
        [self js:@"appSwipeRight()"];
    }
}

- (void)swipeUp {
    if(parent) {
        [parent js:@"appSwipeUp()"];
    } else {
        [self js:@"appSwipeUp()"];
    }
}

- (void)swipeDown {
    if(parent) {
        [parent js:@"appSwipeDown()"];
    } else {
        [self js:@"appSwipeDown()"];
    }
}

- (void)layoutSubviews {
    CGSize size = self.frame.size;
    webView.frame = CGRectMake(0, 0, size.width, size.height);
    spinner.center = CGPointMake(size.width / 2, size.height / 2);
    spinnerBackground.frame = CGRectMake(0, 0, size.width, size.height);
    if(camera != nil) {
        camera.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if(conf != nil) {
        if(conf[@"idle"] != nil) {
            [self runIdle];
        }
        if(conf[@"eval"] != nil) {
            [self runEval];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needsSetupUi" object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0];
}

-(void)show {
    [self waitOff];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    webView.alpha = 1;
    [UIView commitAnimations];
}

-(void)runIdle {
    for(NSString* js in conf[@"idle"]) {
        [self js:js];
    }
    [self performSelector:@selector(runIdle) withObject:nil afterDelay:0.5];
}

-(void)runEval {
    for(NSString* js in conf[@"eval"]) {
        [self js:js];
    }
}

- (void)js:(NSString*)code {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self->webView evaluateJavaScript:code completionHandler:^(id result, NSError *error) {}];
    }];
}

- (void)broadcastjs:(NSString*)code {
    //NSLog(@"%@", code);
    [self js:code];
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if([viewComponent.conf[@"component"] isEqualToString:@"app"]) {
            [(TapWebView*)viewComponent.view broadcastjs:code];
        }
    }
}

-(void)clearViewComponents {
    NSMutableArray* offViewComponents = [[NSMutableArray alloc] init];
    for(TapAppViewComponent* viewComponent in viewComponents) {
        [viewComponent.view removeFromSuperview];
        [offViewComponents addObject:viewComponent];
        if([viewComponent.view isKindOfClass:[TapWebView class]]) {
            [((TapWebView*)viewComponent.view) close];
        }
    }
    [viewComponents removeObjectsInArray:offViewComponents];
}

- (void)close {
    [self clearViewComponents];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [webViewConfiguration.userContentController removeScriptMessageHandlerForName:@"app"];
}

- (void)viewComponentRemove:(NSNotification*)notification {
    NSMutableArray* offViewComponents = [[NSMutableArray alloc] init];
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if(viewComponent.view == notification.object) {
            [viewComponent.view removeFromSuperview];
            if([viewComponent.view isKindOfClass:[TapWebView class]]) {
                [((TapWebView*)viewComponent.view) close];
            }
            [offViewComponents addObject:viewComponent];
        }
    }
    [viewComponents removeObjectsInArray:offViewComponents];
}

-(void)enablePushNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted) {
            //NSLog(@"push granted:%@ error:%@", granted?@"YES":@"NO",  error);
        }
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  {
    if(response.notification.request.content.userInfo) {
        NSString* js = [NSString stringWithFormat:@"appPushNotification(%@)", [TapUtils json:response.notification.request.content.userInfo ]];
        [self js:js];
    }
    completionHandler();
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary:message.body];
    NSLog(@"%@", data);
    if([@"context" compare:data[@"what"]] == NSOrderedSame) {
        long deviceId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceId"] longValue];
        long userId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] longValue];
        [[NSUserDefaults standardUserDefaults] setObject:data[@"url"] forKey:@"appEndpoint"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"ios" forKey:@"channel"];
        [parameters setObject:[NSNumber numberWithLong:deviceId] forKey:@"deviceId"];
        [parameters setObject:[NSNumber numberWithLong:userId] forKey:@"userId"];
        NSString* urlAsString = [NSString stringWithFormat:@"%@", data[@"url"]];
        NSLog(@"%@", parameters);
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlAsString parameters:parameters error:nil];
        NSURLSessionDataTask *dataTask = [[self afmanager] dataTaskWithRequest:request uploadProgress:^(NSProgress * uploadProgress) {
        } downloadProgress:^(NSProgress * downloadProgress) {
        } completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
            NSLog(@"%@", responseObject);
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"deviceId"] forKey:@"deviceId"];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"userId"] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setEnv:data[@"callback"]];
        }];
        [dataTask resume];
    }
    if([@"env" compare:data[@"what"]] == NSOrderedSame) {
        long appId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appId"] longValue];
        [[NSUserDefaults standardUserDefaults] setObject:data[@"url"] forKey:@"appEndpoint"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(appId == 0) {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:@"ios" forKey:@"channel"];
            NSString* urlAsString = [NSString stringWithFormat:@"%@add", data[@"url"]];
            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlAsString parameters:parameters error:nil];
            NSURLSessionDataTask *dataTask = [[self afmanager] dataTaskWithRequest:request uploadProgress:^(NSProgress * uploadProgress) {
            } downloadProgress:^(NSProgress * downloadProgress) {
            } completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"id"] forKey:@"appId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self setEnv:data[@"callback"]];
            }];
            [dataTask resume];
        } else {
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:@"ios" forKey:@"channel"];
            NSString* urlAsString = [NSString stringWithFormat:@"%@%ld", data[@"url"], appId];
            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlAsString parameters:parameters error:nil];
            NSURLSessionDataTask *dataTask = [[self afmanager] dataTaskWithRequest:request uploadProgress:^(NSProgress * uploadProgress) {
            } downloadProgress:^(NSProgress * downloadProgress) {
            } completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"id"] forKey:@"appId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self setEnv:data[@"callback"]];
            }];
            [dataTask resume];
        }
    }
    if([@"camera-on" compare:data[@"what"]] == NSOrderedSame) {
        [self cameraOn];
    }
    if([@"camera-off" compare:data[@"what"]] == NSOrderedSame) {
        [self cameraOff];
    }
    if([@"resource-image" compare:data[@"what"]] == NSOrderedSame) {
        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:[NSString stringWithFormat:@"%@", data[@"base64"]] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage* image = [UIImage imageWithData:imageData scale:1.0f/[data[@"scale"] floatValue]];
        [images setObject:image forKey:data[@"name"]];
    }
    if([@"facebook-logout" compare:data[@"what"]] == NSOrderedSame) {
        FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        [self facebookDidLogOut];
    }
    if([@"facebook-login" compare:data[@"what"]] == NSOrderedSame) {
        //        FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
        //        [loginManager logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:[[TapApp sharedInstance] navigationController] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        //            [self facebookDidLogIn:result];
        //        }];
    }
    if([@"offline" compare:data[@"what"]] == NSOrderedSame) {
        NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
        NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [TapUtils md5:[NSString stringWithFormat:@"%@", data[@"url"]]], data[@"extension"]]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
        if(!fileExists) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", data[@"url"]]]];
            NSURLSessionDownloadTask* downloadTask = [[self afmanager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
            } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return fileURL;
            } completionHandler:^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
                [self offline:fileURL data:data];
            }];
            [downloadTask resume];
        } else {
            [self offline:fileURL data:data];
        }
    }
    if([@"scroll" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            CGRect frame = viewComponent.view.frame;
            frame.origin.y = [viewComponent.conf[@"y"] intValue]-[data[@"y"] intValue];
            viewComponent.view.frame = frame;
        }
    }
    if([@"need" compare:data[@"what"]] == NSOrderedSame) {
        if([@"push" compare:data[@"type"]] == NSOrderedSame) {
            [self enablePushNotifications];
        }
        if([@"location" compare:data[@"type"]] == NSOrderedSame) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            [locationManager requestWhenInUseAuthorization];
            [locationManager startUpdatingLocation];
        }
        if([@"camera" compare:data[@"type"]] == NSOrderedSame) {
            if(camera == nil) {
                camera = [[TapCamera alloc] init];
                [self addSubview:camera];
                [self sendSubviewToBack:camera];
                camera.alpha = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needsSetupUi" object:nil];
            }
        }
        if([@"proximity" compare:data[@"type"]] == NSOrderedSame) {
            peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
            mcSession = [[MCSession alloc] initWithPeer:peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
            mcSession.delegate = self;
        }
        if([@"bonjour" compare:data[@"type"]] == NSOrderedSame) {
            serviceBrowser = [[NSNetServiceBrowser alloc] init];
            serviceBrowser.delegate = self;
            [serviceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@""];
        }
    }
    if([@"set" compare:data[@"what"]] == NSOrderedSame) {
        [[NSUserDefaults standardUserDefaults] setObject:data[@"value"] forKey:data[@"name"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if([@"unset" compare:data[@"what"]] == NSOrderedSame) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:data[@"name"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if([@"get" compare:data[@"what"]] == NSOrderedSame) {
        NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
        NSString* value = [[NSUserDefaults standardUserDefaults] objectForKey:data[@"name"]];
        if(value) {
            [response setObject:value forKey:data[@"name"]];
            NSError* error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:(NSJSONWritingOptions)0 error:&error];
            NSString* js = [NSString stringWithFormat:@"{ var json = %@; %@(json['%@']) }", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], data[@"callback"], data[@"name"]];
            [self js:js];
        } else {
            [self js:[NSString stringWithFormat:@"%@()", data[@"callback"]]];
        }
    }
    if([@"dialog-edit" compare:data[@"what"]] == NSOrderedSame) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: nil message: data[@"message"] preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = data[@"placeholder"];
            textField.text = data[@"text"];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alert.textFields;
            UITextField * namefield = textfields[0];
            NSString* value = namefield.text;
            [data setValue:value forKey:@"value"];
            [self js:[NSString stringWithFormat:@"appDialogEdit(%@)", [TapUtils json:data]]];
        }]];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annulla" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [self js:[NSString stringWithFormat:@"appDialogEditCancel(%@)", [TapUtils json:data]]];
        }];
        [alert addAction:cancelAction];
        [[[TapApp sharedInstance] navigationController] presentViewController:alert animated:YES completion:nil];
    }
    if([@"http-get" compare:data[@"what"]] == NSOrderedSame || [@"http-post" compare:data[@"what"]] == NSOrderedSame) {
        if(data[@"mode"] == nil || [@"background" compare:data[@"mode"]] != NSOrderedSame) {
            [self waitOn];
        }
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        if([data[@"params"] isKindOfClass:[NSArray class]]) {
            for(NSDictionary* param in data[@"params"]) {
                [parameters setObject:param[@"value"] forKey:param[@"name"]];
            }
        } else {
            [parameters addEntriesFromDictionary:data[@"params"]];
        }
        NSMutableURLRequest *request = nil;
        if([@"http-get" compare:data[@"what"]] == NSOrderedSame) {
            request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:data[@"url"] parameters:parameters error:nil];
        }
        if([@"http-post" compare:data[@"what"]] == NSOrderedSame) {
            request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:data[@"url"] parameters:parameters error:nil];
        }
        [request setTimeoutInterval:10];
        [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *dataTask = [[self afmanager] dataTaskWithRequest:request uploadProgress:^(NSProgress * uploadProgress) {
        } downloadProgress:^(NSProgress * downloadProgress) {
        } completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
            NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
            NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [TapUtils md5:[NSString stringWithFormat:@"%@", data[@"url"]]]]];
            if(error == nil && responseObject != nil) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:(NSJSONWritingOptions)0 error:&error];
                [jsonData writeToURL:fileURL atomically:YES];
                NSString* js = [NSString stringWithFormat:@"%@(%@)", data[@"callback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                [self js:js];
            } else {
                NSData *jsonData = nil;
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
                if(fileExists) {
                    jsonData = [NSData dataWithContentsOfURL:fileURL];
                } else {
                    NSMutableDictionary* errorResponse = [[NSMutableDictionary alloc] init];
                    [errorResponse setObject:error.description forKey:@"error"];
                    jsonData = [NSJSONSerialization dataWithJSONObject:errorResponse options:(NSJSONWritingOptions)0 error:&error];
                }
                NSString* js = [NSString stringWithFormat:@"%@(%@)", data[@"callback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                [self js:js];
            }
            if(data[@"mode"] == nil || [@"background" compare:data[@"mode"]] == NSOrderedSame) {
                [self waitOff];
            }
        }];
        [dataTask resume];
    }
    if([@"wait-on" compare:data[@"what"]] == NSOrderedSame) {
        [self waitOn];
    }
    if([@"wait-off" compare:data[@"what"]] == NSOrderedSame) {
        [self waitOff];
    }
    if([@"voice" compare:data[@"what"]] == NSOrderedSame) {
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:data[@"text"]];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:data[@"language"]];
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        [synth speakUtterance:utterance];
    }
    if([@"snapshot" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:data[@"component"]] && [viewComponent.conf[@"component"] isEqualToString:@"webvideo"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapWebVideoView * videoView = (TapWebVideoView *)viewComponent.view;
                    [videoView snapshot];
                }
            }
        }
    }
    if([@"map-clean" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"map"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"mapId"] longValue]) {
                    TapMapView * mapView = (TapMapView *)viewComponent.view;
                    [mapView clean];
                }
            }
        }
    }
    if([@"map-pos" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"map"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"mapId"] longValue]) {
                    TapMapView * mapView = (TapMapView *)viewComponent.view;
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [data[@"lat"] floatValue];
                    coordinate.longitude = [data[@"lng"] floatValue];
                    BOOL animated = [data[@"animated"] intValue] == 1;
                    if(data[@"radius"] != nil) {
                        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, [data[@"radius"] intValue], [data[@"radius"] intValue]);
                        [mapView setRegion:[mapView regionThatFits:viewRegion] animated:animated];
                    } else {
                        [mapView setCenter:coordinate animated:animated];
                    }
                }
            }
        }
    }
    if([@"map-poi" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"map"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"mapId"] longValue]) {
                    TapMapView * mapView = (TapMapView *)viewComponent.view;
                    TapMapAnnotation* annotation = [[TapMapAnnotation alloc] init];
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [data[@"lat"] floatValue];
                    coordinate.longitude = [data[@"lng"] floatValue];
                    annotation.coordinate = coordinate;
                    annotation.title = data[@"title"];
                    annotation.subtitle = data[@"subtitle"];
                    annotation.info = data;
                    [mapView addAnnotation:annotation];
                }
            }
        }
    }
    if([@"painter-color" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapPainter * painter = (TapPainter *)viewComponent.view;
                    [painter painter].lineColor = [UIColor colorWithHexString:data[@"color"]];
                    NSLog(@"%@", [painter painter].lineColor);
                }
            }
        }
    }
    if([@"painter-size" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapPainter * painter = (TapPainter *)viewComponent.view;
                    [painter painter].lineSize = [data[@"size"] intValue];
                    NSLog(@"%d", [painter painter].lineSize);
                }
            }
        }
    }
    if([@"painter-clear" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapPainter * painter = (TapPainter *)viewComponent.view;
                    [[painter painter] clear];
                }
            }
        }
    }
    if([@"painter-on" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapPainter * painter = (TapPainter *)viewComponent.view;
                    painter.userInteractionEnabled = YES;
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    painter.alpha = 1;
                    [UIView commitAnimations];
                }
            }
        }
    }
    if([@"painter-off" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"painter"]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    TapPainter * painter = (TapPainter *)viewComponent.view;
                    painter.userInteractionEnabled = NO;
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    painter.alpha = 0.2;
                    [UIView commitAnimations];
                }
            }
        }
    }
    if([@"painter-changed" compare:data[@"what"]] == NSOrderedSame) {
        [self painterChanged];
    }
    if([@"remote-screen" compare:data[@"what"]] == NSOrderedSame) {
        TapAppViewComponent* theViewComponent = nil;
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"remote-screen"]) {
                theViewComponent = viewComponent;
                break;
            }
        }
        if(theViewComponent != nil) {
            TapRemoteScreen* remoteScreen = (TapRemoteScreen*)theViewComponent.view;
            [remoteScreen setIp:data[@"ip"] port:[data[@"port"] intValue] impl:data[@"impl"]];
        }
        
    }
    if([@"remote-screen-lock" compare:data[@"what"]] == NSOrderedSame) {
        TapAppViewComponent* theViewComponent = nil;
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"remote-screen"]) {
                theViewComponent = viewComponent;
                break;
            }
        }
        if(theViewComponent != nil) {
            TapRemoteScreen* remoteScreen = (TapRemoteScreen*)theViewComponent.view;
            [remoteScreen lock];
        }
        
    }
    if([@"remote-screen-unlock" compare:data[@"what"]] == NSOrderedSame) {
        TapAppViewComponent* theViewComponent = nil;
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:@"remote-screen"]) {
                theViewComponent = viewComponent;
                break;
            }
        }
        if(theViewComponent != nil) {
            TapRemoteScreen* remoteScreen = (TapRemoteScreen*)theViewComponent.view;
            [remoteScreen unlock];
        }
        
    }
    if([@"animate" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:data[@"component"]]) {
                if([viewComponent.conf[@"id"] longValue] == [data[@"id"] longValue]) {
                    viewComponent.animateConf = data;
                    [viewComponent setupAnimate];
                }
            }
        }
    }
    if([@"native-begin" compare:data[@"what"]] == NSOrderedSame) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            viewComponent.state = TapAppViewComponentStateOff;
            if([viewComponent.conf[@"noFade"] intValue] == 0) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                viewComponent.view.alpha = 0;
                [UIView commitAnimations];
            }
        }
    }
    if([@"native" compare:data[@"what"]] == NSOrderedSame) {
        NSDictionary* conf = data[@"conf"];
        TapAppViewComponent* theViewComponent = nil;
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.conf[@"component"] isEqualToString:conf[@"component"]]) {
                if([viewComponent.conf[@"id"] longValue] == [conf[@"id"] longValue]) {
                    theViewComponent = viewComponent;
                }
            }
        }
        if(theViewComponent == nil) {
            UIView* view = nil;
            if([@"web" isEqualToString:conf[@"component"]] || [@"webvideo" isEqualToString:conf[@"component"]]) {
                if([@"webvideo" isEqualToString:conf[@"component"]]) {
                    view = [[TapWebVideoView alloc] initWithParent:self];
                } else {
                    view = [[TapWebView alloc] initWithParent:self];
                }
                ((TapWebView*)view).conf = conf;
                [(TapWebView*)view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:conf[@"src"]]]];
            }
            if([@"view" isEqualToString:conf[@"component"]]) {
                view = [[UIButton alloc] init];
                UIColor* backgroundColor = [UIColor colorWithRed:[conf[@"r"] floatValue] green:[conf[@"g"] floatValue] blue:[conf[@"b"] floatValue] alpha:[conf[@"a"] floatValue]];
                [view setBackgroundColor:backgroundColor];
                [(UIButton*)view addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            if([@"app" isEqualToString:conf[@"component"]]) {
                view = [[TapWebView alloc] initWithParent:self];
                if(parent == nil) {
                    if([[[TapApp sharedInstance] option:@"developer"] intValue] == 1) {
                        [(TapWebView*)view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?id=%@&view=%@", [[TapApp sharedInstance] option:@"baseUrl"], [[TapApp sharedInstance] option:@"projectId"], conf[@"view"] ]]]];
                    } else {
                        NSURL* fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?view=%@", [TapUtils docFileUrl:@"app.html"], conf[@"view"]]];
                        [(TapWebView*)view loadFileURL:fileUrl allowingReadAccessToURL:[TapUtils docUrl]];
                    }
                }
            }
            if([@"map" isEqualToString:conf[@"component"]]) {
                view = [[TapMapView alloc] init];
                ((TapMapView*)view).conf = conf;
                if(conf[@"center"] != nil) {
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [conf[@"center"][@"lat"] floatValue];
                    coordinate.longitude = [conf[@"center"][@"lng"] floatValue];
                    if(conf[@"center"][@"radius"] != nil) {
                        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, [conf[@"center"][@"radius"] intValue], [conf[@"center"][@"radius"] intValue]);
                        [(TapMapView*)view setRegion:viewRegion animated:NO];
                    } else {
                        [(TapMapView*)view setCenter:coordinate animated:NO];
                    }
                }
                [(TapMapView*)view map].delegate = self;
                [(TapMapView*)view map].showsUserLocation = YES;
                NSString* js = [NSString stringWithFormat:@"%@(%@)", conf[@"didLoadCallback"], [TapUtils json:conf]];
                if(parent) {
                    [parent js:js];
                } else {
                    [self js:js];
                }
            }
            if([@"remote-screen" isEqualToString:conf[@"component"]]) {
                view = [[TapRemoteScreen alloc] init];
                [view setBackgroundColor:[UIColor blackColor]];
            }
            if([@"painter" isEqualToString:conf[@"component"]]) {
                view = [[TapPainter alloc] init];
                if(conf[@"color"] != nil) {
                    [((TapPainter*)view) painter].lineColor = [UIColor colorWithHexString:conf[@"color"]];
                }
                if(conf[@"size"] != nil) {
                    [((TapPainter*)view) painter].lineSize = [conf[@"size"] intValue];
                }
            }
            if([@"facebook-login" isEqualToString:conf[@"component"]]) {
                //                view = [[FBSDKLoginButton alloc] init];
                //                ((FBSDKLoginButton*)view).readPermissions = @[@"public_profile", @"email"];
                //                ((FBSDKLoginButton*)view).delegate = self;
            }
            if(view != nil) {
                if([conf[@"radius"] intValue] != 0) {
                    view.layer.cornerRadius = [conf[@"radius"] intValue];
                    view.clipsToBounds = YES;
                }
                if(conf[@"opacity"] != nil) {
                    view.alpha = [conf[@"opacity"] floatValue];
                } else {
                    view.alpha = 0;
                }
                [self addSubview:view];
                [self bringSubviewToFront:spinnerBackground];
                for(TapAppViewComponent* viewComponent in viewComponents) {
                    if(![conf[@"component"] isEqualToString:@"app"] && ![conf[@"component"] isEqualToString:@"view"]) {
                        if([viewComponent.conf[@"component"] isEqualToString:@"app"] || [viewComponent.conf[@"component"] isEqualToString:@"view"]) {
                            [self bringSubviewToFront:viewComponent.view];
                        }
                    }
                }
                theViewComponent = [[TapAppViewComponent alloc] init];
                theViewComponent.view = view;
                theViewComponent.conf = conf;
                [viewComponents addObject:theViewComponent];
            }
        }
        if(theViewComponent != nil) {
            //        if([theViewComponent.view isKindOfClass:[MKMapView class]]) {
            //            [self mapViewDidChangeVisibleRegion:(MKMapView*)theViewComponent.view];
            //        }
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            if(conf[@"opacity"] != nil) {
                theViewComponent.view.alpha = [conf[@"opacity"] floatValue];
            } else {
                theViewComponent.view.alpha = 1;
            }
            [UIView commitAnimations];
            theViewComponent.state = TapAppViewComponentStateOn;
            theViewComponent.conf = conf;
            float x = [conf[@"x"] floatValue];
            float y = [conf[@"y"] floatValue];
            float w = [conf[@"w"] floatValue];
            float h = [conf[@"h"] floatValue];
            if(conf[@"left"] != nil) {
                x = [conf[@"left"] floatValue];
            }
            if(conf[@"top"] != nil) {
                y = [conf[@"top"] floatValue];
            }
            theViewComponent.view.frame = CGRectMake(x, y, w, h);
            [theViewComponent setup];
        }
    }
    if([@"native-end" compare:data[@"what"]] == NSOrderedSame) {
        NSMutableArray* offViewComponents = [[NSMutableArray alloc] init];
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if(viewComponent.state == TapAppViewComponentStateOff) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelegate:viewComponent.view];
                [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
                viewComponent.view.alpha = 0;
                [UIView commitAnimations];
                [offViewComponents addObject:viewComponent];
                if([viewComponent.view isKindOfClass:[TapWebView class]]) {
                    [((TapWebView*)viewComponent.view) close];
                }
            }
        }
        [viewComponents removeObjectsInArray:offViewComponents];
    }
    if([@"proximity-invite" compare:data[@"what"]] == NSOrderedSame) {
        mcAdvertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:data[@"name"] discoveryInfo:nil session:mcSession];
        [mcAdvertiserAssistant start];
    }
    if([@"proximity-find" compare:data[@"what"]] == NSOrderedSame) {
        mcBrowserViewController = [[MCBrowserViewController alloc] initWithServiceType:data[@"name"] session:mcSession];
        [mcBrowserViewController setMaximumNumberOfPeers:1];
        [mcBrowserViewController setMinimumNumberOfPeers:1];
        mcBrowserViewController.delegate = self;
        [[[TapApp sharedInstance] navigationController] presentViewController:mcBrowserViewController animated:YES completion:nil];
    }
    if([@"proximity-disconnect" compare:data[@"what"]] == NSOrderedSame) {
        if(appPeerID != nil) {
            [mcSession disconnect];
            [self disconnectPeer];
        }
    }
    if([@"proximity-message" compare:data[@"what"]] == NSOrderedSame) {
        if(appPeerID != nil) {
            NSData* messageData = [[TapUtils json:data[@"message"]] dataUsingEncoding:NSUTF8StringEncoding];
            [mcSession sendData:messageData toPeers:@[appPeerID] withMode:MCSessionSendDataReliable error:nil];
        }
    }
    if([@"confirm" compare:data[@"what"]] == NSOrderedSame) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:data[@"title"] message:data[@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:data[@"cancel"]?data[@"cancel"]:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSString* js = [NSString stringWithFormat:@"%@()", data[@"cancel-callback"]];
            [self js:js];
        }];
        [alert addAction:cancelAction];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:data[@"ok"]?data[@"ok"]:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            NSString* js = [NSString stringWithFormat:@"%@()", data[@"ok-callback"]];
            [self js:js];
        }];
        [alert addAction:okAction];
        [[[TapApp sharedInstance] navigationController]  presentViewController:alert animated:YES completion:nil];
    }
    if([@"options" compare:data[@"what"]] == NSOrderedSame) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:data[@"title"] message:data[@"message"] preferredStyle:[data[@"style"] intValue]];
        for(NSDictionary* option in data[@"options"]) {
            UIAlertAction* optionAction = [UIAlertAction actionWithTitle:option[@"text"] style:[option[@"style"] intValue] handler:^(UIAlertAction * action) {
                long index = [[alert actions] indexOfObject:action];
                NSString* js = [NSString stringWithFormat:@"%@(%ld)", data[@"callback"], index];
                [self js:js];
            }];
            [alert addAction:optionAction];
        }
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        if(IS_IPAD) {
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = webView;
            if(data[@"rect"] != nil) {
                float x = [data[@"rect"][@"x"] floatValue];
                float y = [data[@"rect"][@"y"] floatValue];
                float w = [data[@"rect"][@"w"] floatValue];
                float h = [data[@"rect"][@"h"] floatValue];
                popPresenter.sourceRect = CGRectMake(x, y, w, h);
            }
            [[[TapApp sharedInstance] navigationController] presentViewController:alert animated:YES completion:nil];
        } else {
            [[[TapApp sharedInstance] navigationController]  presentViewController:alert animated:YES completion:nil];
        }
    }
    if([@"alert" compare:data[@"what"]] == NSOrderedSame) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:data[@"title"] message:data[@"message"] preferredStyle:[data[@"style"] intValue]];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:data[@"ok"]?data[@"ok"]:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        }];
        [alert addAction:okAction];
        if(IS_IPAD) {
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = self;
            if(data[@"rect"] != nil) {
                float x = [data[@"rect"][@"x"] floatValue];
                float y = [data[@"rect"][@"y"] floatValue];
                float w = [data[@"rect"][@"w"] floatValue];
                float h = [data[@"rect"][@"h"] floatValue];
                popPresenter.sourceRect = CGRectMake(x, y, w, h);
            }
            [[[TapApp sharedInstance] navigationController]  presentViewController:alert animated:YES completion:nil];
        } else {
            [[[TapApp sharedInstance] navigationController]  presentViewController:alert animated:YES completion:nil];
        }
    }
    if([@"take-photo" compare:data[@"what"]] == NSOrderedSame) {
        self.photoSettings = data;
        [self takePhoto];
    }
    if([@"choose-photo" compare:data[@"what"]] == NSOrderedSame) {
        self.photoSettings = data;
        [self choosePhoto];
    }
    if([@"album-photo" compare:data[@"what"]] == NSOrderedSame) {
        self.photoSettings = data;
        [self albumPhoto];
    }
    if([@"save" compare:data[@"what"]] == NSOrderedSame) {
        NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
        NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [TapUtils md5:[NSString stringWithFormat:@"%@", data[@"name"]]]]];
        NSError* error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data[@"value"] options:(NSJSONWritingOptions)0 error:&error];
        [jsonData writeToURL:fileURL atomically:YES];
    }
    if([@"load" compare:data[@"what"]] == NSOrderedSame) {
        NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
        NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [TapUtils md5:[NSString stringWithFormat:@"%@", data[@"name"]]]]];
        NSData* jsonData = nil;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
        if(fileExists) {
            jsonData = [NSData dataWithContentsOfURL:fileURL];
        } else {
            NSError* error;
            NSMutableDictionary* errorResponse = [[NSMutableDictionary alloc] init];
            [errorResponse setObject:@"no data" forKey:@"error"];
            jsonData = [NSJSONSerialization dataWithJSONObject:errorResponse options:(NSJSONWritingOptions)0 error:&error];
        }
        NSString* js = [NSString stringWithFormat:@"%@(%@)", data[@"callback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        [self js:js];
    }
    if([@"log" compare:data[@"what"]] == NSOrderedSame) {
        NSLog(@"%@", data[@"log"]);
    }
    if([@"open-url" compare:data[@"what"]] == NSOrderedSame) {
        SFSafariViewController* controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:data[@"url"]]];
        if (@available(iOS 11.0, *)) {
            controller.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
        }
        controller.delegate = self;
        [[[TapApp sharedInstance] navigationController] pushViewController:controller animated:YES];
    }
    if([@"pkpass-check" compare:data[@"what"]] == NSOrderedSame) {
    }
    if([@"pkpass-add" compare:data[@"what"]] == NSOrderedSame) {
        [self waitOn];
        NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
        NSURL *fileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [TapUtils md5:[NSString stringWithFormat:@"%@", data[@"url"]]], @"pkpass"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", data[@"url"]]]];
        NSURLSessionDownloadTask* downloadTask = [[self afmanager] downloadTaskWithRequest:request progress:^(NSProgress *progress) {
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return fileURL;
        } completionHandler:^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
            [self waitOff];
            NSData* passData = [NSData dataWithContentsOfURL:fileURL];
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            PKPass * pass = [[PKPass alloc] initWithData:passData error:&error];
            if(!pass) {
                return;
            }
            PKAddPassesViewController *controller = [[PKAddPassesViewController alloc] initWithPass:pass];
            [controller setDelegate:(id)self];
            [[[TapApp sharedInstance] navigationController] pushViewController:controller animated:YES];
        }];
        [downloadTask resume];
    }
    if([@"navigator" compare:data[@"what"]] == NSOrderedSame) {
        [self openNavigator:data];
    }
    if([@"tel" compare:data[@"what"]] == NSOrderedSame) {
        [self callPhoneNumber:data[@"value"]];
    }
    if([@"mailto" compare:data[@"what"]] == NSOrderedSame) {
        [self sendmail:data[@"value"]];
    }
    if([@"calendar" compare:data[@"what"]] == NSOrderedSame) {
        EKEventStore *store = [EKEventStore new];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"js" object:[NSString stringWithFormat:@"appCalendarDenied()"]];
                return;
            }
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = data[@"title"];
            event.location = data[@"location"];
            event.startDate = [NSDate dateWithTimeIntervalSince1970:[data[@"t"] doubleValue]/1000];
            event.endDate = [event.startDate dateByAddingTimeInterval:[data[@"d"] doubleValue]];
            event.calendar = [store defaultCalendarForNewEvents];
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
            if(event.eventIdentifier != nil) {
                [self js:[NSString stringWithFormat:@"appCalendarSuccess('%@')", event.eventIdentifier]];
            } else {
                [self js:[NSString stringWithFormat:@"appCalendarFailed()"]];
            }
        }];
    }
    if([@"calendar-undo" compare:data[@"what"]] == NSOrderedSame) {
        EKEventStore *store = [EKEventStore new];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                [self js:[NSString stringWithFormat:@"appCalendarDenied()"]];
                return;
            }
            EKEvent* eventToRemove = [store eventWithIdentifier:data[@"id"]];
            if (eventToRemove) {
                NSError* error = nil;
                [store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
                if(error == nil) {
                    [self js:[NSString stringWithFormat:@"appCalendarUndoSuccess('%@')", data[@"id"]]];
                } else {
                    [self js:[NSString stringWithFormat:@"appCalendarUndoFailed('%@')", data[@"id"]]];
                }
            } else {
                [self js:[NSString stringWithFormat:@"appCalendarUndoFailed('%@')", data[@"id"]]];
            }
        }];
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected: {
            appPeerID = peerID;
            [self browserViewControllerDidFinish:mcBrowserViewController];
            NSString* js = [NSString stringWithFormat:@"appProximityConnected()"];
            [self js:js];
        } break;
        case MCSessionStateConnecting: {
            appPeerID = nil;
            NSString* js = [NSString stringWithFormat:@"appProximityConnecting()"];
            [self js:js];
            NSLog(@"MCSessionStateConnecting %@", peerID.displayName);
        } break;
        case MCSessionStateNotConnected: {
            [self disconnectPeer];
            NSLog(@"MCSessionStateNotConnected %@", peerID.displayName);
        } break;
    }
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [[[TapApp sharedInstance] navigationController] dismissViewControllerAnimated:YES completion:nil];
    mcBrowserViewController.delegate = nil;
    mcBrowserViewController = nil;
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self browserViewControllerDidFinish:browserViewController];
}
//
//-(void)remoteReady {
//    if(self->appPeerID != nil) {
//        NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
//        [message setObject:@"remote-ready" forKey:@"what"];
//        NSData* messageData = [[TapUtils json:message] dataUsingEncoding:NSUTF8StringEncoding];
//        [self->mcSession sendData:messageData toPeers:@[self->appPeerID] withMode:MCSessionSendDataReliable error:nil];
//    }
//}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString* js = [NSString stringWithFormat:@"appProximityMessage(%@)", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSLog(@"%@", js);
    [self js:js];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"didReceiveStream %@", streamName);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

- (void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error {
    NSData* file = [NSData dataWithContentsOfURL:localURL];
    NSString* base64 = [file base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"%@", resourceName);
    [self js:[NSString stringWithFormat:@"appProximityResource('%@','%@')", resourceName, base64]];
}

- (void)disconnectPeer {
    appPeerID = nil;
    NSString* js = [NSString stringWithFormat:@"appProximityNotConnected()"];
    [self js:js];
}

- (void)sendmail:(NSString*)mail {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setToRecipients:[NSArray arrayWithObject:mail]];
    [[[TapApp sharedInstance] navigationController] presentViewController:picker animated:YES completion:^{
        
    }];
    picker.mailComposeDelegate = self;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[[TapApp sharedInstance] navigationController] dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)callPhoneNumber:(NSString*)phoneNumber {
    if (IDIOM == IDIOM_IPHONE) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"/" withString:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]] options:[NSDictionary dictionary] completionHandler:nil];
    }
}

- (void)openNavigator:(NSDictionary*)info {
    float lat = [[info objectForKey:@"lat"] floatValue];
    float lng = [[info objectForKey:@"lng"] floatValue];
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[info objectForKey:@"name"]];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[ currentLocationMapItem, mapItem ] launchOptions:launchOptions];
    }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [[[TapApp sharedInstance] navigationController] popViewControllerAnimated:YES];
}

-(void)takePhoto {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [[[TapApp sharedInstance] navigationController] presentViewController:picker animated:true completion:nil];
}

-(void)choosePhoto {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[[TapApp sharedInstance] navigationController] presentViewController:picker animated:true completion:nil];
}

-(void)albumPhoto {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [[[TapApp sharedInstance] navigationController] presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize newSize = CGSizeMake(([photoSettings[@"height"] floatValue]/selectedImage.scale)*selectedImage.size.width/selectedImage.size.height, [photoSettings[@"height"] floatValue]/selectedImage.scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [selectedImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self waitOn];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:self.photoSettings[@"url"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(newImage, 0.8) name:self.photoSettings[@"name"] fileName:@"photo.jpeg" mimeType:@"image/jpeg"];
        } error:nil];
        NSURLSessionUploadTask *uploadTask = [[self afmanager] uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {}
                                                                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self waitOff];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:(NSJSONWritingOptions)0 error:&error];
            NSString* js = [NSString stringWithFormat:@"%@(%@)", self.photoSettings[@"callback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
            [self js:js];
        }];
        [uploadTask resume];
    }];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [services addObject:service];
    service.delegate = self;
    [service resolveWithTimeout:10];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [result setObject:[service name] forKey:@"name"];
    [result setObject:[service hostName] forKey:@"host"];
    [result setObject:[NSNumber numberWithInteger:[service port]] forKey:@"port"];
    [self js:[NSString stringWithFormat:@"appNetServiceDidResolveAddress(%@)", [TapUtils json:result]]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* location = [locations objectAtIndex:0];
    [self js:[NSString stringWithFormat:@"appUserLocation({lat:%f,lng:%f,alt:%f})", location.coordinate.latitude, location.coordinate.longitude, location.altitude]];
}

- (void)setEnv:(NSString*)callback {
    long appId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appId"] longValue];
    long deviceId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceId"] longValue];
    long userId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] longValue];
    NSString* pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
    TapApp* app = [TapApp sharedInstance];
    NSMutableDictionary* env = [[NSMutableDictionary alloc] initWithDictionary:app.options];
    [env setObject:[NSNumber numberWithLong:appId] forKey:@"appId"];
    [env setObject:[NSNumber numberWithLong:userId] forKey:@"userId"];
    [env setObject:[NSNumber numberWithLong:deviceId] forKey:@"deviceId"];
    if(pushToken != nil) {
        [env setObject:pushToken forKey:@"pushToken"];
    }
    NSString* js = [NSString stringWithFormat:@"%@(%@)", callback, [TapUtils json:env]];
    //NSLog(@"%@", js);
    [self js:js];
}

- (void)onClick:(UIButton*)sender {
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if(viewComponent.view == sender) {
            if(parent) {
                [parent js:viewComponent.conf[@"onClick"]];
            } else {
                [self js:viewComponent.conf[@"onClick"]];
            }
        }
    }
}

- (WKNavigation *)loadRequest:(NSURLRequest *)request {
    if(parent) {
        [parent js:self.conf[@"onInit"]];
    } else {
        [self js:self.conf[@"onInit"]];
    }
    [self clearViewComponents];
    webView.alpha= 0;
    [self waitOn];
    return [webView loadRequest:request];
}

- (WKNavigation *)loadFileURL:(NSURL *)fileUrl allowingReadAccessToURL:(NSURL *)url {
    if(parent) {
        [parent js:self.conf[@"onInit"]];
    } else {
        [self js:self.conf[@"onInit"]];
    }
    [self clearViewComponents];
    webView.alpha= 0;
    [self waitOn];
    return [webView loadFileURL:fileUrl allowingReadAccessToURL:url];
}

- (void)waitOn {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedWaitOn) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedWaitOff) object:nil];
    [self performSelector:@selector(delayedWaitOn) withObject:nil afterDelay:0.25];
}

- (void)waitOff {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedWaitOn) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedWaitOff) object:nil];
    [self performSelector:@selector(delayedWaitOff) withObject:nil afterDelay:0.25];}

- (void)delayedWaitOn {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    spinnerBackground.alpha = 1;
    [UIView commitAnimations];
    [spinner startAnimating];
}

- (void)delayedWaitOff {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    spinnerBackground.alpha = 0;
    [UIView commitAnimations];
    [spinner stopAnimating];
}

-(void)offline:(NSURL*)localFile data:(NSDictionary*)data {
    NSString* fileName = [localFile lastPathComponent];
    if([[[TapApp sharedInstance] option:@"developer"] intValue] == 1) {
        NSData* file = [NSData dataWithContentsOfURL:localFile];
        NSString* base64 = [file base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        if([@"background" isEqualToString:data[@"attribute"]]) {
            [self js:[NSString stringWithFormat:@"$('[id=%@]').css('background-image','url(data:%@;base64,%@)')", data[@"id"], data[@"type"], base64]];
        }
        if([@"src" isEqualToString:data[@"attribute"]]) {
            [self js:[NSString stringWithFormat:@"$('[id=%@]').attr('src','data:%@;base64,%@')", data[@"id"], data[@"type"], base64]];
        }
    } else {
        if([@"background" isEqualToString:data[@"attribute"]]) {
            [self js:[NSString stringWithFormat:@"$('[id=%@]').css('background-image','url(%@)')", data[@"id"], fileName]];
        }
        if([@"src" isEqualToString:data[@"attribute"]]) {
            [self js:[NSString stringWithFormat:@"$('[id=%@]').attr('src','%@')", data[@"id"], fileName]];
        }
        [self js:[NSString stringWithFormat:@"appImage('%@','%@')", data[@"id"], fileName]];
    }
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    [self facebookDidLogIn:result];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self facebookDidLogOut];
}

-(void)facebookDidLogIn:(FBSDKLoginManagerLoginResult *)result {
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"id,about,birthday,email,gender,first_name,last_name,picture" forKey:@"fields"];
    FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        [self js:[NSString stringWithFormat:@"facebookLogIn(%@)", [TapUtils json:result]]];
    }];
}

-(void)facebookDidLogOut {
    [self js:@"facebookLogOut()"];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if([annotation isKindOfClass:[TapMapAnnotation class]]) {
        TapMapAnnotation* appAnnotation = (TapMapAnnotation*)annotation;
        MKAnnotationView* pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%@_%@", appAnnotation.info[@"type"], appAnnotation.info[@"id"]]];
        pin.alpha = 0;
        pin.highlighted = NO;
        pin.canShowCallout = YES;
        pin.image = [images objectForKey:appAnnotation.info[@"icon"]];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        pin.alpha = 1;
        [UIView commitAnimations];
        return pin;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view.annotation isKindOfClass:[TapMapAnnotation class]]) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.view isKindOfClass:[TapMapView class]]) {
                if([(TapMapView*)viewComponent.view map] == mapView) {
                    TapMapAnnotation* appAnnotation = (TapMapAnnotation*)view.annotation;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:appAnnotation.info options:(NSJSONWritingOptions)0 error:nil];
                    NSString* js = [NSString stringWithFormat:@"%@(%@, %@)", viewComponent.conf[@"didSelectCallback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], viewComponent.conf[@"id"]];
                    [self js:js];
                }
            }
        }
    }
    if([view.annotation isKindOfClass:[MKUserLocation class]]) {
        for(TapAppViewComponent* viewComponent in viewComponents) {
            if([viewComponent.view isKindOfClass:[TapMapView class]]) {
                if([(TapMapView*)viewComponent.view map] == mapView) {
                    NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
                    [response setObject:[NSNumber numberWithFloat:mapView.userLocation.location.coordinate.latitude] forKey:@"lat"];
                    [response setObject:[NSNumber numberWithFloat:mapView.userLocation.location.coordinate.longitude] forKey:@"lng"];
                    [response setObject:[NSNumber numberWithFloat:mapView.userLocation.location.altitude] forKey:@"alt"];
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:(NSJSONWritingOptions)0 error:nil];
                    NSString* js = [NSString stringWithFormat:@"%@(%@, %@)", viewComponent.conf[@"didSelectCallback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], viewComponent.conf[@"id"]];
                    [self js:js];
                }
            }
        }
    }
}

- (void)mapViewDidChangeVisibleRegion:(MKMapView *)mapView {
    for(TapAppViewComponent* viewComponent in viewComponents) {
        if([viewComponent.view isKindOfClass:[TapMapView class]]) {
            if([(TapMapView*)viewComponent.view map] == mapView) {
                NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
                [data setObject:[NSNumber numberWithFloat:[mapView region].center.latitude] forKey:@"lat"];
                [data setObject:[NSNumber numberWithFloat:[mapView region].center.longitude] forKey:@"lng"];
                [data setObject:[NSNumber numberWithFloat:[mapView region].span.latitudeDelta] forKey:@"latDelta"];
                [data setObject:[NSNumber numberWithFloat:[mapView region].span.longitudeDelta] forKey:@"lngDelta"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:(NSJSONWritingOptions)0 error:nil];
                NSString* js = [NSString stringWithFormat:@"%@(%@, %@)", viewComponent.conf[@"didChangeCallback"], [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], viewComponent.conf[@"id"]];
                [self js:js];
            }
        }
    }
}

- (void)cameraOn {
    if(camera != nil) {
        [camera on];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        camera.alpha = 1;
        [UIView commitAnimations];
        [spinner startAnimating];
    }
}

- (void)cameraOff {
    if(camera != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:camera];
        [UIView setAnimationDidStopSelector:@selector(off)];
        camera.alpha = 0;
        [UIView commitAnimations];
        [spinner stopAnimating];
    }
}

- (void)cameraMetadataObject:(NSNotification*)  notification {
    NSError* error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notification.object options:(NSJSONWritingOptions)0 error:&error];
    if(!error) {
        NSString* js = [NSString stringWithFormat:@"appCameraMetadata(%@)", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        [self js:js];
    }
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
