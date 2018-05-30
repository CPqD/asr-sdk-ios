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


#import "CPqDASRMicAudioSource.h"
#include "zc-e.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "CPqDASRLog.h"

typedef NS_ENUM(NSInteger, CPqDASRAudioState)
{
    CPqDASRAudioStateStopped = 0,
    CPqDASRAudioStateRecording,
    CPqDASRAudioStateError
};

@interface CPqDASRMicAudioSource ()

@property (nonatomic, assign) BOOL isLastPacket;

@property (nonatomic, assign) BOOL silenceDetectionEnabled;

@property (nonatomic, assign) BOOL mainBufferSent;

@property (nonatomic, assign) CPqDASRAudioState audioState;

@property (nonatomic, assign) CPqDASRSampleRate audioSampleRate;

@property (nonatomic, strong) NSData * availableData;

@property (nonatomic, weak) id<CPqDASRMicAudioSourceDelegate> micDelegate;

@end

@implementation CPqDASRMicAudioSource {
    //ZC
    // Buffer principal, onde sao guardadas todas as amostras.
    
    void *mainBuffer;
    
    // Numero de bytes validos no buffer principal.  Variavel funciona como offset.
    
    unsigned int mainBufferOffset;
    
    // Vetor de valores zero cross, necessario para se detectar fim de fala.
    
    int *zero_cross_vector;
    
    // Posicao para o primeiro elemento nao valido do vetor de zero cross.
    
    unsigned int zero_cross_vector_position;
    
    // Variavel para armazenar dados relevantes durante o uso do Audio Queue.
    
    struct AQRecorderState * _aqData;
    
    // Variável para restringir a execução de código apenas uma vez após reconhecimento de fim de fala.
    BOOL wasEndOfSpeechAlreadySignalled;
    
    void *audioBuffer;
    
    dispatch_queue_t _audioQueue;
    
}

#pragma mark -
#pragma mark - Private methods

