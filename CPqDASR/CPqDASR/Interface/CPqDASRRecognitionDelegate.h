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
