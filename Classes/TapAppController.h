#import "TapController.h"
#import "TapCamera.h"
#import "TapWebView.h"
#import <MapKit/MapKit.h>
#import <SafariServices/SafariServices.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UserNotifications/UserNotifications.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapAppController : TapController<MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate,MFMailComposeViewControllerDelegate> {
    TapWebView* webApp;
    MMMaterialDesignSpinner *spinner;
}

@end

NS_ASSUME_NONNULL_END
