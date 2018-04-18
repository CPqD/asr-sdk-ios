//
//  CPqDASRDeviceManager.h
//  CPqDASR
//
//  Created by rodrigomorbach on 29/03/16.
//  Copyright © 2016 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kCMFDeviceManagerDeviceModeliPhone4;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone4S;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone5;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone5C;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone5S;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone6;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone6Plus;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone6S;
extern NSString * const kCMFDeviceManagerDeviceModeliPhone6SPlus;
extern NSString * const kCMFDeviceManagerDeviceModeliPad2;
extern NSString * const kCMFDeviceManagerDeviceModeliPad3;
extern NSString * const kCMFDeviceManagerDeviceModeliPad4;
extern NSString * const kCMFDeviceManagerDeviceModeliPadAir;
extern NSString * const kCMFDeviceManagerDeviceModeliPadAir2;
extern NSString * const kCMFDeviceManagerDeviceModeliPadMini;


@interface CPqDASRDeviceManager : NSObject

//Unique Identifier

/*!
 @brief The service used to store the value in the keychain
 */
@property (readwrite,retain) NSString *service;

@property (readwrite,retain) NSString *value;

/*
 @brief This is the identifierForVender
 */
@property (readwrite,retain) NSString *key;

/*!
 @brief Singleton object.
 */
+ (instancetype)sharedDeviceManager;
/*!
 @brief return the string information of the device model
 */
- (NSString *)deviceModel;

/*!
 @brief return the string information of the device manufacturer
 */
- (NSString *)deviceManufacturer;
/*!
 @brief The platform information. The standard is iOS
 */
- (NSString *)platform;
/*!
 @brief The platform version information. The pattern e.g. 7.0.x
 */
- (NSString *)platformVersion;

/*!
 @brief The platform information. The standard is iOS|deviceModel
 */
- (NSString *)platformAndModel;

//Unique identifier

- (NSString *)getIdentifierFromKeyChain;

/*!
 @brief check if the unique identifier is in the keychain
 */
- (BOOL)isUUIDStoredInKeyChain;

/*!
 @brief store the unique identifier in the keychain
 */
- (BOOL)storeUUIDInKeyChain;

/*!
 @brief update the unique identifier in the keychain
 */
- (BOOL)updateUUIDWithNewUUID:(NSUUID *)newUUID andComment:(NSString *)comment;

/*!
 @brief remove the unique identifier from the keychain
 */
- (BOOL)deleteUUIDFromKeyChain;




@end
