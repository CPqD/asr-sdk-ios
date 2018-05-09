/*******************************************************************************
 * Copyright 2017 CPqD. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy
 * of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ******************************************************************************/

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
