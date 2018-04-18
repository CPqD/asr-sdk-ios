//
//  SpeechRecognizerTests.m
//  CPqDASRTests
//
//  Created by rodrigomorbach on 13/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

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

@end

@implementation SpeechRecognizerTests

- (void)setUp {
    [super setUp];
    self.currentBundle = [NSBundle bundleForClass:[self class]];
    
    self.wsURL = @"ws://vmh123.cpqd.com.br:8025/asr-server/asr";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:nil delegate:self] autoClose: NO] connectOnRecognize: YES] maxSessionIdleSeconds: 5];
    
    self.recognizer = [builder build];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testBasicGrammar {
    
    NSString * audioPath = [self.currentBundle pathForResource:@"cpf_8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"CPF recognized");
        XCTAssertNotNil([[recognitionResult.alternatives firstObject] interpretations], @"There are interpretations");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:grammar/cpf"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testBasicSLM {
    NSString * audioPath = [self.currentBundle pathForResource:@"pizza-veg-8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue([[recognitionResult.alternatives firstObject] score] > 90, @"Score is higher than 90");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Pizza recognized");
        XCTAssertNotNil([[recognitionResult.alternatives firstObject] interpretations], @"There are interpretations");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testNoMatchGrammar {
    NSString * audioPath = [self.currentBundle pathForResource:@"pizza-veg-8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertTrue([recognitionResult.alternatives count] == 0, @"Number of alternatives is zero");
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoMatch, @"Number no match");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:grammar/number"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];

}

- (void)testNoSpeech {
    
    NSString * audioPath = [self.currentBundle pathForResource:@"silence-8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoSpeech, @"No speech");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [self.recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:20.0];
    
}

- (void)testNoInputTimeout {
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:nil delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 5];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    NSString * audioPath = [self.currentBundle pathForResource:@"cpf_8k" ofType:@"wav"];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusNoInputTimeout, @"No input timeout");
        XCTAssertTrue(recognitionResult.alternatives.count == 0, @"Number of alternatives is zero");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:grammar/cpf"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list];
    
    //After start recognition, block until No input timeout
    [NSThread sleepForTimeInterval: 20];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
}

- (void)testCloseWhileRecognizing {
    //TODO
}

- (void)testCloseWithoutRecognize {
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:nil delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 5];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateFailBlock = ^(CPqDASRRecognitionError * recognitionError) {
        XCTAssertEqual(recognitionError.code, CPqDASRRecognitionErrorCodeFailure, @"Connection closed by the server");
        [testExpectation fulfill];
    };
    
    //Wait until the connection is open
    [NSThread sleepForTimeInterval:10.0f];
    
    [recognizer close];
    [self waitForExpectations:@[testExpectation] timeout: 10.0];
    
}

- (void)testCancelWhileRecognizing {
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:nil delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 5];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    //Wait until the connection is open
    [NSThread sleepForTimeInterval:10.0f];
    
    [recognizer cancelRecognition];
    
    XCTAssertTrue(YES, @"Normal return");
}

- (void)testCancelNoRecognize {
    //TODO
}

- (void)testDuplicateRecognize {
    //TODO
}

- (void)testMultiplesConnectOnRecognize {
    //TODO
}

- (void)testMultiplesAutoClose {
    //TODO
}

- (void)testSessionTimeout {
    
    
}

- (void)testRecognizeAfterSessionTimeout {
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:self.wsURL userAgent:nil credentials:nil delegate:self] autoClose: NO] connectOnRecognize: NO] maxSessionIdleSeconds: 5];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    [NSThread sleepForTimeInterval: 70];
    
    NSString * audioPath = [self.currentBundle pathForResource:@"cpf_8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"CPF recognized");
        XCTAssertNotNil([[recognitionResult.alternatives firstObject] interpretations], @"There are interpretations");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:grammar/cpf"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout: 10.0];

}

- (void)testContinuousMode {
    NSString * audioPath = [self.currentBundle pathForResource:@"hetero_segments_8k" ofType:@"wav"];
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak SpeechRecognizerTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult *recognitionResult) {
        XCTAssertEqual(recognitionResult.status, CPqDASRRecognitionStatusRecognized, @"Recognized");
        XCTAssertTrue(recognitionResult.alternatives.count > 0, @"Number of results is > 0");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
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
