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


#import "CPqDASRSpeechRecognizer.h"
#import "CPqDASRClientEndpoint.h"
#import "CPqDASRLog.h"
#import "CPqDASRMicAudioSource.h"
#import "CPqDASRProtocol.h"
#import <CPqDASR/CPqDASRSpeechRecognizerBuilder.h>


@interface CPqDASRSpeechRecognizer() <CPqDASRRecognitionDelegate, CPqDASRClientEndpointDelegate>

@property (nonatomic, strong) CPqDASRSpeechRecognizerBuilder * builder;

@property (nonatomic, strong) dispatch_queue_t recognizerQueue;

@property (nonatomic, strong) CPqDASRClientEndpoint * asrClientEndpoint;

@property (nonatomic, strong) id<CPqDASRAudioSource> audioSource;

@property (nonatomic, strong) NSString * handle;

@property (nonatomic, strong) CPqDASRLanguageModelList * languageModelList;

@property (nonatomic, strong) CPqDASRRecognitionConfig * startRecognitionConfig;

@property (nonatomic, assign) BOOL shouldStartRecognition;

@end

@implementation CPqDASRSpeechRecognizer

- (instancetype)initWithBuilder:(CPqDASRSpeechRecognizerBuilder *)builder {
    
    if (builder == nil){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"builder can not be null" userInfo:nil];
    }
    if (self = [super init]) {
        
        self.builder = builder;
        
        self.recognizerQueue = dispatch_queue_create("com.cpqd.recognizerQueue", DISPATCH_QUEUE_SERIAL);
        
        self.asrClientEndpoint = [[CPqDASRClientEndpoint alloc] initWithURL:builder.url dispatchQueue:self.recognizerQueue credentials: self.builder.credentials];
        
        [self.asrClientEndpoint setRecognitionDelegate:self];
        
        [self.asrClientEndpoint setWSDelegate:self];
        
        [self.asrClientEndpoint setSessionTimeout:self.builder.maxSessionIdleSeconds];
        
        [CPqDASRLog logMessage:@"CPqDASRClientEndpoint created"];
                        
        if (self.builder.recognitionDelegate == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"recognitionDelegate can not be null" userInfo:nil];
        }
        self.shouldStartRecognition = YES;
        if (!self.builder.connectOnRecognize) {
            self.shouldStartRecognition = NO;
            [self open];
        }
    }
    
    return self;
}

- (void)dealloc {
    [CPqDASRLog logMessage:@"CPqDASRSpeechRecognizer dealloc called"];
}

#pragma mark -
#pragma mark - Private methods

- (void)open {
    
    self.handle = nil;
    
    [CPqDASRLog logMessage:@"trying to open connection"];
    
    __weak CPqDASRSpeechRecognizer * weakSelf = self;
    
    [self.asrClientEndpoint openWithBlock:^(BOOL success) {
        if (success) {
            [weakSelf createSession];
        }
    }];
}

- (void)startRecognition {
    
    if ([self.asrClientEndpoint getStatus] == ASRSessionStatusListening) {
        
        [CPqDASRLog logMessage:@"startRecognition status is already listening"];
        return;
    }
    
    ASRStartRecognition * startRecognitionRequest = [[ASRStartRecognition alloc] init];
    
    LanguageModel * languageModel = [[LanguageModel alloc] init];
    if (self.languageModelList != nil) {
        if (self.languageModelList.uriList.count > 0) {
            languageModel.uri = [self.languageModelList.uriList objectAtIndex:0];
        } else if (self.languageModelList.grammarList.count > 0){
            NSArray * grammar = [self.languageModelList.grammarList objectAtIndex:0];
            //First index is Id
            languageModel._id = [grammar objectAtIndex:0];
            //Second is definition
            languageModel.definition = [grammar objectAtIndex:1];
        }
    }
    
    startRecognitionRequest.languageModel = languageModel;
    
    if (self.startRecognitionConfig != nil) {
        startRecognitionRequest.parameters = [self.startRecognitionConfig getParametersMap];
    }
    
    startRecognitionRequest.handle = self.handle;
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"\nStart Recognition: %@", [startRecognitionRequest createMessage]]];
    [self.asrClientEndpoint sendMessage:startRecognitionRequest];
}

- (void)startRecording {
    if ([self.audioSource respondsToSelector:@selector(start)]){
        [self.audioSource start];
    }    
}

- (void)createSession {
    ASRCreateSession * createSessionRequest = [[ASRCreateSession alloc]init];
    
    if (self.builder.userAgent) {
        createSessionRequest.userAgent = self.builder.userAgent;
    }
    
    __weak CPqDASRSpeechRecognizer * weakSelf = self;
    
    [self.asrClientEndpoint sendMessage:createSessionRequest withCompletionBlock:^(ASRMessage *responseMessage) {
        
        if (!weakSelf.shouldStartRecognition) {
            return;
        }
        
        ASRResponseMessage * response = (ASRResponseMessage *)responseMessage;
        
        if ([response.method isEqualToString:kASRProtocolCreateSession] && [response.result isEqualToString:kASRProtocolResponseResultSuccess]) {
            //Section created
            if(weakSelf.builder.recogConfig != nil) {
                [weakSelf setRecognitionParameters:weakSelf.builder.recogConfig];
            }
            [weakSelf startRecognition];
        }
        
    }];
}

