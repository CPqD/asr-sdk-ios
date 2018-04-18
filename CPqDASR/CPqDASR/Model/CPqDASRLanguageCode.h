//
//  CPqDASRLanguage.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, CPqDASRLanguage){
    CPqDASRLanguagePortuguese = 0,
    CPqDASRLanguageSpanishLatam
};

@interface CPqDASRLanguageCode : NSObject

- (id)init NS_UNAVAILABLE;

- (instancetype)initWithLanguage:(CPqDASRLanguage)language;

- (NSString *)value;

@end
