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
#import <CPqDASR/CPqDASRRecognitionDelegate.h>
#import <CPqDASR/CPqDASRLanguageCode.h>
#import <CPqDASR/CPqDASRSampleRate.h>
#import <CPqDASR/CPqDASRRecognitionConfig.h>

@class CPqDASRSpeechRecognizer;

@interface CPqDASRSpeechRecognizerBuilder : NSObject

/**
 User agent
 */
@property (nonatomic, strong, readonly) NSString * userAgent;

/**
 ASR Server URL
 */
@property (nonatomic, strong, readonly) NSURL * url;

/**
 Credentials
 */
@property (nonatomic, strong, readonly) NSArray * credentials;

/**
 Recognition listener
 */
@property (nonatomic, readonly) NSArray<id<CPqDASRRecognitionDelegate>> * recognitionDelegates;

/**
 Capture sample rate
 */
@property (nonatomic, assign, readonly) CPqDASRSampleRate audioSampleRate;

/**
 Language
 */
@property (nonatomic, strong, readonly) CPqDASRLanguageCode * language;

/** the audio packets length. */
@property (nonatomic, assign, readonly) NSInteger chunkLength;

/** the server Real Time Factor. */
@property (nonatomic, assign, readonly) NSInteger serverRTF;

/**
 * If set to true, the ASR session is created at each recognition.
 * Otherwise, it is created when the SpeechRecognizer instance is built.
 */
@property (nonatomic, assign, readonly) BOOL connectOnRecognize;

/**
 * If set to true, the ASR session is automatically closed at the end of
 * each recognition. Otherwise, it is kept open, available for further
 * recognitions.
 */
@property (nonatomic, assign, readonly) BOOL autoClose;

/** The maximum time the ASR session is kept open and idle. */
@property (nonatomic, assign, readonly) NSInteger maxSessionIdleSeconds;


/** The recognition configuration parameters. */
@property (nonatomic, strong, readonly) CPqDASRRecognitionConfig * recogConfig;

/** Dispatch Queue for recognizer delegate **/
@property (nonatomic, readonly) dispatch_queue_t recognizerDelegateQueue;

- (CPqDASRSpeechRecognizer *)build;

- (instancetype)initWithURL:(NSString *)url
                userAgent:(NSString *)userAgent
                credentials:(NSArray *)credentials
                   delegate:(id<CPqDASRRecognitionDelegate>)delegate;

/**
 * Defines the Server URL.
 *
 * @param url
 *            the ASR Server endpoint URL (e.g.:
 *            ws://192.168.100.1:8025/asr-server).
 * @return the Builder object
 */
- (CPqDASRSpeechRecognizerBuilder *)serverUrl:(NSString *)url;

/**
 * Sets user access credentials, if required by the server.
 *
 * @param user
 *            user id.
 * @param password
 *            password.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)userName:(NSString *)user password:(NSString *)password;

/**
 * Configure the recognition parameters.
 *
 * @param config
 *            the configuration parameters.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)recogConfig:(CPqDASRRecognitionConfig *)config;

/**
 * Register a call back listener interface.
 *
 * @param delegate
 *            the listener object.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)addRecognitionDelegate:(id<CPqDASRRecognitionDelegate>)delegate;


/**
 * Sets the connect on recognize property. If set to true, the ASR
 * session is automatically created at each recognition. Otherwise, it
 * is created when the SpeechRecognizer is built.
 *
 * @param connectOnRecognize
 *            the connectOnRecognize property value.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)connectOnRecognize:(BOOL)connectOnRecognize;

/**
 * Sets the auto close property. If set to true, the ASR session is
 * automatically closed at the end of each recognition. Otherwise, it is
 * kept open for the next recognition.
 *
 * @param autoClose
 *            the autoClose property value.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)autoClose:(BOOL)autoClose;


/**
 * Sets the maximum session idle time.
 *
 * @param maxSessionIdleSeconds
 *            the max session idle time in seconds.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)maxSessionIdleSeconds:(NSInteger)maxSessionIdleSeconds;

/**
 * Sets the audio sample rate (in bps).
 *
 * @param sampleRate
 *            the audio sample rate.
 * @return the Builder object.
 * @todo for future use
 */
- (CPqDASRSpeechRecognizerBuilder *)audioSampleRate:(CPqDASRSampleRate)sampleRate;

/**
 * Sets the user agent data. This information indicates the
 * characteristics of the client for logging and debug purposes.
 *
 * @param userAgent
 *            the user agent data.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)userAgent:(NSString *)userAgent;

/**
 *
 * Sets the audio language.
 *
 * @param language
 *            the audio language.
 * @return the Builder object.
 *
 * @todo for future use
 */
- (CPqDASRSpeechRecognizerBuilder *)language:(CPqDASRLanguageCode *)language;

/**
 *
 * Sets Recognizer delegate Queue. By default, this will be dispatch_main_queue.
 *
 *
 * @param delegateQueue
 *            queue to dispatch recognition related events.
 * @return the Builder object.
 */
- (CPqDASRSpeechRecognizerBuilder *)recognizerDelegateDispatchQueue:(dispatch_queue_t)delegateQueue;

@end