- (void)sendAudio:(NSData *)data isLastPacket:(BOOL)lastPacket {
    
    if ( [self.asrClientEndpoint getStatus] != ASRSessionStatusListening ) {
        return;
    }
    
    ASRSendAudio * sendAudioRequest = [[ASRSendAudio alloc]init];
    sendAudioRequest.lastPacket = lastPacket;
    sendAudioRequest.contentlength = [NSString stringWithFormat:@"%ld", (long)[data length]];
    sendAudioRequest.contentType = @"application/octet-stream";
    sendAudioRequest.payload = data;
    sendAudioRequest.handle = self.handle;
    
    [self.asrClientEndpoint sendMessage:sendAudioRequest];;
    
    if (lastPacket) {
        dispatch_async( dispatch_get_main_queue() , ^{
            //TODO - call didStop here?
            //[self.builder.recognitionDelegate cpqdASRDidStopSpeech:0];
        });
    }
}

- (void)setRecognitionParameters:(CPqDASRRecognitionConfig *)parameters {
    ASRSetParametersMessage * setParametersMessage = [[ASRSetParametersMessage alloc] init];
    [setParametersMessage setRecognitionParameters: [parameters getParametersMap]];
    setParametersMessage.handle = self.handle;
    
    [self.asrClientEndpoint sendMessage:setParametersMessage];
}

#pragma -
#pragma mark - CPqDASRSpeechRecognizerProtocol methods

- (void)recognize:(id<CPqDASRAudioSource>)audioSource languageModel:(CPqDASRLanguageModelList *)lm {
    [self recognize:audioSource languageModel:lm recogConfig:nil];
}

- (void)recognize:(id<CPqDASRAudioSource>)audioSource languageModel:(CPqDASRLanguageModelList *)lm recogConfig:(CPqDASRRecognitionConfig *)recogConfig{
    
    self.audioSource = audioSource;    
    self.audioSource.delegate = self;
    
    self.languageModelList = lm;
    
    self.startRecognitionConfig = recogConfig;
    
    if (!self.asrClientEndpoint.isOpen) {
        self.shouldStartRecognition = YES;
        [self open];
    } else {
        [self startRecognition];
    }
}

- (void)close {
    
    [self.audioSource close];
    if(![self.asrClientEndpoint isOpen]){
        return;
    }
    
    ASRReleaseSession * releaseSession = [[ASRReleaseSession alloc] init];
    releaseSession.handle = self.handle;
    [self.asrClientEndpoint sendMessage:releaseSession];
}

- (void)cancelRecognition {
    if(!self.asrClientEndpoint.isOpen){
        return;
    }
    if (self.asrClientEndpoint.getStatus == ASRSessionStatusListening
        || self.asrClientEndpoint.getStatus == ASRSessionStatusRecognizing) {
        ASRCancelRecognition * cancelRecognition = [[ASRCancelRecognition alloc] init];
        cancelRecognition.handle = self.handle;
        [self.asrClientEndpoint sendMessage:cancelRecognition];
    }
}


#pragma mark -
#pragma mark - CPqDASRAudioSourceDelegate

- (void)audioSourceHasDataAvailable {
    [CPqDASRLog logMessage:@"audioSourceHasDataAvailable called"];
    dispatch_async( self.recognizerQueue , ^{
        NSData * data;
        @synchronized (self) {
             data = [self.audioSource read];
        }
        if(data.length > 0){
            [self sendAudio:data isLastPacket:NO];
        } else {
            [self sendAudio:data isLastPacket:YES];
        }
    });
}

#pragma mark -
#pragma mark - CPqDASRRecognitionDelegate methods

- (void)cpqdASRDidFailWithError:(CPqDASRRecognitionError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:@"\n\nCPqDASR - cpqdASRDidFailWithError ---"];
        [self.builder.recognitionDelegate cpqdASRDidFailWithError:error];
        if(self.builder.autoClose){
            [self close];
        }
    });
}

- (void)cpqdASRDidReturnFinalResult:(CPqDASRRecognitionResult *)result {
    //Stop recording
    [self.audioSource finish];
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:[NSString stringWithFormat:@"\n\nCPqDASR - cpqdASRDidReturnFinalResult --- %ld", (long)result.status]];
        [self.builder.recognitionDelegate cpqdASRDidReturnFinalResult:result];
    });
}

- (void)cpqdASRDidReturnPartialResult:(CPqDASRRecognitionResult *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:@"\n\nCPqDASR - cpqdASRDidReturnPartialResult ---"];
        [self.builder.recognitionDelegate cpqdASRDidReturnPartialResult:result];
    });
}

- (void)cpqdASRDidStartListening {
    [self startRecording];
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:@"\n\nCPqDASR - cpqdASRDidStartListening ---"];
        [self.builder.recognitionDelegate cpqdASRDidStartListening];
    });
}

- (void)cpqdASRDidStartSpeech:(NSTimeInterval)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:@"\n\nCPqDASR - cpqdASRDidStartSpeech ---"];
        [self.builder.recognitionDelegate cpqdASRDidStartSpeech:time];
    });
}

- (void)cpqdASRDidStopSpeech:(NSTimeInterval)time {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CPqDASRLog logMessage:@"\n\nCPqDASR - cpqdASRDidStopSpeech ---"];
        [self.audioSource finish];
        [self.builder.recognitionDelegate cpqdASRDidStopSpeech:time];
    });
}

#pragma mark -
#pragma mark - CPqDASRClientEndpointDelegate methods

- (void)asrClientEndpointConnectionDidOpen {
    //[self createSession];
}


@end
