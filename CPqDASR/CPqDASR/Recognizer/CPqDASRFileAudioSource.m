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
@property (nonatomic, strong) NSData * availableData;
@property (nonatomic) dispatch_queue_t filequeue;
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
        [CPqDASRLog logMessage:@"\n CPqDASRFileAudioSource start called \n"];
        
        self.inputStream = [[NSInputStream alloc] initWithFileAtPath: self.filePath];
        self.inputStream.delegate = self;
        
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        
        [self.inputStream scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        
        [self.inputStream open];
        
        [runLoop run];
    });
    
   
    
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
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
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
