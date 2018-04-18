//
//  CPqDASRRecognitionStatus.h
//  CPqDASR
//
//  Created by rodrigomorbach on 09/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#ifndef CPqDASRRecognitionStatus_h
#define CPqDASRRecognitionStatus_h

/*!
 @brief Possible recognition status
 */
typedef NS_ENUM(NSInteger, CPqDASRRecognitionStatus)
{
    CPqDASRRecognitionStatusRecognized = 0,
    CPqDASRRecognitionStatusProcessing = 1,
    CPqDASRRecognitionStatusNoMatch,
    CPqDASRRecognitionStatusNoInputTimeout,
    CPqDASRRecognitionStatusMaxSpeech,
    CPqDASRRecognitionStatusEarlySpeech,
    CPqDASRRecognitionStatusRecognitionTimeout,
    CPqDASRRecognitionStatusNoSpeech,
    CPqDASRRecognitionStatusCanceled,
    CPqDASRRecognitionStatusFailure = 100
};


#endif /* CPqDASRRecognitionStatus_h */
