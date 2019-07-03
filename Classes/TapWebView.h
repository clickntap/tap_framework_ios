#import "TapCamera.h"
#import <WebKit/WebKit.h>
#import <UserNotifications/UserNotifications.h>
#import <MapKit/MapKit.h>
#import <SafariServices/SafariServices.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@class MMMaterialDesignSpinner;

@interface WKFullScreenWebView : WKWebView

@end

@interface TapWebView : UIView<MCSessionDelegate, MCBrowserViewControllerDelegate, WKNavigationDelegate, WKScriptMessageHandler, UNUserNotificationCenterDelegate, FBSDKLoginButtonDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate, MFMailComposeViewControllerDelegate, GCDAsyncSocketDelegate> {
    WKWebViewConfiguration *webViewConfiguration;
    WKFullScreenWebView *webView;
    NSMutableArray* viewComponents;
    MMMaterialDesignSpinner *spinner;
    UIView *spinnerBackground;
    TapWebView* parent;
    NSMutableDictionary* images;
    CLLocationManager* locationManager;
    TapCamera* camera;
    MCPeerID*  peerID;
    MCPeerID*  appPeerID;
    MCSession*  mcSession;
    MCAdvertiserAssistant*  mcAdvertiserAssistant;
    MCBrowserViewController* mcBrowserViewController;
    GCDAsyncSocket* listenSocket;
    GCDAsyncSocket* socket;
    GCDAsyncSocket* connectedSocket;
    int listenPort;
    NSUInteger remoteImageSize;
    NSMutableData* remoteImageData;
    NSData* remoteFrame;
}

- (WKNavigation *)loadRequest:(NSURLRequest *)request;
- (WKNavigation *)loadFileURL:(NSURL *)fileUrl allowingReadAccessToURL:(NSURL *)url;
- (void)js:(NSString*)code;
- (void)broadcastjs:(NSString*)code;
- (void)show;
- (void)close;
- (void)waitOn;
- (void)waitOff;

@property (nonatomic,copy) NSDictionary* conf;
@property (nonatomic, copy) NSDictionary* photoSettings;


@end

NS_ASSUME_NONNULL_END
