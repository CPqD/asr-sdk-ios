//
//  CPqDASRRecognitionDelegate.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#ifndef CPqDASRRecognitionDelegate_h
#define CPqDASRRecognitionDelegate_h

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRRecognitionResult.h>
#import <CPqDASR/CPqDASRRecognitionError.h>

/**
 *@brief Asynchronous callback interface to receive speech recognition events from the
 * server.
 *
 */
@protocol CPqDASRRecognitionDelegate <NSObject>
/**
 * @brief Called when the server is ready to recognize and is listening for audio
 */
- (void)cpqdASRDidStartListening;

/**
 @brief Called when the server detects start of speech in the audio samples.
 @discussion The
 server keeps on listening for audio packets and performing the speech
 recognition.
 @param time when speech has started
 */
- (void)cpqdASRDidStartSpeech:(NSTimeInterval)time;

/**
 * @brief Called when the server detects the end of speech in the audio samples.
 * @discussion The server stops listening and process the final recognition result.
 *
 * @param time
 *            the audio position when the speech stop was detected (in
 *            milis).
 */
- (void)cpqdASRDidStopSpeech:(NSTimeInterval)time;

/**
 * @brief Called when the server generates a partial recognition result.
 *
 * @param result
 *            the recognition result.
 */
- (void)cpqdASRDidReturnPartialResult:(CPqDASRRecognitionResult *)result;

/**
 * @brief Called when the server generates a recognition result.
 *
 * @param result
 *            the recognition result.
 */
- (void)cpqdASRDidReturnFinalResult:(CPqDASRRecognitionResult *)result;

/**
 * @brief Called when an error in the recognition process occurs.
 *
 * @param error
 *            the error object.
 */
- (void)cpqdASRDidFailWithError:(CPqDASRRecognitionError *)error;

@end

#endif /* CPqDASRRecognitionDelegate_h */
