#include "TapController.h"

@interface TapBookController : TapController {
}

// #import "TogoButton.h"
// #import "TogoController.h"
//
// typedef NS_ENUM(NSInteger, BookNavigationType) { BookNavigationTypeUnknown, BookNavigationTypeWithArrowsOnly, BookNavigationTypeWithSwipeOnly, BookNavigationTypeWithDefault };
//
// typedef NS_ENUM(NSInteger, BookPageSetupType) { BookPageSetupTypeUnknown, BookPageSetupTypeActive, BookPageSetupTypeDisabled };
//
// /***************************************************************
//  ** PdfOperation ***********************************************
//  ***************************************************************/
//
// @interface PdfOperation : NSOperation {
//   NSDictionary *info;
//   int pageNumber;
//   float height;
//   float pdfWidth;
//   float pdfHeight;
//   NSString *notificationName;
// }
//
// @property(nonatomic, copy) NSDictionary *info;
// @property(nonatomic, copy) NSString *notificationName;
// @property int pageNumber;
// @property float height;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary pageNumber:(float)n height:(float)h;
//
// @end
//
// /***************************************************************
//  ** PdfImageView ***********************************************
//  ***************************************************************/
//
// @interface PdfImageView : TogoView {
//   CGSize prevSize;
//   float zoomScale;
//   BOOL ready;
// }
//
// @property int pageNumber;
// @property float width;
// @property float height;
// @property BOOL zoomable;
//
// - (id)initWithDictionary:(NSDictionary *)dictionary pageNumber:(int)n;
//
// @end
//
// /***************************************************************
//  ** BookExtraButton ********************************************
//  ***************************************************************/
//
// @interface BookExtraBtn : TogoButtonView {
//   TogoWebView *htmlView;
// }
//
// @end
//
// /***************************************************************
//  ** BookExtraView **********************************************
//  ***************************************************************/
//
// @interface BookExtraView : TogoView {
//   TogoButton *btnBack;
// }
//
// - (id)initWithView:(UIView *)stage;
//
// @end
//
// /***************************************************************
//  ** BookPage ***************************************************
//  ***************************************************************/
//
// @interface BookPage : TogoView <UIScrollViewDelegate> {
//   int pageNumber;
//   BookPageSetupType state;
//   UIView *pageContainer;
//   TogoScrollView *zoomContainer;
//   BOOL zoomable;
//   BOOL showed;
//   MMMaterialDesignSpinner *spinner;
// }
//
// - (UIView *)container;
//
// - (void)pageOn;
// - (void)pageOff;
// - (void)setupExtras:(UIView *)superview size:(CGSize)size;
// - (void)addExtras:(UIView *)superview;
// - (void)alphaExtras:(UIView *)superview;
// - (void)alphaExtras:(UIView *)superview alpha:(float)alpha;
// - (void)toggleExtras:(BOOL)alpha;
//
// - (void)setup:(BookPageSetupType)setupType;
// - (void)resetUi;
// - (void)loadUi;
// - (void)updateUi;
// - (void)setupUi:(CGSize)size;
// - (id)initWithDictionary:(NSDictionary *)dictionary zoomable:(BOOL)zoomable;
//
// @property BookPageSetupType state;
// @property int pageNumber;
// @property BOOL zoomable;
// @property BOOL showed;
//
// @end
//
// /***************************************************************
//  ** BookPagePdf ************************************************
//  ***************************************************************/
//
// @interface BookPagePdf : BookPage {
//   PdfImageView *pdfImage;
// }
//
// @end
//
// /***************************************************************
//  ** BookPageImage ************************************************
//  ***************************************************************/
//
// @interface BookPageImage : BookPage {
//   UIImageView *image;
// }
//
// @end
//
// /***************************************************************
//  ** BookDoublePage *********************************************
//  ***************************************************************/
//
// @interface BookDoublePage : TogoView <UIScrollViewDelegate> {
//   int pageNumber;
//   BookPageSetupType state;
//   UIView *pageContainer;
//   TogoScrollView *zoomContainer;
//   BOOL showed;
// }
//
// - (void)setup:(BookPageSetupType)setupType;
//
// @property int pageNumber;
// @property BOOL showed;
// @property BookPageSetupType state;
//
// - (void)pageOn;
// - (void)pageOff;
// @end
//
// /***************************************************************
//  ** BookThumb **************************************************
//  ***************************************************************/
//
// @interface BookThumb : TogoButtonView {
//   BookPageSetupType state;
//   BOOL doublePage;
// }
//
// @property BOOL doublePage;
//
// - (void)setup:(BookPageSetupType)setupType;
//
// @end
//
// /***************************************************************
//  ** BookNavigator **********************************************
//  ***************************************************************/
//
// @interface BookNavigator : TogoView <UIScrollViewDelegate> {
//   UIScrollView *container;
// }
// @end
//
// @class TogoWebSvg;
//
// /***************************************************************
//  ** TogoBookController *****************************************
//  ***************************************************************/
//
// @interface TogoBookController : TogoController <UIScrollViewDelegate> {
//   BookNavigationType navigationType;
//   UIScrollView *container;
//   UIScrollView *horizontalContainer;
//   UIView *stage;
//
//   int numberOfPages;
//   int currentPage;
//
//   UIView *bgLeftArrow;
//   UIView *bgRightArrow;
//   TogoButton *btnBackOverlay;
//   TogoButton *btnShowThumbsOverlay;
//   TogoButton *btnLeftArrow;
//   TogoButton *btnRightArrow;
//   UIButton *btnNextPage;
//   UIButton *btnPrevPage;
//
//   UIView *footer;
//   BookNavigator *navigator;
//
//   TogoButton *btnShowThumbs;
//
//   BOOL navigatorOn;
//   BOOL uiOn;
//   BOOL prevUiOn;
//
//   //  BookExtraView* extraView;
//   //  UIButton* bgExtraView;
//
//   BOOL standaloneMode;
//   BOOL togoMode;
//   BOOL showArrows;
//
//   //  UIImageView* debugImage;
//   TogoWebSvg *logo;
// }
//
// @property BOOL showArrows;
//
// @end
