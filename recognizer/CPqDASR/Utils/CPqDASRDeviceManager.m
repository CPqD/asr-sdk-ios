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

#import "CPqDASRDeviceManager.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "CPqDASRLog.h"
//Devide Models

NSString * const kCMFDeviceManagerDeviceModeliPhone4 = @"iPhone 4";
NSString * const kCMFDeviceManagerDeviceModeliPhone4S = @"iPhone 4S";
NSString * const kCMFDeviceManagerDeviceModeliPhone5 = @"iPhone 5";
NSString * const kCMFDeviceManagerDeviceModeliPhone5C = @"iPhone 5C";
NSString * const kCMFDeviceManagerDeviceModeliPhone5S = @"iPhone 5S";
NSString * const kCMFDeviceManagerDeviceModeliPhone6 = @"iPhone 6";
NSString * const kCMFDeviceManagerDeviceModeliPhone6Plus = @"iPhone 6 Plus";
NSString * const kCMFDeviceManagerDeviceModeliPad2 = @"iPad 2";
NSString * const kCMFDeviceManagerDeviceModeliPad3 = @"iPad 3";
NSString * const kCMFDeviceManagerDeviceModeliPad4 = @"iPad 4";
NSString * const kCMFDeviceManagerDeviceModeliPadAir = @"iPad Air";
NSString * const kCMFDeviceManagerDeviceModeliPadAir2 = @"iPad Air 2";
NSString * const kCMFDeviceManagerDeviceModeliPadMini = @"iPad Mini";
NSString * const kCMFDeviceManagerDeviceModeliPhone6S = @"iPhone 6s";
NSString * const kCMFDeviceManagerDeviceModeliPhone6SPlus = @"iPhone 6s Plus";
NSString * const kCMFDeviceManagerDeviceModeliPhoneSE = @"iPhone SE";
NSString * const kCMFDeviceManagerDeviceModeliPhone7 = @"iPhone 7";
NSString * const kCMFDeviceManagerDeviceModeliPhone7Plus = @"iPhone 7 Plus";
NSString * const kCMFDeviceManagerPlatformString = @"iOS|";

NSString * const kKeyIdentifier = @"deviceIdentifier";

NSString * const kCMFDeviceManagerDeviceManufacturer = @"Apple";

@interface CPqDASRDeviceManager()

@property (nonatomic) NSDictionary * deviceList;

@end


static CPqDASRDeviceManager * sharedManager;

@implementation CPqDASRDeviceManager

+ (instancetype)sharedDeviceManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CPqDASRDeviceManager alloc]init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.deviceList = [NSDictionary dictionaryWithObjectsAndKeys:
                           kCMFDeviceManagerDeviceModeliPhone4, @"iPhone3,1",
                           kCMFDeviceManagerDeviceModeliPhone4, @"iPhone3,2",
                           kCMFDeviceManagerDeviceModeliPhone4, @"iPhone3,3",
                           kCMFDeviceManagerDeviceModeliPhone4S, @"iPhone4,1",
                           kCMFDeviceManagerDeviceModeliPhone5, @"iPhone5,1",
                           kCMFDeviceManagerDeviceModeliPhone5, @"iPhone5,2",
                           kCMFDeviceManagerDeviceModeliPhone5C, @"iPhone5,3",
                           kCMFDeviceManagerDeviceModeliPhone5C, @"iPhone5,4",
                           kCMFDeviceManagerDeviceModeliPhone5S, @"iPhone6,1",
                           kCMFDeviceManagerDeviceModeliPhone5S, @"iPhone6,2",
                           kCMFDeviceManagerDeviceModeliPhone6, @"iPhone7,2",
                           kCMFDeviceManagerDeviceModeliPhone6Plus, @"iPhone7,1",
                           kCMFDeviceManagerDeviceModeliPad2, @"iPad2,1",
                           kCMFDeviceManagerDeviceModeliPad2, @"iPad2,2",
                           kCMFDeviceManagerDeviceModeliPad2, @"iPad2,3",
                           kCMFDeviceManagerDeviceModeliPad2, @"iPad2,4",
                           kCMFDeviceManagerDeviceModeliPad3, @"iPad3,1",
                           kCMFDeviceManagerDeviceModeliPad3, @"iPad3,2",
                           kCMFDeviceManagerDeviceModeliPad3, @"iPad3,3",
                           kCMFDeviceManagerDeviceModeliPad4, @"iPad3,4",
                           kCMFDeviceManagerDeviceModeliPad4, @"iPad3,5",
                           kCMFDeviceManagerDeviceModeliPad4, @"iPad3,6",
                           kCMFDeviceManagerDeviceModeliPadAir, @"iPad4,1",
                           kCMFDeviceManagerDeviceModeliPadAir, @"iPad4,2",
                           kCMFDeviceManagerDeviceModeliPadAir, @"iPad4,3",
                           kCMFDeviceManagerDeviceModeliPadAir2, @"iPad5,1",
                           kCMFDeviceManagerDeviceModeliPadAir2, @"iPad5,3",
                           kCMFDeviceManagerDeviceModeliPadAir2, @"iPad5,4",
                           kCMFDeviceManagerDeviceModeliPadMini, @"iPad4,7",
                           kCMFDeviceManagerDeviceModeliPadMini, @"iPad4,8",
                           kCMFDeviceManagerDeviceModeliPadMini, @"iPad4,9",
                           kCMFDeviceManagerDeviceModeliPhone6S, @"iPhone8,2",
                           kCMFDeviceManagerDeviceModeliPhone6SPlus, @"iPhone8,1",
                           kCMFDeviceManagerDeviceModeliPhoneSE, @"iPhone8,4",
                           kCMFDeviceManagerDeviceModeliPhone7, @"iPhone9,1",
                           kCMFDeviceManagerDeviceModeliPhone7Plus, @"iPhone9,2",
                           kCMFDeviceManagerDeviceModeliPhone7, @"iPhone9,3",
                           kCMFDeviceManagerDeviceModeliPhone7Plus, @"iPhone9,4",
                           nil];
        //Unique ID
        NSString * serviceName = ([[NSBundle mainBundle] bundleIdentifier]) ? [[NSBundle mainBundle] bundleIdentifier] : @"CPqDASR";
        self.service = serviceName;
        self.key = kKeyIdentifier;
        self.value = [self createUUID];
    }
    return self;
}

