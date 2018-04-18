//
//  CPqDASRFileAudioSource.m
//  CPqDASR
//
//  Created by rodrigomorbach on 17/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import "CPqDASRFileAudioSource.h"
#import "CPqDASRLog.h"

@interface CPqDASRFileAudioSource() <NSStreamDelegate>

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSInputStream * inputStream;
@property (nonatomic, strong) NSData * availableData;

@end

@implementation CPqDASRFileAudioSource

- (instancetype)initWithFilePath:(NSString *)path {
    
    if (path == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"path must not be null" userInfo:nil];
    }
    
    if (self = [self init]) {
        self.filePath = path;
    }
    return self;
}

#pragma mark -
#pragma mark - CPqDASRAudioSource methods

- (void)start {
    
    [CPqDASRLog logMessage:@"\n CPqDASRFileAudioSource start called \n"];
    
    //Optional    
    self.inputStream = [[NSInputStream alloc] initWithFileAtPath: self.filePath];
    self.inputStream.delegate = self;
    
    NSRunLoop * runLoop = [NSRunLoop mainRunLoop];
    
    [self.inputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    
    //[runLoop run];
    
}

- (NSData *)read {
    
    if (self.inputStream == nil) {
        return nil;
    }

    return self.availableData;
}

- (void)close {
    if (self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)finish {
    [self close];
    self.inputStream = nil;
}


#pragma mark -
#pragma mark - NSStreamDelegate methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"aStream handleEvent called code %lu", (unsigned long)eventCode]];
    
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buff[1024];
            NSInteger len = 0;
            len = [(NSInputStream *) aStream read:buff maxLength:1024];
            
            if(len > 0) {
                @synchronized (self) {
                    self.availableData = [NSData dataWithBytes:buff length:len];
                }
                
            } else {
                @synchronized (self) {
                    self.availableData = [NSData dataWithBytes:nil length:0];
                }
            }
            [self.delegate audioSourceHasDataAvailable];
        }
            break;
        case NSStreamEventEndEncountered: {
            @synchronized (self) {
                self.availableData = [NSData dataWithBytes:nil length:0];
            }
            [self.delegate audioSourceHasDataAvailable];
            [self close];
        }
        default:
            break;
    }

}


@end
