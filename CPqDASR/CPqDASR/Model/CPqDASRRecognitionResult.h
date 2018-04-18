//
//  CPqDASRRecognitionResult.h
//  CPqDASRApp
//
//  Created by rodrigomorbach on 03/11/16.
//  Copyright © 2016 CPqD. All rights reserved.
//

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
