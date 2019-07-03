#import <UIKit/UIKit.h>

#define IDIOM                          UI_USER_INTERFACE_IDIOM()
#define IDIOM_IPAD                     UIUserInterfaceIdiomPad
#define IDIOM_IPHONE                   UIUserInterfaceIdiomPhone
#define IS_IPAD                        (IDIOM == IDIOM_IPAD)
#define IS_IPHONE                      (IDIOM == IDIOM_IPHONE)

NS_ASSUME_NONNULL_BEGIN

@class AFURLSessionManager;

@interface TapUtils : NSObject

+ (NSString *)md5:(NSString *)text;
+ (NSString *)json:(NSDictionary*)data;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSURL*)docFileUrl:(NSString*)fileName;
+ (NSURL*)docUrl;
+ (NSString*)ip;

@end

NS_ASSUME_NONNULL_END
