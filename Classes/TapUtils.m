#import "TapUtils.h"
#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation TapUtils

+ (NSString *)md5:(NSString *)text {
    if (text != nil) {
        const char *str = [text cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *keyData = [NSData dataWithBytes:str length:strlen(str)];
        uint8_t digest[CC_MD5_DIGEST_LENGTH] = {0};
        CC_MD5(keyData.bytes, (int)keyData.length, digest);
        NSData *data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
        NSMutableString *dataAsString = [NSMutableString string];
        const unsigned char *dataBuffer = [data bytes];
        for (int i=0; i<[data length]; ++i) {
            [dataAsString appendFormat:@"%02X", (unsigned int)dataBuffer[i]];
        }
        return [dataAsString lowercaseString];
    } else
        return nil;
}

+ (NSString *)json:(NSDictionary*)data {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSURL*)docFileUrl:(NSString*)fileName {
    NSURL *documentsDirectoryURL = [self docUrl];
    return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
}

+(NSURL*)docUrl {
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];;
}

+(NSString*)ip {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}


@end

