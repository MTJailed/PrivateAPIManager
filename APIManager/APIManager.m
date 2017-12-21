/*
  APIManager.m
  Created by Sem Voigtländer on 13/12/2017.
  Reverse engineering Apple Private APIs is allowed by Apple.
  Using code reverse engineered from Private APIs is not recommended as the original code might be licensed.
  Providing code reverse engineered from Private APIs might infringe DMCA rights.
*/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/NSObjCRuntime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import "APIManager.h"

@interface APIManager()
@end
@implementation APIManager

+(BOOL)loadFW:(NSString*)name {
    return [[NSBundle bundleWithPath:[NSString stringWithFormat:@"/System/Library/Frameworks/%@.framework", name]] load];
}
+(BOOL)loadPFW:(NSString*)name {
    return [[NSBundle bundleWithPath:[NSString stringWithFormat:@"/System/Library/PrivateFrameworks/%@.framework", name]] load];
}

+(void)dumpClasses {
    uint count = 0;
    const char **classes;
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    printf("[Classes]\n");
    for (uint i = 0; i < count; i++) {
        NSBundle *b = [NSBundle bundleForClass:NSClassFromString([NSString stringWithUTF8String:classes[i]])];
        if(b != [NSBundle mainBundle]) {
            NSArray* bundlePath = [[b bundlePath] componentsSeparatedByString:@"/"];
            printf("\t%s:\n\t\t- %s\n",[[bundlePath lastObject] UTF8String], classes[i]);
        }
    }
}
+(NSArray*)dumpClasses:(NSString*)framework privateFW:(BOOL)pfw{
    uint count = 0;
    Class * classes = NULL;
    NSString *fwClasses = @"";
    count = objc_getClassList(NULL, 0);
    if(count > 0) {
        printf("[%s Classes]\n", [framework UTF8String]);
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * count);
        count = objc_getClassList(classes, count);
        for (uint i = 0; i < count; i++) {
            NSBundle *b = [NSBundle bundleForClass:NSClassFromString([NSString stringWithUTF8String:class_getName(classes[i])])];
            NSString* path =[NSString stringWithFormat:@"/System/Library/PrivateFrameworks/%@.framework",framework];
            if(!pfw) {
                path = [NSString stringWithFormat:@"/System/Library/Frameworks/%@.framework",framework];
            }
            if([[b bundlePath] isEqualToString:path]) {
                printf("\t\t- %s\n",class_getName(classes[i]));
                fwClasses = [fwClasses stringByAppendingString:[NSString stringWithFormat:@"%@\n", NSStringFromClass(classes[i])]];
            }
        }
    } else {
        printf("No classes found in %s.\n", [framework UTF8String]);
    }
    return [fwClasses componentsSeparatedByString:@"\n"];
}


+(void)dumpAllFromFramework:(NSString*)framework privateFW:(BOOL)pfw{
    NSArray* classes = [APIManager dumpClasses:framework privateFW:pfw];
    if(classes != nil) {
        for(int i = 0; i < classes.count;i++) {
                Class c = NSClassFromString(classes[i]);
                [APIManager dumpProperties:c];
                [APIManager dumpMethods:c];
        }
    }
}

+(void)dumpMethods:(Class)class {
    uint count = 0;
    Method* methods = class_copyMethodList(class, &count);
    printf("[%s Methods]:\n", class_getName(class));
    for (uint i = 0; i < count; i++) {
        Method method = methods[i];
        printf("\t- %s\n", sel_getName(method_getName(method)));
    }
}

+(void)dumpProperties:(Class)class{
    uint count = 0;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    printf("[%s Properties]:\n", class_getName(class));
    for(uint i = 0; i < count; i++) {
        printf("\t- %s\n", property_getName(properties[i]));
    }
}
@end
