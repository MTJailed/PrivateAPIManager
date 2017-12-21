#ifndef APIManager_h
#define APIManager_h
#import <Foundation/Foundation.h>

@interface APIManager : NSObject
+(void)dumpAllFromFramework:(NSString*)framework privateFW:(BOOL)pfw;
+(void)dumpClasses;
+(NSArray*)dumpClasses:(NSString*)framework privateFW:(BOOL)pfw;
+(void)dumpMethods:(Class)class;
+(void)dumpProperties:(Class)class;
+(BOOL)loadFW:(NSString*)name;
+(BOOL)loadPFW:(NSString*)name;
@end
#endif /* APIManager_h */
