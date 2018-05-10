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


#import "CPqDASRFileAudioSource.h"
#import "CPqDASRLog.h"

@interface CPqDASRFileAudioSource() <NSStreamDelegate>

@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSInputStream * inputStream;
@property (nonatomic) dispatch_queue_t filequeue;
@property (nonatomic) BOOL finished;
@end

@implementation CPqDASRFileAudioSource

- (instancetype)initWithFilePath:(NSString *)path {
    
    if (path == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"path must not be null" userInfo:nil];
    }
    
    if (self = [self init]) {
        self.filePath = path;
    }
    
    self.filequeue = dispatch_queue_create("com.cpqd.filequeue", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

#pragma mark -
#pragma mark - CPqDASRAudioSource methods

- (void)start {
    dispatch_async(self.filequeue, ^{
        self.finished = NO;
        [CPqDASRLog logMessage:@"\n CPqDASRFileAudioSource start called \n"];
        
        self.inputStream = [[NSInputStream alloc] initWithFileAtPath: self.filePath];
        self.inputStream.delegate = self;
    
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        
        [self.inputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        
        [self.inputStream open];
        
        [runLoop run];
    });
}

- (NSData *)readWithLength:(NSInteger)length {
    
    if (self.inputStream == nil || self.finished) {
        return [NSData dataWithBytes:nil length:0];;
    }

    uint8_t buff[length];
    NSInteger len = 0;
    len = [self.inputStream read:buff maxLength:length];
    
    if(len > 0) {
        return [NSData dataWithBytes:buff length:len];
    }
    
    return [NSData dataWithBytes:nil length:0];
}

- (void)close {
    self.finished = YES;
    if (self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream = nil;
    }
}

- (void)finish {
    [self close];
    self.inputStream = nil;    
}

#pragma mark -
#pragma mark - NSStreamDelegate methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            [self.delegate audioSourceHasDataAvailable];
            [NSThread sleepForTimeInterval:0.005];
        }
            break;
        case NSStreamEventEndEncountered: {
            [self close];
        }
            break;
        case NSStreamEventErrorOccurred: {
            [self close];
        }
            break;
        default:
            break;
    }
}
@end
