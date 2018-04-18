//
//  CPqDASRSpeechRecognizerBuilder.m
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

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
        _recognitionDelegate = delegate;
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

- (CPqDASRSpeechRecognizerBuilder *)recognitionDelegate:(id<CPqDASRRecognitionDelegate>)delegate {
    _recognitionDelegate = delegate;
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

- (CPqDASRSpeechRecognizer *)build {
    return [[CPqDASRSpeechRecognizer alloc] initWithBuilder: self];
}






@end
