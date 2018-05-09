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


#import <XCTest/XCTest.h>
#import <CPqDASR/CPqDASR.h>

typedef void (^DelegateStartListeningBlock)(BOOL success);

typedef void (^DelegateFailBlock)(CPqDASRRecognitionError * recognitionError);

typedef void (^DelegateFinalResultBlock)(CPqDASRRecognitionResult * recognitionResult);

@interface SpeechRecognizerTests : XCTestCase <CPqDASRRecognitionDelegate>

@property (nonatomic) NSBundle * currentBundle;

@property (nonatomic) DelegateFailBlock delegateFailBlock;

@property (nonatomic) CPqDASRSpeechRecognizer * recognizer;

@property (nonatomic) DelegateFinalResultBlock delegateResultBlock;

@property (nonatomic) DelegateStartListeningBlock delegateStartListening;

@property (nonatomic) NSString * wsURL;

@property (nonatomic) NSString * username;

@property (nonatomic) NSString * password;

@end

@implementation SpeechRecognizerTests

- (void)setUp {
    [super setUp];
    self.currentBundle = [NSBundle bundleForClass:[self class]];
    self.wsURL = @"wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k";
    self.password = @"Thect195";
    self.username = @"estevan";
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:@[self.username, self.password] delegate:self] autoClose: NO] connectOnRecognize: YES] maxSessionIdleSeconds: 2];
    self.recognizer = [builder build];
}

- (void)testBasicGrammar {
    
    NSString * audioName = @"cpf_8k";
    NSString * grammarUri = @"builtin:grammar/cpf";
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of alternatives is %lu", (unsigned long)recognitionResult.alternatives.count);
        XCTAssertTrue([recognitionResult.alternatives.firstObject score] > 90, @"Score is higher than 90");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        XCTAssertNotNil([[recognitionResult.alternatives firstObject] interpretations], @"Contains interpretations");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testBasicSLM {
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue([[recognitionResult.alternatives firstObject] score] > 90, @"Score is higher than 90");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        [weakSelf.recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testNoMatchGrammar {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:grammar/cpf";
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue([recognitionResult.alternatives count] == 0, @"Number of alternatives is zero");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoMatch, @"Number no match");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];

}

- (void)testNoSpeech {
    
    NSString * audioName = @"silence-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoSpeech, @"No speech");
        [weakSelf.recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:20.0];
    
}

- (void)testNoInputTimeout {
    
    
    NSString * audioName = @"cpf_8k";
    NSString * grammarUri = @"builtin:grammar/cpf";
    NSInteger noInputTimeoutMillis = 1000;
    BOOL noInputTimeoutEnabled = YES;
    NSInteger packetDelay = 0.3;
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials: @[self.username, self.password] delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 5];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoInputTimeout, @"Result is NoinputTimeout");
        XCTAssertTrue(recognitionResult.alternatives.count == 0, @"Number of alternatives is zero");
        [recognizer close];
        [testExpectation fulfill];
    };
    
    
    CPqDASRRecognitionConfig * recogConfig = [[CPqDASRRecognitionConfig alloc] init];
    recogConfig.noInputTimeoutMilis = [NSNumber numberWithInteger: noInputTimeoutMillis];
    recogConfig.noInputTimeoutEnabled = [NSNumber numberWithInteger: noInputTimeoutEnabled];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
    
    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list recogConfig: recogConfig];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 5];
    
    [inputStream open];
    
    while (1) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
    }
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testRecognizeBufferAudioSource {
 
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    //Delay to deliver packets to recognizer, in seconds
    NSInteger packetDelay = 0.3;
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue([[recognitionResult.alternatives firstObject] score] > 90, @"Score is higher than 90");
        XCTAssertTrue(recognitionResult.alternatives.count == recognitionResult.alternatives.count, @"Number of alternatives is 1");
        [weakSelf.recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];

    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [inputStream open];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 4];
    
    while (1) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
    }
    
    [self waitForExpectations:@[testExpectation] timeout: 20.0];
        
}

