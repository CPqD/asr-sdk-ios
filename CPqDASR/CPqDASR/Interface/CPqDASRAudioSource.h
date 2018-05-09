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

#ifndef CPqDASRAudioSource_h
#define CPqDASRAudioSource_h

#import <Foundation/Foundation.h>

/**
 * @brief Recognizer must implement this delegate in order to be notified about new incoming data from audio source.
 */
@protocol CPqDASRAudioSourceDelegate <NSObject>

/**
 * @brief Notify the recognizer that there are data to be recognized.
 */
- (void)audioSourceHasDataAvailable;

@end

/**
 * @brief Represents an audio input source for the recognition process.
 */
@protocol CPqDASRAudioSource <NSObject>

/**
 * Reads data from the source.
 */
- (NSData *)read;

/**
 * Closes the source and releases any system resources associated.
 */
- (void)close;

/**
 * Informs that the audio is finished. Forces any buffered output bytes to
 * be written out.
 */
- (void)finish;

@optional

/**
 * Optional. Starts audio source recording or configuration, if necessary.
 */
- (void)start;

@required
/**
 @brief CPqDASRSpeechRecognizer will reference this property to get data
 */
@property (nonatomic, weak) id<CPqDASRAudioSourceDelegate> delegate;
@end

#endif /* CPqDASRAudioSource_h */
