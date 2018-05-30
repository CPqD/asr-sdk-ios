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


#import <CPqDASR/CPqDASRSpeechRecognizerBuilder.h>
#import <CPqDASR/CPqDASRSpeechRecognizer.h>
#import <CPqDASR/CPqDASRRecognitionDelegate.h>
#import <CPqDASR/CPqDASRLanguageCode.h>
#import "CPqDASRLog.h"


@interface CPqDASRSpeechRecognizerBuilder()

@end

@implementation CPqDASRSpeechRecognizerBuilder

- (instancetype)init {
    if( self = [super init] ){
        [CPqDASRLog logMessage:@"CPqDASRSpeechRecognizerBuilder default init called"];
        //Defines default configuration parameters
        _audioSampleRate = CPqDASRSampleRate8K;
        _chunkLength = 250;
        _serverRTF = 0.1f;
        _maxSessionIdleSeconds = 30;
        _connectOnRecognize = false;
        _autoClose = false;
        _recognitionDelegates = [[NSArray alloc] init];
        _recognizerDelegateQueue = dispatch_get_main_queue();
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url
                  userAgent:(NSString *)userAgent
                credentials:(NSArray *)credentials
                   delegate:(id<CPqDASRRecognitionDelegate>)delegate{
    if(self = [[CPqDASRSpeechRecognizerBuilder alloc] init]){
        _url = [NSURL URLWithString:url];
        _credentials = credentials;
        _recognitionDelegates = [NSArray arrayWithObject:delegate];
        _userAgent = userAgent;
    }
    return self;
}


- (void)dealloc {
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"%@ called", NSStringFromClass([CPqDASRSpeechRecognizerBuilder class])]];
}

#pragma mark -
#pragma mark - Public methods

- (CPqDASRSpeechRecognizerBuilder *)serverUrl:(NSString *)url{
    _url = [NSURL URLWithString:url];    
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)userAgent:(NSString *)userAgent{
    _userAgent = userAgent;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)userName:(NSString *)user password:(NSString *)password {
    NSMutableArray * serviceCredentials = [NSMutableArray arrayWithObjects:user, password, nil];
    _credentials = [NSArray arrayWithArray: serviceCredentials];
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)audioSampleRate:(CPqDASRSampleRate)sampleRate{
    _audioSampleRate = sampleRate;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)autoClose:(BOOL)autoClose{
    _autoClose = autoClose;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)maxSessionIdleSeconds:(NSInteger)maxSessionIdleSeconds {
    _maxSessionIdleSeconds = maxSessionIdleSeconds;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)connectOnRecognize:(BOOL)connectOnRecognize{
    _connectOnRecognize = connectOnRecognize;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)addRecognitionDelegate:(id<CPqDASRRecognitionDelegate>)delegate {
    
    if (delegate == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"CPqDASRRecognitionDelegate can not be null" userInfo:nil];
    }
    
    NSMutableArray <id<CPqDASRRecognitionDelegate>> * delegates = [[NSMutableArray alloc] initWithArray:_recognitionDelegates];
    [delegates addObject:delegate];
    
    _recognitionDelegates = [NSArray arrayWithArray:delegates];
    
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)recogConfig:(CPqDASRRecognitionConfig *)config {
    _recogConfig = config;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)language:(CPqDASRLanguageCode *)language {
    _language = language;
    return self;
}

- (CPqDASRSpeechRecognizerBuilder *)recognizerDelegateDispatchQueue:(dispatch_queue_t)delegateQueue {
    _recognizerDelegateQueue = delegateQueue;
    return self;
}

- (CPqDASRSpeechRecognizer *)build {
    return [[CPqDASRSpeechRecognizer alloc] initWithBuilder: self];
}

@end
