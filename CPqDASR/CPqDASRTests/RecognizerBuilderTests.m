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

@interface RecognizerBuilderTests : XCTestCase <CPqDASRRecognitionDelegate, CPqDASRMicAudioSourceDelegate>

@property (nonatomic) DelegateFailBlock delegateFailBlock;

@property (nonatomic) CPqDASRMicAudioSource * micAudioSource;

@property (nonatomic) DelegateFinalResultBlock delegateResultBlock;

@property (nonatomic) DelegateStartListeningBlock delegateStartListening;

@end

@implementation RecognizerBuilderTests

- (void)setUp {
    [super setUp];
    self.micAudioSource = [[CPqDASRMicAudioSource alloc] initWithDelegate:self andSampleRate:CPqDASRSampleRate8K];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testUrlNull {
    CPqDASRSpeechRecognizerBuilder * builder = [[CPqDASRSpeechRecognizerBuilder alloc] init];
    XCTAssertThrows([builder build], @"Invalid URL");
}

- (void)testUrlInvalid {
    //NSURL does not throw exception for non-standard url strings as Java does.
    //This test is probably to pass.
    CPqDASRSpeechRecognizerBuilder * builder = [[CPqDASRSpeechRecognizerBuilder alloc] init];
    NSString * invalidURL = @"abcdasr:";
    
    builder = [builder serverUrl:invalidURL];
    XCTAssertThrows([builder build]);
}

- (void)testCredentialValid {
    
    NSString * wsURL = @"wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k";
    NSString * username = @"estevan";
    NSString * password = @"Thect195";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:wsURL userAgent:nil credentials:nil delegate:self] autoClose:NO] connectOnRecognize:NO] userName: username password: password];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak RecognizerBuilderTests * weakSelf = self;
    weakSelf.delegateStartListening = ^(BOOL success) {
        XCTAssertTrue(success, @"Connection created successfully");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];

    [recognizer recognize:self.micAudioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
    
}

- (void)testCredentialNotValid {
    NSString * wsURL = @"wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k";
    NSString * username = @"invalidUsername";
    NSString * password = @"invalidPassword";
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:wsURL userAgent:nil credentials:nil delegate:self] autoClose:NO] connectOnRecognize:NO] userName: username password: password];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak RecognizerBuilderTests * weakSelf = self;
    weakSelf.delegateFailBlock = ^(CPqDASRRecognitionError * recognitionError) {
        XCTAssertEqual(recognitionError.code, CPqDASRRecognitionErrorCodeUnauthorized, @"Unauthorized");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
    [recognizer recognize:self.micAudioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
}

- (void)testCredentialNull {

    NSString * wsURL = @"wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k";
    NSString * username = nil;
    NSString * password = nil;
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:wsURL userAgent:nil credentials:nil delegate:self] autoClose:NO] connectOnRecognize:NO] userName: username password: password];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    __weak RecognizerBuilderTests * weakSelf = self;
    weakSelf.delegateFailBlock = ^(CPqDASRRecognitionError * recognitionError) {
        XCTAssertEqual(recognitionError.code, CPqDASRRecognitionErrorCodeUnauthorized, @"Unauthorized");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
    [recognizer recognize:self.micAudioSource languageModel: list];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
    
}

- (void)testCreateRecogConfig {
 
    NSString * wsURL = @"wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k";
    NSString * username = @"estevan";
    NSString * password = @"Thect195";
    
    //Change this value in order to test it
    int maxSentences = 5;

    CPqDASRRecognitionConfig * recogConfig = [[CPqDASRRecognitionConfig alloc] init];
    recogConfig.maxSentences = [NSNumber numberWithInteger: maxSentences];
    
    CPqDASRSpeechRecognizerBuilder * builder = [[[[CPqDASRSpeechRecognizerBuilder alloc] initWithURL:wsURL userAgent:nil credentials:@[username, password] delegate:self] autoClose:NO] connectOnRecognize:YES];
    
    CPqDASRSpeechRecognizer * recognizer = [builder build];
    
    XCTestExpectation * testExpectation = [[XCTestExpectation alloc] init];
    
    __weak RecognizerBuilderTests * weakSelf = self;
    weakSelf.delegateResultBlock = ^(CPqDASRRecognitionResult * recognitionResult) {
        XCTAssertEqual(recognitionResult.alternatives.count, maxSentences, @"Three alternatives returned");
        [testExpectation fulfill];
    };
    
    CPqDASRLanguageModelList * list = [[CPqDASRLanguageModelList alloc] init];
    [list addURI:@"builtin:slm/general"];
    
    NSBundle * bundle = [NSBundle bundleForClass: [self class]];
    
    NSString * audioPath = [bundle pathForResource:@"cpf_8k" ofType:@"wav"];
    
    CPqDASRFileAudioSource * audioSource = [[CPqDASRFileAudioSource alloc] initWithFilePath:audioPath];
    
    [recognizer recognize:audioSource languageModel: list recogConfig: recogConfig];
    
    [self waitForExpectations:@[testExpectation] timeout:10.0];
    
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

#pragma mark -
#pragma mark - CPqDASRMicAudioSourceDelegate methods

- (void)didFailWithError:(NSError *)error {
    
}

@end
