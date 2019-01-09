#import "TogoApp.h"
#import "TogoController.h"
#import "TogoView.h"
#import "TogoWebController.h"
#import "UIColor+Expanded.h"
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>

/***************************************************************
 ** TogoNavigationController ***********************************
 ***************************************************************/

@implementation TogoNavigationController

- (BOOL)shouldAutorotate {
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

@end

/***************************************************************
 ** TogoController *********************************************
 ***************************************************************/

@implementation TogoController

@synthesize info, data;

- (id)initWithDictionary:(NSDictionary *)dictionary {
  if (self = [super init]) {
    self.info = dictionary;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  TogoControllerView *controllerView = [[TogoControllerView alloc] init];
  self.view = controllerView;
  self.view.backgroundColor = [[TogoApp sharedInstance] confColor:@"windowBgColor"];
  self.view.window.backgroundColor = [[TogoApp sharedInstance] confColor:@"windowBgColor"];
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
  [[[TogoApp sharedInstance] confColor:@"windowBgColor"] getRed:&red green:&green blue:&blue alpha:&alpha];
  spinnerBg = [[UIView alloc] init];
  spinnerBg.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
  [self.view addSubview:spinnerBg];
  spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  spinner.lineWidth = 2;
  spinner.tintColor = [[TogoApp sharedInstance] confColor:@"windowFgColor"];
  [spinnerBg addSubview:spinner];
  spinnerBg.alpha = 0;
  [self loadUi];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:@"TogoSizeChange" object:self.view];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitOn) name:@"TogoWaitOn" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitOff) name:@"TogoWaitOff" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUiAnimated) name:@"TogoNeedsSetupUi" object:nil];
  self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)waitOn {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  spinnerBg.alpha = 1;
  [UIView commitAnimations];
  [spinner startAnimating];
}

- (void)waitOff {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  spinnerBg.alpha = 0;
  [UIView commitAnimations];
  [spinner stopAnimating];
}

- (void)setupUiAnimated {
  prevUserInteractionEnabled = self.view.userInteractionEnabled;
  self.view.userInteractionEnabled = NO;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(didSetupUiAnimated)];
  [self setupUi:self.view.frame.size];
  [UIView commitAnimations];
}

- (void)didSetupUiAnimated {
  self.view.userInteractionEnabled = prevUserInteractionEnabled;
}

- (void)sizeChanged:(NSNotification *)notification {
  UIView *view = notification.object;
  [self setupUi:view.frame.size];
}

- (void)loadUi {
}

- (void)needsSetupUi {
  [self setupUi:self.view.frame.size];
}

- (void)setupUi:(CGSize)size {
  spinner.center = CGPointMake(size.width / 2, size.height / 2);
  spinnerBg.frame = CGRectMake(0, 0, size.width, size.height);
  [self performSelector:@selector(didSetupUi) withObject:nil afterDelay:0];
}

- (void)didSetupUi {
  [self.view bringSubviewToFront:spinnerBg];
}

- (BOOL)prefersStatusBarHidden {
  return [[TogoApp sharedInstance] confBoolean:@"prefersStatusBarHidden"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return [[TogoApp sharedInstance] confInt:@"preferredStatusBarStyle"];
}

@end

/***************************************************************
 ** TogoControllerView *****************************************
 ***************************************************************/

@implementation TogoControllerView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    prevFrame = CGRectZero;
  }
  return self;
}

- (void)layoutSubviews {
  if (!CGRectEqualToRect(prevFrame, self.frame)) {
    prevFrame = self.frame;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TogoSizeChange" object:self];
  }
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

@end
