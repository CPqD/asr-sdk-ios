//
//  CPqDASRVersionManager.h
//  CPqDASR
//
//  Created by rodrigomorbach on 29/03/16.
//  Copyright © 2016 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPqDASRVersionManager : NSObject

+ (NSString *)libVersion;

+ (NSString *)libName;

+ (NSString *)appVersion;

+ (NSString *)appName;

@end