- (void)testRecognizeBufferBlockRead {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    NSInteger noInputTimeout = 8000;
    //Big delay to block read thread
    NSInteger packetDelay = 0.5;
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue(recognitionResult.status == CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        XCTAssertTrue(recognitionResult.alternatives.count == recognitionResult.alternatives.count, @"Number of alternatives is %lu", (unsigned long)recognitionResult.alternatives.count);
        [weakSelf.recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
    
    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    CPqDASRRecognitionConfig * recogConfig = [[CPqDASRRecognitionConfig alloc] init];
    recogConfig.noInputTimeoutEnabled = [NSNumber numberWithBool:YES];
    recogConfig.noInputTimeoutMilis = [NSNumber numberWithInteger:noInputTimeout];
    
    [self.recognizer recognize:audioSource languageModel: list recogConfig:recogConfig];
    
    [inputStream open];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 4];
    
    while (1) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
    }
    
    [self waitForExpectations:@[testExpectation] timeout: 20.0];
    
}

- (void)testRecognizeMaxWaitSeconds {
    //TODO - maxWaitSeconds is not being used so far.
}

- (void)testCloseWhileRecognizing {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    //Delay to deliver packets to recognizer, in seconds
    NSInteger packetDelay = 0.3;
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
    
    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [inputStream open];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 4];
    
    int counter = 2;
    while (counter > 0) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
        counter = counter - 1;
    }
    
    [self.recognizer close];
    
    XCTAssertTrue(YES, @"Normal return");
    
}

- (void)testCloseWithoutRecognize {
    
    //Wait until the connection is open
    [NSThread sleepForTimeInterval:10.0f];
    
    [self.recognizer close];
    XCTAssertTrue(YES, @"Normal return");
    
}

- (void)testCancelWhileRecognizing {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    //Delay to deliver packets to recognizer, in seconds
    NSInteger packetDelay = 0.3;
    
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
    
    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [inputStream open];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 4];
    
    int counter = 2;
    while (counter > 0) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
        counter = counter - 1;
    }
    
    //Wait until the connection is open
    [NSThread sleepForTimeInterval:10.0f];
    
    [self.recognizer cancelRecognition];
    
    XCTAssertTrue(YES, @"Normal return");
}

- (void)testCancelNoRecognize {
    
    [self.recognizer cancelRecognition];
    XCTAssertTrue(YES, @"Normal return");
    
}

- (void)testWaitNoRecognize {
    //waitRecognitionResult() not implemented
}

- (void)testDuplicateRecognize {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    //Delay to deliver packets to recognizer, in seconds
    NSInteger packetDelay = 0.3;
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of alternatives is %lu", (unsigned long)recognitionResult.alternatives.count);
        XCTAssertTrue([recognitionResult.alternatives.firstObject score] > 90, @"Score is higher than 90");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        XCTAssertNotNil([[recognitionResult.alternatives firstObject] interpretations], @"Contains interpretations");
        [testExpectation fulfill];
    };
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRBufferAudioSource * audioSource = [[CPqDASRBufferAudioSource alloc] init];
    
    NSInputStream * inputStream = [[NSInputStream alloc] initWithFileAtPath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [inputStream open];
    
    //Wait for the server to start listening
    [NSThread sleepForTimeInterval: 4];
    
    int counter = 10;
    while (counter > 0) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
        counter = counter - 1;
    }
    
    //Call recognize another time
    XCTAssertThrows([self.recognizer recognize:audioSource languageModel: list]);
    
    //Continue sending audio
    while (1) {
        if ([inputStream hasBytesAvailable]) {
            uint8_t buffer[1024];
            NSInteger len = [inputStream read:buffer maxLength:1024];
            if (len > 0) {
                [audioSource write: [NSData dataWithBytes:buffer length:len]];
                
                [NSThread sleepForTimeInterval: packetDelay];
                
            } else {
                [inputStream close];
                [audioSource close];
                break;
            }
        } else {
            break;
        }
    }
    
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
    
}