- (instancetype)init {
    if (self = [super init]) {
        //Default values
        self.mainBufferSent = NO;
        //Use builtin silence detection.
        self.silenceDetectionEnabled = YES;
        //Default is 8Khz
        self.audioSampleRate = CPqDASRSampleRate8K;
        
        _audioQueue = dispatch_queue_create("com.cpqd.recordingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initWithDelegate:(id<CPqDASRMicAudioSourceDelegate>)micDelegate andSampleRate:(CPqDASRSampleRate)sampleRate {
    self = [self init];
    self.micDelegate = micDelegate;
    self.audioSampleRate = sampleRate;
    
    dispatch_async(_audioQueue, ^{
        [self createAudioRecorder];
    });
    
    return self;
}


- (void)createAudioRecorder {
    
    zero_cross_vector = (int *) malloc(zero_cross_vector_size * sizeof (int));
    
    _aqData = (struct AQRecorderState *) malloc(sizeof (struct AQRecorderState));
    
    _aqData->mIsRunning = false;
    
    //16k = 320000 8K = 160000 ~ 10S of audio
    _aqData->kMainBufferSize = (self.audioSampleRate == CPqDASRSampleRate16K) ? 320000 : 160000;
    
    mainBuffer = malloc(_aqData->kMainBufferSize);
    audioBuffer = malloc(_aqData->kMainBufferSize);
    
    _aqData->mDataFormat.mFormatID = kAudioFormatLinearPCM;
    _aqData->mDataFormat.mSampleRate = (self.audioSampleRate == CPqDASRSampleRate16K) ? 16000.0 : 8000.0;
    _aqData->mDataFormat.mChannelsPerFrame = 1;
    _aqData->mDataFormat.mBitsPerChannel = 16;
    _aqData->mDataFormat.mBytesPerPacket = _aqData->mDataFormat.mBytesPerFrame = _aqData->mDataFormat.mChannelsPerFrame * sizeof (SInt16);
    _aqData->mDataFormat.mFramesPerPacket = 1;
    _aqData->mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    
    //Callback for normal recording
    SEL callbackSelector;
    callbackSelector = @selector(onRecordAudio:);
    
    _aqData->callbackMethodImplementation = [self methodForSelector:callbackSelector];
    _aqData->callbackTarget = self;
    _aqData->callbackMethodSelector = callbackSelector;
    
    //Callback for silence detection
    SEL silenceCallbackSelector;
    silenceCallbackSelector = @selector(onSilenceDetected);
    
    _aqData->silenceCallbackMethodImplementation = [self methodForSelector:silenceCallbackSelector];
    _aqData->silenceCallbackTarget = self;
    _aqData->silenceCallbackMethodSelector = silenceCallbackSelector;
    
    _aqData->mainBuffer = mainBuffer;
    _aqData->mainBufferOffset = &mainBufferOffset;
    _aqData->zero_cross_vector = zero_cross_vector;
    _aqData->zero_cross_vector_position = &zero_cross_vector_position;
    
    _aqData->audioBuffer = audioBuffer;
    
    OSStatus retval;
    
    retval = AudioQueueNewInput(&_aqData->mDataFormat, MyAudioQueueInputCallback, _aqData, NULL, kCFRunLoopCommonModes, 0, &_aqData->mQueue);
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueNewInput returned %d", (int)retval]];
    
    // AudioStreamBasicDescription size.
    UInt32 asbdSize;
    
    retval = AudioQueueGetPropertySize(_aqData->mQueue, kAudioQueueProperty_StreamDescription, &asbdSize);
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueGetPropertySize returned %d; property size is %u", (int)retval, (unsigned int)asbdSize]];
    
    retval = AudioQueueGetProperty(_aqData->mQueue, kAudioQueueProperty_StreamDescription, &_aqData->mDataFormat, &asbdSize);
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueGetProperty returned %d; property size is %u", (int)retval, (unsigned int)asbdSize]];
    
    UInt32 bufferSize = (self.audioSampleRate == CPqDASRSampleRate16K) ? 8000 : 4000;
    
    for (int i = 0; i < kNumberBuffers; ++i) {
        retval = AudioQueueAllocateBuffer(_aqData->mQueue, bufferSize, &_aqData->mBuffers[i]);
        [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueAllocateBuffer returned %d; i is %d", (int)retval, i]];
    }
}

- (void)stopAudioQueue {
    
    OSStatus status;
    
    status = AudioQueueStop(_aqData->mQueue, true);
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueStop returned %ld", (long)status]];
    
    _aqData->mIsRunning = false;
    if (!wasEndOfSpeechAlreadySignalled) {
        wasEndOfSpeechAlreadySignalled = YES;
    }
}

- (void)stopRecording {
    
    if (_aqData && _aqData->mIsRunning) {
        [CPqDASRLog logMessage:@"--- CPqDASR stopRecording --- "];
        [self stopAudioQueue];
    }
    
}

- (BOOL)startRecordingWithSilenceCut {
    OSStatus retval = 0;
    
    mainBufferOffset = 0;
    
    zero_cross_vector_position = 0;
    
    _aqData->lastLengthAudioBuffer = 0;
    
    //Buffer enqueue
    for (int i = 0; i < kNumberBuffers; ++i) {
        
        retval = AudioQueueEnqueueBuffer(_aqData->mQueue, _aqData->mBuffers[i], 0, NULL);
        [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueEnqueueBuffer returned %ld; i is %d", (long)retval, i]];
        if (retval != 0) {
            //Error has occurred enqueueing buffers
            return NO;
            break;
        }
    }
    
    _aqData->mIsRunning = true;
    
    retval = AudioQueueStart(_aqData->mQueue, NULL);
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"AudioQueueStart returned %ld", (long)retval]];
    
    wasEndOfSpeechAlreadySignalled = NO;
    
    return YES;
}

- (void)startRecording {
    //If mic is not allowed, return error and abort recognition
    AVAuthorizationStatus micStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if(micStatus == AVAuthorizationStatusDenied) {
        [self.micDelegate didFailWithError:[NSError errorWithDomain:@"mic unavailable" code:100 userInfo:nil]];
        return;
    }
    
    self.mainBufferSent = NO;
    self.isLastPacket = NO;
    self.audioState = CPqDASRAudioStateStopped;
    
    if ([self startRecordingWithSilenceCut]) {
        self.audioState = CPqDASRAudioStateRecording;
    } else {
        self.audioState = CPqDASRAudioStateError;
        [self.micDelegate didFailWithError:[NSError errorWithDomain:@"something went wrong" code:100 userInfo:nil]];
    }
}

#pragma mark -
#pragma mark - Callback methods

- (void)onRecordAudio:(int)length {
    
    [CPqDASRLog logMessage:@"onRecordAudio called"];
    if ((_aqData && _aqData->mIsRunning) && _aqData->lastLengthAudioBuffer > 0) {
        if (!self.mainBufferSent) {
            [CPqDASRLog logMessage:[NSString stringWithFormat:@" --onRecordAudio -- mainBuffer not Sent"]];
            @synchronized (self) {
                self.availableData = [NSData dataWithBytes:_aqData->mainBuffer length:(int)*_aqData->mainBufferOffset];
            }
            //Notify observer
            [self.delegate audioSourceHasDataAvailable];
            self.mainBufferSent = YES;
        }
        else {
            [CPqDASRLog logMessage:[NSString stringWithFormat:@" --onRecordAudio -- main buffer sent"]];
            @synchronized (self) {
                self.availableData = [NSData dataWithBytes:_aqData->audioBuffer length:_aqData->lastLengthAudioBuffer];
            }
            [self.delegate audioSourceHasDataAvailable];
        }
        
        if (self.isLastPacket) {
            [self stopRecording];
            if (self.audioState == CPqDASRAudioStateRecording) {
                self.audioState = CPqDASRAudioStateStopped;
                [CPqDASRLog logMessage:[NSString stringWithFormat:@" -- onRecordAudio - lastPacket --"]];
                @synchronized (self) {
                    self.availableData = [NSData dataWithBytes:nil length:0];
                }
                [self.delegate audioSourceHasDataAvailable];
            }
        }
    }
}

- (void)onSilenceDetected {
    if (self.silenceDetectionEnabled) {
        //Empty data and notify observer
        self.isLastPacket = YES;
        [CPqDASRLog logMessage:@"Silence detection is ENABLED"];
    } else {
        [CPqDASRLog logMessage:@"Silence detection is NOT enabled"];
    }
}

#pragma mark -
#pragma mark - Public methods


- (void)setDetectEndOfSpeech:(BOOL)flag {
    self.silenceDetectionEnabled = flag;
}

#pragma mark -
#pragma mark - CPqDASRAudioSource methods

- (void)start {
    dispatch_async( _audioQueue , ^{
        [self startRecording];
    });
}

- (NSData *)readWithLength:(NSInteger)length {
    [CPqDASRLog logMessage:@" --- read called --- "];
    
    if (self.audioState == CPqDASRAudioStateRecording){
        return self.availableData;
    }
    
    return nil;
}

- (void)close {
    [CPqDASRLog logMessage:@"--- close --- "];
    [self stopAudioQueue];
}

- (void)finish {
    [CPqDASRLog logMessage:@"--- finish --- "];
    [self stopRecording];
}

@end