- (NSString *)deviceModel
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    NSString * deviceModel;
    @try {
        deviceModel = [self.deviceList objectForKey:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    }
    @catch (NSException *exception) {
        //ignore
    }
    return deviceModel;
}

- (NSString *)deviceManufacturer
{
    return kCMFDeviceManagerDeviceManufacturer;
}

- (NSString *)platform
{
    //return [UIDevice currentDevice].systemName;
    return [[kCMFDeviceManagerPlatformString componentsSeparatedByString:@"|"] firstObject];
}

- (NSString *)platformVersion
{
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *)platformAndModel
{
    return [NSString stringWithFormat:@"%@%@", kCMFDeviceManagerPlatformString,[self deviceModel]];
}

#pragma mark -
#pragma mark - Unique identifier methods

- (NSString *)getIdentifierFromKeyChain{
    NSDictionary *query = @{
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrService : self.service,
                            (__bridge id)kSecAttrAccount : self.key,
                            (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue,
                            };
    CFDataRef cfValue = NULL;
    NSString *valueStored;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                          (CFTypeRef *)&cfValue);
    if (status == errSecSuccess){
        NSString *value = [[NSString alloc]
                           initWithData:(__bridge  NSData *)cfValue
                           encoding:NSUTF8StringEncoding];
        valueStored = value;
    }else if(status == errSecItemNotFound){
        //Item was not found
        valueStored = @"";
    }
    else{
        [CPqDASRLog logMessage:[NSString stringWithFormat:@"Error happened with code: %ld", (long)status]];
    }
    return valueStored;
}

- (BOOL)isUUIDStoredInKeyChain{
    if ([[self getIdentifierFromKeyChain] isEqualToString:@""]) {
        return NO;
    }
    else{
        return YES;
    }
    return NO;
}
- (BOOL)storeUUIDInKeyChain{
    NSString *valueIdentifier = self.value;
    NSData *valueDataIdentifier = [valueIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *secItem = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                              (__bridge id)kSecAttrService: self.service,
                              (__bridge id)kSecAttrAccount: self.key,
                              (__bridge id)kSecValueData: valueDataIdentifier
                              };
    CFTypeRef result = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)secItem, &result);
    if (status == errSecSuccess) {
        [CPqDASRLog logMessage:@"UUID stored in the keychain!!"];
        return YES;
    }else{
        [CPqDASRLog logMessage:@"Error while storing in the keychain"];
        return NO;
    }
    return NO;
}
- (BOOL)updateUUIDWithNewUUID:(NSUUID *)newUUID andComment:(NSString *)comment{
    NSDictionary *query = @{
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrService : self.service,
                            (__bridge id)kSecAttrAccount : self.key,
                            };
    
    OSStatus found = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                         NULL);
    BOOL updateResult = NO;
    if (found == errSecSuccess){
        NSData *newData = [[NSString stringWithFormat:@"%@", newUUID] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *update = @{
                                 (__bridge id)kSecValueData : newData,
                                 (__bridge id)kSecAttrComment :comment};
        OSStatus updated = SecItemUpdate((__bridge CFDictionaryRef)query,
                                         (__bridge CFDictionaryRef)update);
        if (updated == errSecSuccess){
            updateResult = YES;
        }
    }
    return updateResult;
}
- (BOOL)deleteUUIDFromKeyChain{
    BOOL status = NO;
    NSDictionary *query = @{
                            (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrService : self.service,
                            (__bridge id)kSecAttrAccount : self.key
                            };
    OSStatus foundExisting =
    SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (foundExisting == errSecSuccess){
        OSStatus deleted = SecItemDelete((__bridge CFDictionaryRef)query);
        if (deleted == errSecSuccess){
            status = YES;
            [CPqDASRLog logMessage:@"Successfully deleted the item"];
        }else{
            [CPqDASRLog logMessage:@"Failed to deleted the item"];
        }
    }else{
        status = NO;
        [CPqDASRLog logMessage:@"Did not find the existing value"];
    }
    return status;
}
- (NSString *)createUUID{
    NSUUID *UUID = [[UIDevice currentDevice]identifierForVendor];
    return [UUID UUIDString];
}




@end
