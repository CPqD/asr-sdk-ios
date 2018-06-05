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

NSString *const outputFileName = @"/buffer.dat";

@interface CPqDASRBufferAudioSource ()

@property (nonatomic) dispatch_queue_t bufferQueue;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic) NSOutputStream * outputStream;
@property (nonatomic) NSInputStream * inputStream;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSString * file;
@property (nonatomic, assign) BOOL initiated;
@end

@implementation CPqDASRBufferAudioSource

- (instancetype)init {
    
    if (self = [super init]){
        self.bufferQueue = dispatch_queue_create("com.cpqd.bufferqueue", DISPATCH_QUEUE_SERIAL);
        self.finished = NO;
        self.offset = 0;
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.file = [[paths objectAtIndex:0] stringByAppendingString: outputFileName];
    }
    return self;
    
}

- (BOOL)removeAudioFile {
    //Remove file, is exists
    return [[NSFileManager defaultManager] removeItemAtPath:self.file error:nil];
}

#pragma mark -
#pragma mark - Public methods

- (void)start {
    @synchronized (self) {
        self.offset = 0;
        self.finished = NO;
        self.initiated = NO;
        [self removeAudioFile];
        self.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.file append: YES];
        [self.outputStream open];
        
        self.inputStream = [[NSInputStream alloc] initWithFileAtPath:self.file];
        [self.inputStream open];
    
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
        
        if (!self.initiated) {
            [self.delegate audioSourceHasDataAvailable];
            self.initiated = YES;
        }
        
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

- (NSData *)readWithLength:(NSInteger)length {
    
    NSData * dt = nil;
    uint8_t buffer[length];
    NSInteger bytesRead = 0;
    
    @synchronized (self) {
        bytesRead = [self.inputStream read:buffer maxLength: length];
    }
    
    if (bytesRead < 0 ) {
        return nil;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 300 * NSEC_PER_MSEC), self.bufferQueue, ^{        
        if ([self.inputStream hasBytesAvailable]) {
            [self.delegate audioSourceHasDataAvailable];
        } else {
            [self close];
        }
    });
    
    dt = [NSData dataWithBytes:buffer length: bytesRead];
    return dt;
}

- (void)close {
    @synchronized (self) {
        self.finished = YES;
        [self.outputStream close];
        [self.inputStream close];
    };
}


@end
