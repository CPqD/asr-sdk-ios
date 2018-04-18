//
//  CPqDASRSpeechRecognizer.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRSpeechRecognizerProtocol.h>
#import <CPqDASR/CPqDASRAudioSource.h>
@class CPqDASRSpeechRecognizerBuilder;

@interface CPqDASRSpeechRecognizer : NSObject <CPqDASRSpeechRecognizerProtocol, CPqDASRAudioSourceDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBuilder:(CPqDASRSpeechRecognizerBuilder *)builder;

@end
