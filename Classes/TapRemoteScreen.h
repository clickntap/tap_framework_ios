#import <UIKit/UIKit.h>
#import <NodeMediaClient/NodeMediaClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapRemoteScreen : UIView {
    //    BOOL isPen;
    NodePlayer* np;
    UIImageView* screen;
    UIView* videoScreen;
    NSString* ip;
    int port;
    BOOL busy;
}

@property (nonatomic, copy) NSString* ip;
@property int port;

-(void)setIp:(NSString*)ip port:(int)port;
-(void)lock;
-(void)unlock;
-(void)uploadImage:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
