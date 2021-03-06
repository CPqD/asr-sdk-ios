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


#import <Foundation/Foundation.h>

#import <CPqDASR/CPqDASRRecognitionStatus.h> 

@interface CPqDASRRecognitionResultWord : NSObject

@property (nonatomic, copy) NSString * text;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) NSTimeInterval endTime;

@end

@interface CPqDASRRecognitionResultAlternative : NSObject

/*!
 @brief The recognized text
 */
@property (nonatomic, strong) NSString * text;

/*!
 @brief The score of this alternative
 */
@property (nonatomic, assign) NSInteger score;

/*!
 @brief Possible interpretations
 */
@property (nonatomic, strong) NSArray * interpretations;

/** the language model considered in the recognition. */
@property (nonatomic, strong) NSString * languageModel;

@property (nonatomic, strong) NSArray <CPqDASRRecognitionResultWord *> * words;

@end

@interface CPqDASRRecognitionResult : NSObject

/*!
 @brief Possible alternatives. First one is the most accurate.
 */
@property (nonatomic, strong) NSArray <CPqDASRRecognitionResultAlternative *> * alternatives;

/*!
 @brief Recognition status.
 */
@property (nonatomic, assign) CPqDASRRecognitionStatus status;

/** the speech segment index. */
@property (nonatomic, assign) NSInteger speechSegmentIndex;

/**
 * indicates if this is the last recognized segment.
 */
@property (nonatomic, assign) BOOL lastSpeechSegment;

/** the audio position when the speech start was detected (in secs). */
@property (nonatomic, assign) NSTimeInterval startTime;

/** the audio position when the speech stop was detected (in secs). */
@property (nonatomic, assign) NSTimeInterval endTime;

@end