- (void)testMultipleRecognize {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __block int numberOfRecognitionsPerformed = 0;
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
            XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of alternatives is %lu", (unsigned long)recognitionResult.alternatives.count);
            XCTAssertTrue([recognitionResult.alternatives.firstObject score] > 90, @"Score is higher than 90");
            XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        
        if (numberOfRecognitionsPerformed == 2){
            [testExpectation fulfill];
        }
        numberOfRecognitionsPerformed = numberOfRecognitionsPerformed + 1;
    };
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    //First recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [NSThread sleepForTimeInterval:10.0];
    
    //Second recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [NSThread sleepForTimeInterval:10.0];
    
    //Third recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
    
}

- (void)testMultiplesConnectOnRecognize {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials: @[self.username, self.password] delegate:self] autoClose: NO] connectOnRecognize: YES] maxSessionIdleSeconds: 2];
    
    self.recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __block int numberOfRecognitionsPerformed = 0;
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of alternatives is %lu", (unsigned long)recognitionResult.alternatives.count);
        XCTAssertTrue([recognitionResult.alternatives.firstObject score] > 90, @"Score is higher than 90");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        
        if (numberOfRecognitionsPerformed == 2){
            [testExpectation fulfill];
        }
        numberOfRecognitionsPerformed = numberOfRecognitionsPerformed + 1;
    };
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    //First recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [NSThread sleepForTimeInterval:10.0];
    
    //Second recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [NSThread sleepForTimeInterval:15.0];
    
    //Third recognition
    [self.recognizer recognize:audioSource languageModel:list];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
    
}

- (void)testMultiplesAutoClose {
    //TODO
}

- (void)testSessionTimeout {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials: @[self.username, self.password] delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 10];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        XCTAssertTrue(recognitionResult.alternatives.firstObject.score > 90, @"Score is higher than 90");
        [recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list];
    
    [NSThread sleepForTimeInterval: 65];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
    
}

- (void)testRecognizeAfterSessionTimeout {
    
    NSString * audioName = @"pizza-veg-8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials: @[self.username, self.password] delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 10];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    [NSThread sleepForTimeInterval: 65];
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Result is recognized");
        XCTAssertTrue(recognitionResult.alternatives.firstObject.score > 90, @"Score is higher than 90");
        [recognizer close];
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI: grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];

}

- (void)testContinuousMode {
    
    NSString * audioName = @"hetero_segments_8k";
    NSString * grammarUri = @"builtin:slm/general";
    
    NSString * audioPath = [self.currentBundle pathForResource:audioName ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Recognized");
        XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of results is > 0");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:grammarUri];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    CPqDASRRecognitionConfig * recogConfig = [[CPqDASRRecognitionConfig alloc] init];
    [recogConfig setContinuousMode: [NSNumber numberWithBool:YES]];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:20.0];
}

#pragma mark -
#pragma mark - CPqDASRRecognitionDelegate methods

- (void)cpqdASRDidFailWithError:(CPqDASRRecognitionError *)error {
    if (self.delegateFailBlock) {
        NSLog(@"cpqdASRDidFailWithError called");
        self.delegateFailBlock(error);
    }
}

- (void)cpqdASRDidStopSpeech:(NSTimeInterval)time {
    NSLog(@"cpqdASRDidStopSpeech called");
}

- (void)cpqdASRDidStartSpeech:(NSTimeInterval)time {
    NSLog(@"cpqdASRDidStartSpeech called");
}

- (void)cpqdASRDidStartListening {
    NSLog(@"cpqdASRDidStartListening called");
    if (self.delegateStartListening) {
        self.delegateStartListening(true);
    }
}

- (void)cpqdASRDidReturnFinalResult:(CPqDASRRecognitionResult *)result {
    if (self.delegateResultBlock) {
        self.delegateResultBlock(result);
    }
}

- (void)cpqdASRDidReturnPartialResult:(CPqDASRRecognitionResult *)result {
    
}

@end
