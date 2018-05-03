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
