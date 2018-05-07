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

#import "CPqDASRBufferAudioSource.h"
#import "CPqDASRLog.h"

@interface CPqDASRBufferAudioSource ()

@property (nonatomic) dispatch_queue_t bufferQueue;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic) NSOutputStream * outputStream;
@property (nonatomic, assign) NSInteger offset;
@end

@implementation CPqDASRBufferAudioSource

- (instancetype)init {
    
    if (self = [super init]){
        self.bufferQueue = dispatch_queue_create("com.cpqd.bufferqueue", DISPATCH_QUEUE_SERIAL);
        self.finished = NO;
        self.offset = 0;
    }
    return self;
    
}

#pragma mark -
#pragma mark - Public methods

- (void)start {
    @synchronized (self) {
        self.offset = 0;
        self.finished = NO;
        self.outputStream = [[NSOutputStream alloc] initToMemory];
        [self.outputStream open];
    }

}

- (BOOL)write:(NSData *)data {
    
    if (self.finished) {
        return false;
    }
    if ([self.outputStream hasSpaceAvailable]) {
        NSInteger bytesWritten = 0;
        
        @synchronized (self){
            bytesWritten = [self.outputStream write:[data bytes] maxLength: [data length]];
        };
        
        if (bytesWritten < 0) {
            return false;
        }
        
        [self.delegate audioSourceHasDataAvailable];
        
    } else {
        return false;
    }
    
    return true;
}

#pragma mark -
#pragma mark - CPqDAudioSource methods

- (void)finish {
    [self close];
}

- (NSData *)read {
    
    NSData * data = [self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];

    if ( !data || data.length <= 0 ) {
        return [NSData dataWithBytes:nil length:0];
    }
    
    uint8_t buffer[1024];
    
    NSInteger maxLength = (data.length - self.offset) > 1024 ? 1024 : data.length - self.offset;
    
    
    if (self.offset + maxLength > data.length) {
        maxLength = data.length - self.offset;
    }
    
    [data getBytes:buffer range:NSMakeRange(self.offset, maxLength)];
    
    self.offset += maxLength;
    
    NSData * dt = [NSData dataWithBytes:buffer length: maxLength];
    
    return dt;
}

- (void)close {
    self.finished = YES;
    @synchronized (self){
        [self.outputStream close];        
    };
}


@end
