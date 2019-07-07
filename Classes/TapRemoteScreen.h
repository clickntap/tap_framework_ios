#import <UIKit/UIKit.h>
#import "TapPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapRemoteScreen : UIView {
    //    BOOL isPen;
    TapPlayer* player;
    UIImageView* screen;
    UIView* videoScreen;
    NSString* ip;
    int port;
    BOOL busy;
}

@property (nonatomic, copy) NSString* ip;
@property (nonatomic, copy) NSString* impl;
@property int port;

-(void)setIp:(NSString*)ip port:(int)port impl:(NSString*)impl;
-(void)lock;
-(void)unlock;
-(void)uploadImage:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
