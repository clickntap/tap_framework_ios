#import "TapBookController.h"

@implementation TapBookController

@end
// #import "TogoApp.h"
// #import "TogoBookController.h"
// #import "TogoView.h"
// #import "TogoWebController.h"
// #import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
// #import <SDWebImage/UIImageView+WebCache.h>
//
// /***************************************************************
//  ** PdfOperation ***********************************************
//  ***************************************************************/
//
// @implementation PdfOperation
//
// @synthesize info, pageNumber, height, notificationName;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary pageNumber:(float)n height:(float)h {
//   self = [super init];
//   if (self) {
//     h = MIN(3200.0f, h);
//     height = h;
//     pageNumber = n;
//     self.info = dictionary;
//   }
//   return self;
// }
//
// - (void)main {
//   UIImage *image = nil;
//   //  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
//   //                                                       NSUserDomainMask,
//   //                                                       YES);
//   //  NSString* imagePath = [[paths objectAtIndex:0]
//   //      stringByAppendingPathComponent:
//   //          [NSString stringWithFormat:
//   //                        @"%@_%d_%d.jpg",
//   //                        [TogoUtils sha256:[self.info
//   //                        objectForKey:@"pdfUrl"]],
//   //                        pageNumber, (int)height]];
//   //  if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
//   //    image = [UIImage imageWithData:[NSData
//   //    dataWithContentsOfFile:imagePath]];
//   //  } else {
//   CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL URLWithString:[self.info objectForKey:@"pdfUrl"]]);
//   CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, pageNumber);
//   CGRect pdfPageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
//   float scale = height / pdfPageRect.size.height;
//   pdfPageRect = CGRectMake(0, 0, pdfPageRect.size.width * scale, pdfPageRect.size.height * scale);
//   UIGraphicsBeginImageContext(pdfPageRect.size);
//   CGContextRef context = UIGraphicsGetCurrentContext();
//   CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//   CGContextFillRect(context, pdfPageRect);
//   CGContextSaveGState(context);
//   CGContextTranslateCTM(context, 0.0, pdfPageRect.size.height);
//   CGContextScaleCTM(context, 1.0, -1.0);
//   CGContextScaleCTM(context, scale, scale);
//   CGContextDrawPDFPage(context, pdfPage);
//   CGContextRestoreGState(context);
//   image = UIGraphicsGetImageFromCurrentImageContext();
//   UIGraphicsEndImageContext();
//   CGPDFDocumentRelease(pdf);
//   //  }
//   pdfWidth = image.size.width;
//   pdfHeight = image.size.height;
//   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
//   [userInfo setObject:[NSString stringWithFormat:@"%d", pageNumber] forKey:@"pageNumber"];
//   [userInfo setObject:[NSString stringWithFormat:@"%f", pdfWidth] forKey:@"width"];
//   [userInfo setObject:[NSString stringWithFormat:@"%f", pdfHeight] forKey:@"height"];
//   [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:image userInfo:userInfo];
// }
//
// @end
//
// /***************************************************************
//  ** PdfImageView ***********************************************
//  ***************************************************************/
//
// @implementation PdfImageView
//
// @synthesize pageNumber, width, height, zoomable;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary pageNumber:(int)n {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//     self.pageNumber = n;
//     CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL URLWithString:[self.info objectForKey:@"pdfUrl"]]);
//     CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, pageNumber);
//     CGRect pdfPageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
//     self.width = pdfPageRect.size.width;
//     self.height = pdfPageRect.size.height;
//     CGPDFDocumentRelease(pdf);
//     self.userInteractionEnabled = NO;
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingImage:) name:@"IncomingPdfImageView" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidZoom:) name:@"PageDidZoom" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageChanged:) name:@"BookPageChanged" object:nil];
//     prevSize = CGSizeZero;
//     zoomScale = 1;
//     zoomable = NO;
//     ready = NO;
//   }
//   return self;
// }
//
// - (void)pageChanged:(NSNotification *)notification {
//   //  int currentPage = [notification.object intValue];
//   // NSLog(@"currentPage: %d, page: %d", currentPage, pageNumber);
//   //  int page = pageNumber;
//   //  if(currentPage == page) {
//   //    self.alpha = 1;
//   //  } else {
//   //    self.alpha = 0.75;
//   //  }
// }
//
// - (void)incomingImage:(NSNotification *)notification {
//   if ([[notification.userInfo objectForKey:@"pageNumber"] intValue] == pageNumber) {
//     [self performSelectorOnMainThread:@selector(delayedIncomingImage:) withObject:notification.object waitUntilDone:YES];
//   }
// }
//
// - (void)delayedIncomingImage:(UIImage *)image {
//   for (UIImageView *view in [self subviews]) {
//     [view removeFromSuperview];
//   }
//   CGSize size = self.frame.size;
//   UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//   [self addSubview:imageView];
//   imageView.frame = CGRectMake(0, 0, size.width, size.height);
//   if (!ready) {
//     imageView.alpha = 0;
//     [UIView beginAnimations:nil context:nil];
//     [UIView setAnimationDuration:0.5];
//     imageView.alpha = 1;
//     [UIView commitAnimations];
//     ready = YES;
//   }
// }
//
// - (void)dealloc {
//   [[NSNotificationCenter defaultCenter] removeObserver:self];
// }
//
// - (void)pageDidZoom:(NSNotification *)notification {
//   CGSize size = self.frame.size;
//   float value = [notification.object floatValue];
//   if (value != zoomScale && zoomable) {
//     zoomScale = value;
//     PdfOperation *operation = [[PdfOperation alloc] initWithDictionary:self.info pageNumber:pageNumber height:zoomScale * size.height * (IS_RETINA ? 1.5 : 1)];
//     operation.notificationName = @"IncomingPdfImageView";
//     [[[TogoApp sharedInstance] pdfProcessingQueue] addOperation:operation];
//   }
// }
//
// - (void)layoutSubviews {
//   CGSize size = self.frame.size;
//   if (!CGSizeEqualToSize(size, prevSize)) {
//     PdfOperation *operation = [[PdfOperation alloc] initWithDictionary:self.info pageNumber:pageNumber height:zoomScale * size.height * (IS_RETINA ? 1.5 : 1)];
//     operation.notificationName = @"IncomingPdfImageView";
//     [[[TogoApp sharedInstance] pdfProcessingQueue] addOperation:operation];
//     prevSize = size;
//   }
// }
//
// @end
//
// /***************************************************************
//  ** BookExtraButton ********************************************
//  ***************************************************************/
//
// @implementation BookExtraBtn
//
// - (id)initWithDictionary:(NSDictionary *)dictionary {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//   }
//   return self;
// }
//
// - (void)layoutSubviews {
// }
//
// @end
//
// /***************************************************************
//  ** BookExtraView **********************************************
//  ***************************************************************/
//
// @implementation BookExtraView
//
// - (id)initWithView:(UIView *)stage {
//   self = [super init];
//   if (self) {
//     UIColor *color = [[TogoApp sharedInstance] confColor:@"headerBgColor"];
//     self.backgroundColor = color;
//     btnBack = [[TogoButton alloc] initWithUnicode:@"\uf00d" color:[[TogoApp sharedInstance] confColor:@"headerFgColor"]];
//     [btnBack addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//     [self addSubview:btnBack];
//     stage.tag = 1;
//     [self addSubview:stage];
//   }
//   return self;
// }
//
// - (void)goBack {
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"BookExtraViewClose" object:nil];
// }
//
// - (void)clearMe {
//   for (UIView *view in [self subviews]) {
//     [view removeFromSuperview];
//   }
// }
//
// - (void)layoutSubviews {
//   CGSize size = self.frame.size;
//   int hh = [[TogoApp sharedInstance] confInt:@"headerHeight"];
//   btnBack.frame = CGRectMake(size.width - hh, 0, hh, hh);
//   for (UIView *view in [self subviews]) {
//     if (view.tag == 1) {
//       view.frame = CGRectMake(5, hh, size.width - 10, size.height - 5 - hh);
//     }
//   }
// }
//
// @end
//
// /***************************************************************
//  ** BookPage ***************************************************
//  ***************************************************************/
//
// @implementation BookPage
//
// @synthesize pageNumber, zoomable, showed, state;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary zoomable:(BOOL)_zoomable {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//     state = BookPageSetupTypeUnknown;
//     zoomable = _zoomable;
//     showed = NO;
//     spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//     spinner.lineWidth = 0.5;
//     spinner.tintColor = [[TogoApp sharedInstance] confColor:@"windowFgColor"];
//     [self addSubview:spinner];
//     [spinner startAnimating];
//     if (zoomable) {
//       zoomContainer = [[TogoScrollView alloc] init];
//       [self addSubview:zoomContainer];
//       pageContainer = [[UIView alloc] init];
//       [zoomContainer addSubview:pageContainer];
//       zoomContainer.maximumZoomScale = 4;
//       zoomContainer.delegate = self;
//       zoomContainer.bounces = NO;
//       zoomContainer.bouncesZoom = NO;
//     }
//   }
//   return self;
// }
//
// - (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(broadcastDidZoom) object:nil];
//   [self performSelector:@selector(broadcastDidZoom) withObject:nil afterDelay:0.3];
// }
//
// - (void)broadcastDidZoom {
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"PageDidZoom" object:[NSString stringWithFormat:@"%f", zoomContainer.zoomScale]];
// }
//
// - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//   return pageContainer;
// }
//
// - (UIView *)container {
//   UIView *container = self;
//   if (zoomable) {
//     container = pageContainer;
//   }
//   return container;
// }
//
// - (void)setup:(BookPageSetupType)setupType {
//   if (zoomable) {
//     zoomContainer.zoomScale = 1;
//   }
//   if (state != setupType) {
//     [self resetUi];
//     if (setupType == BookPageSetupTypeActive) {
//       [self loadUi];
//     }
//     state = setupType;
//   }
//   [self setNeedsLayout];
// }
//
// - (void)resetUi {
// }
//
// - (void)loadUi {
// }
//
// - (void)updateUi {
//   [self setNeedsLayout];
// }
//
// - (void)setupExtras:(UIView *)superview size:(CGSize)size {
//   float ph = [[self.info objectForKey:@"h"] floatValue];
//   for (BookExtraBtn *view in [superview subviews]) {
//     if ([view isKindOfClass:[BookExtraBtn class]]) {
//       float x = [view.info[@"x"] floatValue] * size.height / ph;
//       float y = [view.info[@"y"] floatValue] * size.height / ph;
//       float w = [view.info[@"w"] floatValue] * size.height / ph;
//       float h = [view.info[@"h"] floatValue] * size.height / ph;
//       view.frame = CGRectMake(x, y, w, h);
//       if (zoomable) {
//         view.alpha = (zoomContainer.zoomScale == 1);
//       }
//     }
//   }
// }
//
// - (void)alphaExtras:(UIView *)superview {
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   for (BookExtraBtn *view in [superview subviews]) {
//     if ([view isKindOfClass:[BookExtraBtn class]]) {
//       if (zoomable) {
//         view.alpha = (zoomContainer.zoomScale == 1);
//       }
//     }
//   }
//   [UIView commitAnimations];
// }
//
// - (void)alphaExtras:(UIView *)superview alpha:(float)alpha {
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   for (BookExtraBtn *view in [superview subviews]) {
//     if ([view isKindOfClass:[BookExtraBtn class]]) {
//       view.alpha = alpha;
//     }
//   }
//   [UIView commitAnimations];
// }
//
// - (void)toggleExtras:(BOOL)alpha {
// }
//
// - (void)addExtras:(UIView *)superview {
//   for (NSDictionary *extra in self.info[@"extras"]) {
//     BookExtraBtn *extraBtn = [[BookExtraBtn alloc] initWithDictionary:extra];
//     [superview addSubview:extraBtn];
//   }
// }
//
// - (void)layoutSubviews {
//   CGSize size = self.frame.size;
//   if (zoomable) {
//     zoomContainer.frame = CGRectMake(0, 0, size.width, size.height);
//     pageContainer.frame = CGRectMake(0, 0, size.width, size.height);
//     zoomContainer.zoomScale = 1;
//   }
//   [self setupUi:size];
// }
//
// - (void)setupUi:(CGSize)size {
//   if (zoomable) {
//     zoomContainer.zoomScale = 1;
//   }
//   spinner.center = CGPointMake(size.width / 2, size.height / 2);
// }
//
// - (void)pageOn {
//   showed = YES;
// }
//
// - (void)pageOff {
//   showed = NO;
// }
//
// @end
//
// /***************************************************************
//  ** BookPagePdf ************************************************
//  ***************************************************************/
//
// @implementation BookPagePdf
//
// - (id)initWithDictionary:(NSDictionary *)dictionary zoomable:(BOOL)_zoomable {
//   self = [super initWithDictionary:dictionary zoomable:_zoomable];
//   if (self) {
//     pdfImage = nil;
//   }
//   return self;
// }
//
// - (void)loadUi {
//   [super loadUi];
//   pdfImage = [[PdfImageView alloc] initWithDictionary:self.info pageNumber:pageNumber];
//   [[self container] addSubview:pdfImage];
//   if (showed) {
//     pdfImage.zoomable = YES;
//   }
// }
//
// - (void)resetUi {
//   [super resetUi];
//   if (pdfImage != nil) {
//     [pdfImage removeFromSuperview];
//     pdfImage = nil;
//   }
// }
//
// - (void)pageOn {
//   [super pageOn];
//   if (pdfImage != nil) {
//     pdfImage.zoomable = YES;
//   }
// }
//
// - (void)pageOff {
//   [super pageOff];
//   if (pdfImage != nil) {
//     pdfImage.zoomable = NO;
//   }
// }
//
// - (void)setupUi:(CGSize)size {
//   [super setupUi:size];
//   if (pdfImage != nil && pdfImage.width != 0 && pdfImage.height != 0) {
//     float w = pdfImage.width;
//     float h = pdfImage.height;
//     float r1 = size.width / size.height;
//     float r2 = w / h;
//     if (r2 > r1) {
//       float w = size.width;
//       float h = w / r2;
//       pdfImage.frame = CGRectMake(0, (size.height - h) / 2, w, h);
//     }
//     if (r2 < r1) {
//       float h = size.height;
//       float w = h * r2;
//       float padding = size.width - w;
//       if (padding / size.width < 0.2 || !zoomable) {
//         if (pageNumber % 2 == 0) {
//           pdfImage.frame = CGRectMake(padding, 0, w, h);
//         } else {
//           pdfImage.frame = CGRectMake(0, 0, w, h);
//         }
//       } else {
//         pdfImage.frame = CGRectMake((size.width - w) / 2, 0, w, h);
//       }
//     }
//   }
// }
//
// @end
//
// /***************************************************************
//  ** BookPageImage ************************************************
//  ***************************************************************/
//
// @implementation BookPageImage
//
// - (id)initWithDictionary:(NSDictionary *)dictionary zoomable:(BOOL)_zoomable {
//   self = [super initWithDictionary:dictionary zoomable:_zoomable];
//   if (self) {
//     image = nil;
//   }
//   return self;
// }
//
// - (void)loadUi {
//   [super loadUi];
//   image = [[UIImageView alloc] init];
//   image.alpha = 0;
//   [image sd_setImageWithURL:[NSURL URLWithString:info[@"imageUrl"]]
//                   completed:^(UIImage *img, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                     [UIView beginAnimations:nil context:nil];
//                     [UIView setAnimationDuration:0.5];
//                     image.alpha = 1;
//                     [UIView commitAnimations];
//                   }];
//   [[self container] addSubview:image];
//   [self addExtras:image];
// }
//
// - (void)resetUi {
//   [super resetUi];
//   if (image != nil) {
//     [image removeFromSuperview];
//     image = nil;
//   }
// }
//
// - (void)pageOn {
//   [super pageOn];
// }
//
// - (void)pageOff {
//   [super pageOff];
// }
//
// - (void)toggleExtras:(BOOL)alpha {
//   if (image != nil) {
//     [self alphaExtras:image alpha:alpha];
//   }
// }
//
// - (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//   [super scrollViewDidZoom:scrollView];
//   if (image != nil) {
//     [self alphaExtras:image];
//   }
// }
//
// - (void)setupUi:(CGSize)size {
//   [super setupUi:size];
//   float w = [[self.info objectForKey:@"w"] floatValue];
//   float h = [[self.info objectForKey:@"h"] floatValue];
//   if (image != nil) {
//     float r1 = size.width / size.height;
//     float r2 = w / h;
//     if (r2 > r1) {
//       float w = size.width;
//       float h = w / r2;
//       image.frame = CGRectMake(0, (size.height - h) / 2, w, h);
//     }
//     if (r2 < r1) {
//       float h = size.height;
//       float w = h * r2;
//       float padding = size.width - w;
//       if (padding / size.width < 0.2 || !zoomable) {
//         if (pageNumber % 2 == 0) {
//           image.frame = CGRectMake(padding, 0, w, h);
//         } else {
//           image.frame = CGRectMake(0, 0, w, h);
//         }
//       } else {
//         image.frame = CGRectMake((size.width - w) / 2, 0, w, h);
//       }
//     }
//     [self setupExtras:image size:image.frame.size];
//   }
// }
//
// @end
//
// /***************************************************************
//  ** BookDoublePage *********************************************
//  ***************************************************************/
//
// @implementation BookDoublePage
//
// @synthesize pageNumber, state, showed;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//     state = BookPageSetupTypeUnknown;
//     zoomContainer = [[TogoScrollView alloc] init];
//     [self addSubview:zoomContainer];
//     pageContainer = [[UIView alloc] init];
//     [zoomContainer addSubview:pageContainer];
//     zoomContainer.maximumZoomScale = 4;
//     zoomContainer.delegate = self;
//     zoomContainer.bounces = NO;
//     zoomContainer.bouncesZoom = NO;
//     showed = NO;
//   }
//   return self;
// }
//
// - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//   return pageContainer;
// }
//
// - (void)setup:(BookPageSetupType)setupType {
//   zoomContainer.zoomScale = 1;
//   if (state != setupType) {
//     for (BookPage *page in [pageContainer subviews]) {
//       if ([page isKindOfClass:[BookPage class]]) {
//         [page removeFromSuperview];
//       }
//     }
//     if (setupType == BookPageSetupTypeActive) {
//       int numberOfPages = (int)[[[self info] objectForKey:@"pages"] count];
//       if (pageNumber > 1) {
//         NSDictionary *data = [[info objectForKey:@"pages"] objectAtIndex:pageNumber - 2];
//         BookPage *page = [[NSClassFromString([data objectForKey:@"class"]) alloc] initWithDictionary:data zoomable:NO];
//         page.pageNumber = pageNumber - 1;
//         [pageContainer addSubview:page];
//       }
//       if (pageNumber <= numberOfPages) {
//         NSDictionary *data = [[info objectForKey:@"pages"] objectAtIndex:pageNumber - 1];
//         BookPage *page = [[NSClassFromString([data objectForKey:@"class"]) alloc] initWithDictionary:data zoomable:NO];
//         page.pageNumber = pageNumber;
//         [pageContainer addSubview:page];
//       }
//       [self setNeedsLayout];
//     }
//     state = setupType;
//   }
// }
//
// - (void)pageOn {
//   showed = YES;
//   for (BookPage *page in [pageContainer subviews]) {
//     if ([page isKindOfClass:[BookPage class]]) {
//       [page pageOn];
//     }
//   }
// }
//
// - (void)pageOff {
//   showed = NO;
//   for (BookPage *page in [pageContainer subviews]) {
//     if ([page isKindOfClass:[BookPage class]]) {
//       [page pageOff];
//     }
//   }
// }
//
// - (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(broadcastDidZoom) object:nil];
//   [self performSelector:@selector(broadcastDidZoom) withObject:nil afterDelay:0.3];
//   for (BookPage *page in [pageContainer subviews]) {
//     if ([page isKindOfClass:[BookPage class]]) {
//       [page toggleExtras:(zoomContainer.zoomScale == 1)];
//     }
//   }
// }
//
// - (void)broadcastDidZoom {
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"PageDidZoom" object:[NSString stringWithFormat:@"%f", zoomContainer.zoomScale]];
// }
//
// - (void)layoutSubviews {
//   zoomContainer.zoomScale = 1;
//   CGSize size = self.frame.size;
//   zoomContainer.frame = CGRectMake(0, 0, size.width, size.height);
//   pageContainer.frame = CGRectMake(0, 0, size.width, size.height);
//   for (BookPage *page in [pageContainer subviews]) {
//     if ([page isKindOfClass:[BookPage class]]) {
//       if (page.pageNumber == pageNumber) {
//         page.frame = CGRectMake(size.width / 2, 0, size.width / 2, size.height);
//         [page setup:BookPageSetupTypeActive];
//       } else {
//         page.frame = CGRectMake(0, 0, size.width / 2, size.height);
//         [page setup:BookPageSetupTypeActive];
//       }
//     }
//   }
// }
//
// @end
//
// /***************************************************************
//  ** BookThumb **************************************************
//  ***************************************************************/
//
// @implementation BookThumb
//
// @synthesize doublePage;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//     doublePage = YES;
//     state = BookPageSetupTypeUnknown;
//     self.backgroundColor = [UIColor whiteColor];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageChanged:) name:@"BookPageChanged" object:nil];
//     //    [[NSNotificationCenter defaultCenter] addObserver:self
//     //                                             selector:@selector(updateThumb:)
//     //                                                 name:@"AfterGrabView"
//     //                                               object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingImage:) name:@"IncomingPdfThumb" object:nil];
//     [self addTarget:self action:@selector(openMe) forControlEvents:UIControlEventTouchUpInside];
//   }
//   return self;
// }
//
// - (void)dealloc {
//   [[NSNotificationCenter defaultCenter] removeObserver:self];
// }
//
// - (void)incomingImage:(NSNotification *)notification {
//   if ([[notification.userInfo objectForKey:@"pageNumber"] intValue] == [[[self info] objectForKey:@"n"] intValue]) {
//     [self performSelectorOnMainThread:@selector(delayedIncomingImage:) withObject:notification.object waitUntilDone:YES];
//   }
// }
//
// - (void)delayedIncomingImage:(UIImage *)image {
//   UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//   imageView.userInteractionEnabled = NO;
//   [self addSubview:imageView];
//   [self setNeedsLayout];
// }
//
// //- (void)updateThumb:(NSNotification*)notification {
// //  if (self.alpha == 1) {
// //    CGSize size = self.frame.size;
// //    UIImageView* image =
// //        [[UIImageView alloc] initWithImage:notification.object];
// //    [self addSubview:image];
// //    image.frame = CGRectMake(0, 0, size.width, size.height);
// //    AFHTTPRequestOperationManager* afManager =
// //        [AFHTTPRequestOperationManager manager];
// //    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
// //    [parameters setObject:[self.info objectForKey:@"id"] forKey:@"id"];
// //    [afManager POST:@"..."
// //        parameters:parameters
// //        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
// //          [formData
// //              appendPartWithFileData:UIImageJPEGRepresentation(image.image,
// //              0.8)
// //                                name:@"thumb"
// //                            fileName:@"thumb"
// //                            mimeType:@"image/jpeg"];
// //        }
// //        success:^(AFHTTPRequestOperation* operation, id responseObject) {
// //        }
// //        failure:^(AFHTTPRequestOperation* operation, NSError* error){
// //        }];
// //  }
// //}
//
// - (void)pageChanged:(NSNotification *)notification {
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   int currentPage = [notification.object intValue];
//   int page = [[self.info objectForKey:@"n"] intValue];
//   if (doublePage) {
//     if (currentPage == page || (page % 2 == 1 && currentPage + 1 == page) || (page % 2 == 0 && currentPage - 1 == page)) {
//       self.alpha = 1;
//       [[NSNotificationCenter defaultCenter] postNotificationName:@"BookShowThumb" object:self];
//     } else {
//       self.alpha = 0.75;
//     }
//   } else {
//     if (currentPage == page) {
//       self.alpha = 1;
//       [[NSNotificationCenter defaultCenter] postNotificationName:@"BookShowThumb" object:self];
//     } else {
//       self.alpha = 0.75;
//     }
//   }
//   [UIView commitAnimations];
// }
//
// - (void)setup:(BookPageSetupType)setupType {
//   if (state != setupType) {
//     for (UIView *view in [self subviews]) {
//       [view removeFromSuperview];
//     }
//     if (setupType == BookPageSetupTypeActive) {
//       if ([self.info objectForKey:@"thumbUrl"] != nil) {
//         TogoImageView *thumb = [[TogoImageView alloc] initWithURL:[self.info objectForKey:@"thumbUrl"]];
//         [self addSubview:thumb];
//         thumb.userInteractionEnabled = NO;
//         [self setNeedsLayout];
//       }
//       if ([self.info objectForKey:@"pdfUrl"] != nil) {
//         PdfOperation *operation = [[PdfOperation alloc] initWithDictionary:self.info pageNumber:[[[self info] objectForKey:@"n"] intValue] height:300];
//         [operation setQueuePriority:NSOperationQueuePriorityVeryLow];
//         operation.notificationName = @"IncomingPdfThumb";
//         [[[TogoApp sharedInstance] pdfProcessingQueue] addOperation:operation];
//       }
//     }
//     state = setupType;
//   }
// }
//
// - (void)layoutSubviews {
//   CGSize size = self.frame.size;
//   for (UIView *thumb in [self subviews]) {
//     if ([thumb isKindOfClass:[TogoImageView class]]) {
//       thumb.frame = CGRectMake(0, 0, size.width, size.height);
//     }
//     if ([thumb isKindOfClass:[UIImageView class]]) {
//       thumb.frame = CGRectMake(0, 0, size.width, size.height);
//     }
//   }
// }
//
// - (void)openMe {
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"BookGoToPage" object:self.info];
// }
//
// @end
//
// /***************************************************************
//  ** BookNavigator **********************************************
//  ***************************************************************/
//
// @implementation BookNavigator
//
// - (id)initWithDictionary:(NSDictionary *)dictionary {
//   self = [super initWithDictionary:dictionary];
//   if (self) {
//     BOOL doublePage = NO;
//     if ([@"double" compare:[self.info objectForKey:@"horizontalMode"]] == NSOrderedSame) {
//       doublePage = YES;
//     }
//     UIColor *color = [[[TogoApp sharedInstance] confColor:@"windowFgColor"] colorWithAlphaComponent:0.8];
//     self.backgroundColor = color;
//     container = [[UIScrollView alloc] init];
//     container.delegate = self;
//     [self addSubview:container];
//     for (NSDictionary *dictionary in [self.info objectForKey:@"pages"]) {
//       BookThumb *thumb = [[BookThumb alloc] initWithDictionary:dictionary];
//       thumb.doublePage = doublePage;
//       [container addSubview:thumb];
//     }
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showThumb:) name:@"BookShowThumb" object:nil];
//   }
//   return self;
// }
//
// - (void)showThumb:(NSNotification *)notification {
//   [self performSelector:@selector(showThumbDelayed:) withObject:notification afterDelay:0.5];
// }
//
// - (void)showThumbDelayed:(NSNotification *)notification {
//   if (container.frame.size.width != 0) {
//     BookThumb *thumb = notification.object;
//     if (thumb.frame.origin.x < container.contentOffset.x) {
//       int x = thumb.frame.origin.x;
//       if (x < 0)
//         x = 0;
//       [container setContentOffset:CGPointMake(x, 0) animated:YES];
//     }
//     if (thumb.frame.origin.x > container.contentOffset.x + container.frame.size.width - thumb.frame.size.width) {
//       int x = thumb.frame.origin.x - container.frame.size.width + thumb.frame.size.width;
//       [container setContentOffset:CGPointMake(x, 0) animated:YES];
//     }
//   }
// }
//
// - (void)layoutSubviews {
//   BOOL doublePage = NO;
//   if ([@"double" compare:[self.info objectForKey:@"horizontalMode"]] == NSOrderedSame) {
//     doublePage = YES;
//   }
//   CGSize size = self.frame.size;
//   int x = 0;
//   int i = 0;
//   container.frame = CGRectMake(0, 0, size.width, size.height);
//   for (BookThumb *thumb in [container subviews]) {
//     if ([thumb isKindOfClass:[BookThumb class]]) {
//       float w = [[thumb.info objectForKey:@"w"] floatValue];
//       float h = [[thumb.info objectForKey:@"h"] floatValue];
//       if (w == 0)
//         w = 768;
//       if (h == 0)
//         h = 1024;
//       w = w * 170 / h;
//       thumb.frame = CGRectMake(x, 0, w, 170);
//       x += w;
//       if (!doublePage || i % 2 == 0) {
//         x += 10;
//       }
//       i++;
//     }
//   }
//   container.contentSize = CGSizeMake(x - (doublePage ? 0 : 10), 170);
//   [self scrollViewDidScroll:container];
// }
//
// - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//   CGSize size = self.frame.size;
//   for (BookThumb *thumb in [container subviews]) {
//     if ([thumb isKindOfClass:[BookThumb class]]) {
//       float x1 = thumb.frame.origin.x;
//       float x2 = container.contentOffset.x;
//       if (fabs(x1 - x2) < size.width * 2) {
//         [thumb setup:BookPageSetupTypeActive];
//       } else {
//         [thumb setup:BookPageSetupTypeDisabled];
//       }
//     }
//   }
// }
//
// @end
//
// /***************************************************************
//  ** TogoBookController *****************************************
//  ***************************************************************/
//
// @implementation TogoBookController
// @synthesize showArrows;
//
// - (id)init {
//   self = [super init];
//   if (self) {
//     navigationType = BookNavigationTypeUnknown;
//     self.showArrows = YES;
//   }
//   return self;
// }
//
// - (id)initWithDictionary:(NSDictionary *)dictionary {
//   self = [super init];
//   if (self) {
//     self.info = dictionary;
//     self.showArrows = YES;
//     [self setup];
//   }
//   return self;
// }
//
// - (void)setup {
//   navigationType = BookNavigationTypeWithDefault;
//   numberOfPages = (int)[[info objectForKey:@"pages"] count];
//   currentPage = 1;
// }
//
// - (int)doubleNumberOfPages {
//   return numberOfPages / 2 + 1;
// }
//
// - (int)doubleCurrentPage {
//   return currentPage / 2;
// }
//
// - (void)loadUi {
//   [super loadUi];
//   navigatorOn = NO;
//   uiOn = YES;
//   logo = [[TogoWebSvg alloc] initWithSvgAsString:[[TogoApp sharedInstance] conf:@"logoSvg"]];
//   [self.view addSubview:logo];
//   logo.alpha = 0.1;
//   if (navigationType != BookNavigationTypeUnknown) {
//     stage = [[UIView alloc] init];
//     [self.view addSubview:stage];
//     self.view.clipsToBounds = YES;
//     if ([@"double" compare:[self.info objectForKey:@"horizontalMode"]] == NSOrderedSame) {
//       horizontalContainer = [[UIScrollView alloc] init];
//       horizontalContainer.pagingEnabled = YES;
//       [stage addSubview:horizontalContainer];
//       for (int i = 0; i < [self doubleNumberOfPages]; i++) {
//         BookDoublePage *page = [[BookDoublePage alloc] initWithDictionary:self.info];
//         page.pageNumber = 1 + i * 2;
//         [horizontalContainer addSubview:page];
//       }
//     } else {
//       horizontalContainer = nil;
//     }
//     {
//       container = [[UIScrollView alloc] init];
//       container.pagingEnabled = YES;
//       [stage addSubview:container];
//       for (int i = 0; i < numberOfPages; i++) {
//         NSDictionary *dict = [[info objectForKey:@"pages"] objectAtIndex:i];
//         BookPage *page = [[NSClassFromString([dict objectForKey:@"class"]) alloc] initWithDictionary:dict zoomable:[[info objectForKey:@"zoomable"] boolValue]];
//         page.pageNumber = i + 1;
//         [container addSubview:page];
//       }
//     }
//     btnBackOverlay = [[TogoButton alloc] initWithUnicode:@"\uf00d" color:[[TogoApp sharedInstance] confColor:@"windowFgColor"]];
//     [btnBackOverlay addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//     [self.view addSubview:btnBackOverlay];
//     btnShowThumbsOverlay = [[TogoButton alloc] initWithUnicode:@"\uf077" color:[[TogoApp sharedInstance] confColor:@"headerFgColor"]];
//     [btnShowThumbsOverlay addTarget:self action:@selector(showNavigator) forControlEvents:UIControlEventTouchUpInside];
//     [self.view addSubview:btnShowThumbsOverlay];
//     btnShowThumbsOverlay.alpha = 0;
//
//     if (showArrows) {
//       bgLeftArrow = [[UIView alloc] init];
//       bgLeftArrow.backgroundColor = [[TogoApp sharedInstance] confColor:@"windowBgColor"];
//       bgLeftArrow.layer.cornerRadius = 256;
//       bgLeftArrow.layer.masksToBounds = YES;
//       [self.view addSubview:bgLeftArrow];
//       bgRightArrow = [[UIView alloc] init];
//       bgRightArrow.backgroundColor = [[TogoApp sharedInstance] confColor:@"windowBgColor"];
//       bgRightArrow.layer.cornerRadius = 256;
//       bgRightArrow.layer.masksToBounds = YES;
//       [self.view addSubview:bgRightArrow];
//       btnLeftArrow = [[TogoButton alloc] initWithUnicode:@"\uf053" color:[[TogoApp sharedInstance] confColor:@"windowFgColor"]];
//       [self.view addSubview:btnLeftArrow];
//       btnRightArrow = [[TogoButton alloc] initWithUnicode:@"\uf054" color:[[TogoApp sharedInstance] confColor:@"windowFgColor"]];
//       [self.view addSubview:btnRightArrow];
//       bgLeftArrow.userInteractionEnabled = bgRightArrow.userInteractionEnabled = btnLeftArrow.userInteractionEnabled = btnRightArrow.userInteractionEnabled = NO;
//       bgLeftArrow.alpha = bgRightArrow.alpha = btnLeftArrow.alpha = btnRightArrow.alpha = 0;
//       btnPrevPage = [[UIButton alloc] init];
//       [self.view addSubview:btnPrevPage];
//       [btnPrevPage addTarget:self action:@selector(prevPage) forControlEvents:UIControlEventTouchUpInside];
//       btnNextPage = [[UIButton alloc] init];
//       [self.view addSubview:btnNextPage];
//       [btnNextPage addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
//     }
//
//     footer = [[UIView alloc] init];
//     footer.backgroundColor = [[[TogoApp sharedInstance] confColor:@"windowFgColor"] colorWithAlphaComponent:0.8];
//     footer.userInteractionEnabled = NO;
//     [self.view addSubview:footer];
//     navigator = [[BookNavigator alloc] initWithDictionary:self.info];
//     [self.view addSubview:navigator];
//     btnShowThumbs = [[TogoButton alloc] initWithUnicode:@"\uf077" color:[[TogoApp sharedInstance] confColor:@"headerBgColor"]];
//     [btnShowThumbs addTarget:self action:@selector(toggleNavigator) forControlEvents:UIControlEventTouchUpInside];
//     [self.view addSubview:btnShowThumbs];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToPage:) name:@"BookGoToPage" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeNavigator) name:@"TogoDoubleTap" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideUi) name:@"TogoDoubleTap" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleUi) name:@"TogoSingleTap" object:nil];
//     //    [[NSNotificationCenter defaultCenter]
//     //        addObserver:self
//     //           selector:@selector(onShowExtraView:)
//     //               name:@"BookExtraView"
//     //             object:nil];
//     //    [[NSNotificationCenter defaultCenter] addObserver:self
//     //                                             selector:@selector(onHideExtraView)
//     //                                                 name:@"BookExtraViewClose"
//     //                                               object:nil];
//
//     footer.alpha = 0;
//     [self performSelector:@selector(showUi) withObject:nil afterDelay:0];
//
//     //    bgExtraView = [[UIButton alloc] init];
//     //    [bgExtraView addTarget:self
//     //                    action:@selector(onHideExtraView)
//     //          forControlEvents:UIControlEventTouchUpInside];
//     //    bgExtraView.backgroundColor =
//     //        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//     //    [self.view addSubview:bgExtraView];
//     //    bgExtraView.alpha = 0;
//     //    extraView = nil;
//
//     //    debugImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300,
//     //    400)];
//     //    [self.view addSubview:debugImage];
//     //    debugImage.alpha = 0;
//   }
// }
// //
// //- (void)onShowExtraView:(NSNotification*)notification {
// //  [self showExtraView:notification.object];
// //}
// //
// //- (void)showExtraView:(UIView*)view {
// //  if (extraView != nil) {
// //    [extraView removeFromSuperview];
// //  }
// //  extraView = [[BookExtraView alloc] initWithView:view];
// //  [self.view addSubview:extraView];
// //  extraView.alpha = 0;
// //  bgExtraView.alpha = 0;
// //  [UIView beginAnimations:nil context:nil];
// //  [UIView setAnimationDuration:0.5];
// //  extraView.alpha = 1;
// //  bgExtraView.alpha = 1;
// //  [UIView commitAnimations];
// //  [self needsSetupUi];
// //}
// //
// //- (void)onHideExtraView {
// //  if (extraView != nil) {
// //    [UIView beginAnimations:nil context:nil];
// //    [UIView setAnimationDuration:0.5];
// //    [UIView setAnimationDelegate:self];
// //    [UIView setAnimationDidStopSelector:@selector(clearExtraView)];
// //    extraView.alpha = 0;
// //    bgExtraView.alpha = 0;
// //    [UIView commitAnimations];
// //  }
// //}
// //
// //- (void)clearExtraView {
// //  if (extraView != nil) {
// //    [extraView removeFromSuperview];
// //    extraView = nil;
// //  }
// //}
//
// - (void)showUi {
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   footer.alpha = 1;
//   [UIView commitAnimations];
// }
//
// - (void)goBack {
//   [[TogoApp sharedInstance] popController:YES];
// }
//
// - (void)showNavigator {
//   uiOn = NO;
//   [self toggleUi];
//   navigatorOn = YES;
//   [self performSelector:@selector(setupUiAnimated) withObject:nil afterDelay:0.5];
// }
//
// - (void)goToPage:(NSNotification *)notification {
//   int n = [[notification.object objectForKey:@"n"] intValue];
//   //  if (n == currentPage && togoMode == YES) {
//   //    [[NSNotificationCenter defaultCenter]
//   // postNotificationName :
//   //   @"BeforeGrabView"
//   //                                                        object:nil];
//   //    [self performSelector:@selector(grabPage) withObject:nil
//   //    afterDelay:0];
//   //  } else {
//   currentPage = n;
//   navigatorOn = NO;
//   [self hideUi];
//   [self setupUiAnimated];
//   //  }
// }
// //
// //+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
// //  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
// //  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
// //  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
// //  UIGraphicsEndImageContext();
// //  return newImage;
// //}
// //
// ////- (void)grabPage {
// ////  UIGraphicsBeginImageContextWithOptions(stage.bounds.size, stage.opaque,
// /// 0.0);
// ////  [stage.layer renderInContext:UIGraphicsGetCurrentContext()];
// ////  UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
// ////  debugImage.image =
// ////      [TogoBookController imageWithImage:img scaledToSize:CGSizeMake(300,
// /// 400)];
// ////  UIGraphicsEndImageContext();
// ////  [[NSNotificationCenter defaultCenter]
// /// postNotificationName:@"AfterGrabView"
// //// object:debugImage.image];
// ////}
//
// - (void)toggleNavigator {
//   navigatorOn = !navigatorOn;
//   [self setupUiAnimated];
// }
//
// - (void)hideUi {
//   uiOn = YES;
//   [self toggleUi];
// }
//
// - (void)toggleUi {
//   uiOn = !uiOn;
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   footer.alpha = btnShowThumbs.alpha = navigator.alpha = uiOn;
//   btnShowThumbsOverlay.alpha = (!uiOn) * 0.25;
//   if (!uiOn && navigatorOn) {
//     navigatorOn = NO;
//     [self setupUiNavigator];
//   }
//   [UIView commitAnimations];
// }
//
// - (void)closeNavigator {
//   navigatorOn = NO;
//   [UIView beginAnimations:nil context:nil];
//   [UIView setAnimationDuration:0.5];
//   [self setupUiNavigator];
//   [UIView commitAnimations];
// }
//
// - (void)prevPage {
//   self.view.userInteractionEnabled = NO;
//   CGSize size = self.view.frame.size;
//   if (container.alpha == 1) {
//     if (currentPage > 1) {
//       [container setContentOffset:CGPointMake((currentPage - 2) * size.width, 0) animated:YES];
//     }
//   }
//   if (horizontalContainer.alpha == 1) {
//     if (currentPage > 1) {
//       [horizontalContainer setContentOffset:CGPointMake(([self doubleCurrentPage] - 1) * size.width, 0) animated:YES];
//     }
//   }
//   [self performSelector:@selector(enableInteraction) withObject:self afterDelay:0.5];
// }
//
// - (void)nextPage {
//   self.view.userInteractionEnabled = NO;
//   CGSize size = self.view.frame.size;
//   if (container.alpha == 1) {
//     if (currentPage < numberOfPages) {
//       [container setContentOffset:CGPointMake((currentPage)*size.width, 0) animated:YES];
//     }
//   }
//   if (horizontalContainer.alpha == 1) {
//     if ([self doubleCurrentPage] + 1 < [self doubleNumberOfPages]) {
//       [horizontalContainer setContentOffset:CGPointMake(([self doubleCurrentPage] + 1) * size.width, 0) animated:YES];
//     }
//   }
//   [self performSelector:@selector(enableInteraction) withObject:self afterDelay:0.5];
// }
//
// - (void)enableInteraction {
//   self.view.userInteractionEnabled = YES;
// }
//
// - (void)setupPage {
//   CGSize size = self.view.frame.size;
//   if (horizontalContainer == nil || size.width < size.height) {
//     [UIView beginAnimations:nil context:nil];
//     [UIView setAnimationDuration:0.5];
//     if (showArrows) {
//       bgLeftArrow.alpha = btnLeftArrow.alpha = 0.25 * (currentPage > 1);
//       bgRightArrow.alpha = btnRightArrow.alpha = 0.25 * (currentPage < numberOfPages);
//     }
//     [UIView commitAnimations];
//     for (BookPage *page in [container subviews]) {
//       if ([page isKindOfClass:[BookPage class]]) {
//         if (abs(page.pageNumber - currentPage) < 2) {
//           [page setup:BookPageSetupTypeActive];
//         } else {
//           [page setup:BookPageSetupTypeDisabled];
//         }
//         if (page.pageNumber == currentPage) {
//           [page pageOn];
//         } else {
//           [page pageOff];
//         }
//       }
//     }
//     for (BookDoublePage *page in [horizontalContainer subviews]) {
//       if ([page isKindOfClass:[BookDoublePage class]]) {
//         [page setup:BookPageSetupTypeDisabled];
//       }
//     }
//   }
//   if (horizontalContainer != nil && size.width > size.height) {
//     [UIView beginAnimations:nil context:nil];
//     [UIView setAnimationDuration:0.5];
//     if (showArrows) {
//       bgLeftArrow.alpha = btnLeftArrow.alpha = 0.25 * (currentPage > 2);
//       bgRightArrow.alpha = btnRightArrow.alpha = 0.25 * ([self doubleCurrentPage] + 1 < [self doubleNumberOfPages]);
//     }
//     [UIView commitAnimations];
//     for (BookDoublePage *page in [horizontalContainer subviews]) {
//       if ([page isKindOfClass:[BookDoublePage class]]) {
//         int oddCurrentPage = currentPage + 1 - currentPage % 2;
//         if (abs(page.pageNumber - oddCurrentPage) < 3) {
//           [page setup:BookPageSetupTypeActive];
//         } else {
//           [page setup:BookPageSetupTypeDisabled];
//         }
//         if (page.pageNumber == oddCurrentPage) {
//           [page pageOn];
//         } else {
//           [page pageOff];
//         }
//       }
//     }
//     for (BookPage *page in [container subviews]) {
//       if ([page isKindOfClass:[BookPage class]]) {
//         [page setup:BookPageSetupTypeDisabled];
//       }
//     }
//   }
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"BookPageChanged" object:[NSString stringWithFormat:@"%d", currentPage]];
//
//   //  NSString* verticalInfo = @"";
//   //  int i = 0;
//   //  for (BookPage* page in [container subviews]) {
//   //    if ([page isKindOfClass:[BookPage class]]) {
//   //      if (page.state == BookPageSetupTypeActive) {
//   //        if (page.showed) {
//   //          verticalInfo = [verticalInfo stringByAppendingString:@"•"];
//   //        } else {
//   //          verticalInfo = [verticalInfo stringByAppendingString:@"-"];
//   //        }
//   //      } else {
//   //        verticalInfo = [verticalInfo stringByAppendingString:@"_"];
//   //      }
//   //    }
//   //    i++;
//   //  }
//   //  NSLog(@"V: %@", verticalInfo);
//   //  if (horizontalContainer != nil) {
//   //    NSString* horizontalInfo = @"";
//   //    int i = 0;
//   //    for (BookDoublePage* page in [horizontalContainer subviews]) {
//   //      if ([page isKindOfClass:[BookDoublePage class]]) {
//   //        if (page.state == BookPageSetupTypeActive) {
//   //          if (page.showed) {
//   //            horizontalInfo = [horizontalInfo stringByAppendingString:@"•"];
//   //          } else {
//   //            horizontalInfo = [horizontalInfo stringByAppendingString:@"-"];
//   //          }
//   //        } else {
//   //          horizontalInfo = [horizontalInfo stringByAppendingString:@"_"];
//   //        }
//   //      }
//   //      i++;
//   //    }
//   //    NSLog(@"H: %@", horizontalInfo);
// }
//
// - (void)setupUiLandscape:(CGSize)size {
//   if (horizontalContainer != nil) {
//     container.alpha = 0;
//     horizontalContainer.alpha = 1;
//   }
// }
//
// - (void)setupUiPortrait:(CGSize)size {
//   if (horizontalContainer != nil) {
//     container.alpha = 1;
//     horizontalContainer.alpha = 0;
//   }
// }
//
// - (void)setupUi:(CGSize)size {
//   [super setupUi:size];
//   if (size.width > size.height) {
//     [self setupUiLandscape:size];
//   } else {
//     [self setupUiPortrait:size];
//   }
//   logo.frame = CGRectMake(0, (size.height - size.width) / 2, size.width, size.width);
//   if (navigationType != BookNavigationTypeUnknown) {
//     if (horizontalContainer != nil) {
//       horizontalContainer.delegate = nil;
//       horizontalContainer.frame = CGRectMake(0, 0, size.width, size.height);
//       if (navigationType != BookNavigationTypeWithArrowsOnly) {
//         horizontalContainer.contentSize = CGSizeMake(size.width * [self doubleNumberOfPages], size.height);
//         horizontalContainer.contentOffset = CGPointMake(size.width * [self doubleCurrentPage], 0);
//       }
//     }
//     container.delegate = nil;
//     stage.frame = CGRectMake(0, 0, size.width, size.height);
//     container.frame = CGRectMake(0, 0, size.width, size.height);
//     if (navigationType != BookNavigationTypeWithArrowsOnly) {
//       container.contentSize = CGSizeMake(size.width * numberOfPages, size.height);
//       container.contentOffset = CGPointMake(size.width * (currentPage - 1), 0);
//     }
//     {
//       int i = 0;
//       for (BookPage *page in [container subviews]) {
//         if ([page isKindOfClass:[BookPage class]]) {
//           page.frame = CGRectMake(i * size.width, 0, size.width, size.height);
//           i++;
//         }
//       }
//     }
//     if (horizontalContainer != nil) {
//       int i = 0;
//       for (BookDoublePage *page in [horizontalContainer subviews]) {
//         if ([page isKindOfClass:[BookDoublePage class]]) {
//           page.frame = CGRectMake(i * size.width, 0, size.width, size.height);
//           i++;
//         }
//       }
//     }
//     int hh = [[TogoApp sharedInstance] confInt:@"headerHeight"];
//     if (showArrows) {
//       bgLeftArrow.frame = CGRectMake(hh - 512, (size.height - 512) / 2, 512, 512);
//       bgRightArrow.frame = CGRectMake(size.width - hh, (size.height - 512) / 2, 512, 512);
//       btnLeftArrow.frame = CGRectMake(0, (size.height - hh) / 2, hh, hh);
//       btnRightArrow.frame = CGRectMake(size.width - hh, (size.height - hh) / 2, hh, hh);
//       btnPrevPage.frame = CGRectMake(0, size.height / 2 - 32, hh * 0.8, 64);
//       btnNextPage.frame = CGRectMake(size.width - hh * 0.8, size.height / 2 - 32, hh * 0.8, 64);
//     }
//     btnBackOverlay.frame = CGRectMake(0, 0, hh, hh);
//     btnShowThumbsOverlay.frame = CGRectMake(size.width - hh, size.height - hh, hh, hh);
//     [self setupPage];
//     container.delegate = self;
//     if (horizontalContainer != nil) {
//       horizontalContainer.delegate = self;
//     }
//     [self setupUiNavigator];
//     //
//     //    if (extraView != nil) {
//     //      int w = MIN(size.width, size.height) - (IS_IPAD ? 160 : 40);
//     //      extraView.frame =
//     //          CGRectMake((size.width - w) / 2, (size.height - w) / 2, w, w);
//     //    }
//     //    bgExtraView.frame = CGRectMake(0, 0, size.width, size.height);
//   }
//   [self performSelector:@selector(updateNavigator) withObject:nil afterDelay:0];
// }
//
// - (void)setupUiNavigator {
//   CGSize size = self.view.frame.size;
//   int hh = [[TogoApp sharedInstance] confInt:@"headerHeight"];
//   if (!navigatorOn) {
//     footer.frame = CGRectMake(0, size.height - hh, size.width, hh);
//     btnShowThumbs.frame = CGRectMake(size.width - hh, size.height - hh, hh, hh);
//     navigator.frame = CGRectMake(0, size.height, size.width, 170);
//     btnShowThumbs.transform = CGAffineTransformMakeRotation(0);
//   } else {
//     footer.frame = CGRectMake(0, size.height - hh - 170, size.width, hh);
//     btnShowThumbs.frame = CGRectMake(size.width - hh, size.height - hh - 170, hh, hh);
//     navigator.frame = CGRectMake(0, size.height - 170, size.width, 170);
//     btnShowThumbs.transform = CGAffineTransformMakeRotation(M_PI);
//   }
// }
//
// - (void)updateNavigator {
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"BookPageChanged" object:[NSString stringWithFormat:@"%d", currentPage]];
// }
//
// - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//   CGSize size = self.view.frame.size;
//   if (scrollView == container) {
//     int n = 1 + ((scrollView.contentOffset.x + size.width / 2)) / size.width;
//     if (n != currentPage) {
//       currentPage = n;
//       [self performSelector:@selector(setupPage) withObject:nil afterDelay:0.25];
//       if (!navigatorOn) {
//         uiOn = YES;
//         [self toggleUi];
//       }
//     }
//     if (horizontalContainer != nil) {
//       horizontalContainer.delegate = nil;
//       [horizontalContainer setContentOffset:CGPointMake(([self doubleCurrentPage]) * size.width, 0) animated:NO];
//       horizontalContainer.delegate = self;
//     }
//   }
//   if (scrollView == horizontalContainer) {
//     int n = 1 + ((scrollView.contentOffset.x + size.width / 2)) / size.width;
//     n = n * 2 - 1;
//     if (n != currentPage) {
//       currentPage = n;
//       if (currentPage > numberOfPages) {
//         currentPage--;
//       }
//       [self performSelector:@selector(setupPage) withObject:nil afterDelay:0.25];
//       if (!navigatorOn) {
//         uiOn = YES;
//         [self toggleUi];
//       }
//       container.delegate = nil;
//       [container setContentOffset:CGPointMake(currentPage * size.width, 0) animated:NO];
//       container.delegate = self;
//     }
//   }
// }
//
// - (BOOL)prefersStatusBarHidden {
//   return YES;
// }
//
// @end
