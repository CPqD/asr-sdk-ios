//
//  CPqDASRSpeechRecognizer.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#ifndef CPqDASRSpeechRecognizerProtocol_h
#define CPqDASRSpeechRecognizerProtocol_h

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRAudioSource.h>
#import <CPqDASR/CPqDASRLanguageModelList.h>
#import <CPqDASR/CPqDASRRecognitionConfig.h>

@protocol CPqDASRSpeechRecognizerProtocol <NSObject>

@required
/**
 @brief Release resources and close the server connection.
 */
- (void)close;

- (void)cancelRecognition;

- (void)recognize:(id<CPqDASRAudioSource>)audioSource languageModel:(CPqDASRLanguageModelList *)lm;

@optional
- (void)recognize:(id<CPqDASRAudioSource>)audioSource languageModel:(CPqDASRLanguageModelList *)lm recogConfig:(CPqDASRRecognitionConfig *)recogConfig;

@end




#endif /* CPqDASRSpeechRecognizerProtocol_h */
