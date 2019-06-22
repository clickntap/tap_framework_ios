#import "TapController.h"
#import "TapView.h"

@implementation TapController

-(void)viewDidLoad {
    [super viewDidLoad];
    TapView *controllerView = [[TapView alloc] init];
    self.view = controllerView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:@"viewSizeChanged" object:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needsSetupUi) name:@"needsSetupUi" object:nil];
    [self loadUi];
}

- (void)needsSetupUi {
    [self setupUi:self.view.frame.size];
}

- (void)sizeChanged:(NSNotification *)notification {
    [self performSelector:@selector(needsSetupUi) withObject:nil afterDelay:0];
}

- (void)loadUi {
    
}

- (void)resetUi {
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setupUi:(CGSize)size {
    float safeAreaLeft = 0;
    float safeAreaRight = 0;
    float safeAreaTop = 0;
    float safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaRight = self.view.safeAreaInsets.right;
        safeAreaLeft = self.view.safeAreaInsets.left;
        safeAreaTop = self.view.safeAreaInsets.top;
        safeAreaBottom = self.view.safeAreaInsets.bottom;
    }
}

@end
