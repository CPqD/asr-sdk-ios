//
//  CPqDASRVersionManager.m
//  CPqDASR
//
//  Created by rodrigomorbach on 29/03/16.
//  Copyright © 2016 CPqD. All rights reserved.
//

#import "CPqDASRVersionManager.h"


NSString * const kLibVersion = @"2.3";
NSString * const kFrameworkBundleName = @"CPqDASR";

@implementation CPqDASRVersionManager

+ (NSString *)libName {
    return kFrameworkBundleName;
}

+ (NSString *)libVersion {
    return kLibVersion;
}

+ (NSString *)appName {
    NSString * appName = nil;
    NSDictionary * d = [[NSBundle mainBundle] infoDictionary];
    NSArray * bundleIdentifier = [[d objectForKey:@"CFBundleIdentifier"] componentsSeparatedByString:@"."];
    //Get the last value, which is the appName
    if (bundleIdentifier.count > 0) {
        appName = [bundleIdentifier lastObject];
    }
    return appName;
}

+ (NSString *)appVersion {
    NSString * appVersion = nil;
    NSDictionary * d = [[NSBundle mainBundle]infoDictionary];
    appVersion = [d objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

@end
