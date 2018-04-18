//
//  CPqDASRLanguage.m
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import "CPqDASRLanguageCode.h"

@interface CPqDASRLanguageCode()

@property (nonatomic, assign) CPqDASRLanguage language;

@property (nonatomic, strong) NSSet * languageString;

@end

NSString *const kCPqDASRLanguageCodePtBr = @"pt-BR";
NSString *const kCPqDASRLanguageCodeEsLatam = @"es-x-latam";

@implementation CPqDASRLanguageCode

- (instancetype)initWithLanguage:(CPqDASRLanguage)language{
    if(self = [super init]){
        self.language = language;
        self.languageString = [NSSet setWithObjects:kCPqDASRLanguageCodePtBr, kCPqDASRLanguageCodeEsLatam, nil];
    }
    return self;
}

- (NSString *)value {
    NSArray * languages = self.languageString.allObjects;
    return [languages objectAtIndex:self.language];
}

@end
