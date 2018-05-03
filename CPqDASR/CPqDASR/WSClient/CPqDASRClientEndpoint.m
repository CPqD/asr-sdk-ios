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

#import "CPqDASRClientEndpoint.h"
#import <SocketRocket.h>
#import "CPqDASRProtocol.h"
#import "CPqDASRLog.h"
#import "CPqDASRReturnCode.h"
#import <CPqDASR/CPqDASRRecognitionError.h>


@interface CPqDASRClientEndpoint() <SRWebSocketDelegate>

@property (nonatomic, strong) NSURL * wsURL;

@property (nonatomic, weak) id<CPqDASRRecognitionDelegate>delegate;

@property (nonatomic, assign) ASRSessionStatus status;

@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@property (nonatomic, assign) BOOL alreadyReturnResult;

@property (nonatomic, strong, readonly) NSArray * credentials;

@property (nonatomic, assign) NSTimeInterval sessionTimeout;

@property (nonatomic, strong) SRWebSocket * webSocket;

@property (nonatomic, weak) id<CPqDASRClientEndpointDelegate> wsDelegate;

@property (nonatomic, strong) NSMutableArray * responseQueue;

@property (nonatomic, copy) OpenConnectionBlock openConnectionBlock;

/*!
 @brief Sends message to Web socket server
 @discussion Sends data to server
 @param message String or NSData message
 */
- (void)sendMessageToWS:(id)message;

@end

@implementation CPqDASRClientEndpoint

- (instancetype)init {
    if( self = [super init] ){
        //Default value
        self.sessionTimeout = 60.0f;
        self.responseQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)wsURL credentials:(NSArray *)credentials {
    
    if (wsURL == nil){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"URL can not be null" userInfo:nil];
    }
    
    if (self = [self init]) {
        self.wsURL = wsURL;
        _credentials = credentials;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)wsURL dispatchQueue:(dispatch_queue_t)dispatch_queue credentials:(NSArray *)credentials {
    
    if (wsURL == nil){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"URL can not be null" userInfo:nil];
    }
    if (self = [self init]) {
        self.wsURL = wsURL;
        self.delegateQueue = dispatch_queue;
        _credentials = credentials;
    }
    return self;
}

- (void)setRecognitionDelegate:(id<CPqDASRRecognitionDelegate>) recognitionDelegate {
    self.delegate = recognitionDelegate;
}

- (void)setWSDelegate:(id<CPqDASRClientEndpointDelegate>)wsDelegate {
    self.wsDelegate = wsDelegate;            
}

- (void)openWithBlock:(OpenConnectionBlock)block {
    self.openConnectionBlock = block;
    [self open];
}

- (void)open {
    if (self.webSocket) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
    }
    NSURL * wsURL;
    
    //Check if there is credential
    if (self.credentials && self.credentials.count > 1) {
        NSString * urlString = [self.wsURL absoluteString];
        NSString * protocol = [[urlString componentsSeparatedByString:@"//"]firstObject];
        NSString * host = [[urlString componentsSeparatedByString:@"//"]lastObject];
        NSString * newURLString = [protocol stringByAppendingString:[NSString stringWithFormat:@"//%@:%@@%@", [self.credentials firstObject], [self.credentials objectAtIndex:1], host]];
        wsURL = [[NSURL alloc]initWithString:newURLString];
    } else {
        wsURL = self.wsURL;
    }
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:wsURL];
    
    request.timeoutInterval = self.sessionTimeout;
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.webSocket.delegate = self;
    
    if (self.delegateQueue) {
        [self.webSocket setDelegateDispatchQueue:self.delegateQueue];
    }
    
    [self.webSocket open];
    
}

- (NSInteger)getStatus {
    return self.status;
}

- (void)dealloc {
    [CPqDASRLog logMessage: [NSString stringWithFormat:@"%@ dealloc called", NSStringFromClass([self class])]];
}

/*!
 @brief teste
 @todo Not used
 */
- (void)stopRecording {
    switch (self.status) {
        case ASRSessionStatusListening:
        {
            [self.delegate cpqdASRDidStopSpeech:0];
        }
            break;
        case ASRSessionStatusIdle:
        {
            //   [self releaseSTTSession];
        }
            break;
        case ASRSessionStatusRecognizing:
            
            break;
        default:
            break;
    }
}

- (void)sendMessage:(ASRMessage *)message {
    id messageToSend = [message createMessage];
    
    if([message isKindOfClass:[ASRSendAudio class]]) {
        [CPqDASRLog logMessage: [NSString stringWithFormat:@"\n Sending Audio length %@ \n", message.contentlength]];
        NSMutableData * dt = [NSMutableData data];
        [dt appendData:[(NSString *)messageToSend dataUsingEncoding:NSUTF8StringEncoding]];
        [dt appendData:message.payload];
        messageToSend = dt;
    }
    
    [self sendMessageToWS:messageToSend];
}

- (void)sendMessage:(ASRMessage *)message withCompletionBlock:(SendMessageBlock)block {
    //Save block to the queue
    [self.responseQueue addObject:block];
    
    [self sendMessage:message];
}

- (BOOL)isOpen {
    return (self.webSocket.readyState == SR_OPEN);
}

- (void)close {
    if (self.webSocket && (self.webSocket.readyState == SR_OPEN)) {
        [self.webSocket close];
    }
}

- (void)sendMessageToWS:(id)message {
    
    if ([message isKindOfClass:[NSString class]]) {
        [self.webSocket send:[message dataUsingEncoding:NSUTF8StringEncoding]];
    } else{
        //Deal with NSData message
        [self.webSocket send:message];
    }
}

#pragma mark -
#pragma mark - SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"webSocket:didCloseWithCode:reason:wasClean: %@ Code:%ld", reason, (long)code]];
    self.status = ASRSessionStatusIdle;
    
    CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
    recognitionError.code = CPqDASRRecognitionErrorCodeFailure;
    
    if (code != 1000 && !self.alreadyReturnResult) {
        recognitionError.code = CPqDASRRecognitionErrorCodeFailure;
    }
    else if([[[reason uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"SESSION TIMEOUT"]) {
        recognitionError.code = CPqDASRRecognitionErrorCodeSessionTimeout;
    }
    [self.delegate cpqdASRDidFailWithError:recognitionError];
    
    [self.responseQueue removeAllObjects];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"webSocket:didFailWithCode:reason:wasClean: %@ Code:%ld", error.localizedDescription, (long)error.code]];
    
    self.status = ASRSessionStatusIdle;
    
    NSString * reason = error.localizedDescription;
    
    CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
    recognitionError.message = reason;
    //Unauthorized
    if(error.code == 401 || error.code == 2132) {
        recognitionError.code = CPqDASRRecognitionErrorCodeUnauthorized;
    }    
    else if (error.code != 54 && !self.alreadyReturnResult) {
        recognitionError.code = CPqDASRRecognitionErrorCodeConnectionFailure;
    }
    else {
        recognitionError.code = CPqDASRRecognitionErrorCodeConnectionFailure;
    }
    
    [self.responseQueue removeAllObjects];
    
    [self.delegate cpqdASRDidFailWithError:recognitionError];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSString * receivedMessage = nil;
    if ([message isKindOfClass:[NSData class]]) {
        NSData * receivedData = (NSData *)message;
        receivedMessage = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
    }
    
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"webSocket didReceiveMessage \n\n%@", (NSString *)receivedMessage]];
    
    ASRMessage * asrMessage = [ASRProtocolEncoder decode:receivedMessage];
    
    if([asrMessage isKindOfClass:[ASRResponseMessage class]]){
        self.status = [(ASRResponseMessage *)asrMessage sessionStatus];
    }
    
    //RECOGNITION_RESULT_RESPONSE
    if ([asrMessage isKindOfClass:[ASRRecognitionResultMessage class]]) {
        
        [CPqDASRLog logMessage:@"\n Message is ASRRecognitionResultMessage \n "];
        
        ASRRecognitionResultMessage * resultResponse = (ASRRecognitionResultMessage *)asrMessage;
        
        //Now, the state is idle again
        self.status = ASRSessionStatusIdle;
        self.alreadyReturnResult = YES;
        
        CPqDASRRecognitionResult * result = [[CPqDASRRecognitionResult alloc] init];
        
        result.endTime = resultResponse.recognitionResult.endTime;
        result.startTime = resultResponse.recognitionResult.startTime;
        result.lastSpeechSegment = resultResponse.recognitionResult.lastSpeechSegment;
        result.speechSegmentIndex = resultResponse.recognitionResult.speechSegmentIndex;
        result.status = resultResponse.recognitionStatus;
        
        NSMutableArray * alternatives = [[NSMutableArray alloc] init];
        for (ASRRecognitionResultAlternative * alt in resultResponse.recognitionResult.alternatives) {
            CPqDASRRecognitionResultAlternative * asrAlternative = [[CPqDASRRecognitionResultAlternative alloc] init];
            
            asrAlternative.score = alt.score;
            asrAlternative.text = alt.text;
            
            NSMutableArray <CPqDASRRecognitionResultWord *> * words = [[NSMutableArray alloc] init];
            for (ASRRecognitionResultWord * word in alt.words) {
                CPqDASRRecognitionResultWord * asrWord = [[CPqDASRRecognitionResultWord alloc]  init];
                asrWord.text = word.text;
                asrWord.score = word.score;
                asrWord.startTime = word.startTime;
                asrWord.endTime = word.endTime;
                
                [words addObject:asrWord];
            }
            asrAlternative.words = [NSArray arrayWithArray:words];
            asrAlternative.languageModel = alt.languageModel;
            asrAlternative.interpretations = alt.interpretations;
            
            [alternatives addObject:asrAlternative];
        }
        
        result.alternatives = [NSArray arrayWithArray:alternatives];
        
        [CPqDASRLog logMessage:[NSString stringWithFormat:@"\nCPqDASRClientEndpoint Status is : %ld", result.status]];
        
        if (resultResponse.isFinalResult) {
            [self.delegate cpqdASRDidReturnFinalResult: result];
        } else {
            [self.delegate cpqdASRDidReturnPartialResult:result];
        }
    }
    
    else if([asrMessage isKindOfClass:[ASRResponseMessage class]]){
        
        ASRResponseMessage * response = (ASRResponseMessage *)asrMessage;
        
        if(response.sessionStatus) {
            self.status = response.sessionStatus;
        }
        
        if (self.responseQueue.count > 0) {
            [CPqDASRLog logMessage:@"self.responseQueue.count > 0"];
            SendMessageBlock block = [self.responseQueue firstObject];
            block(response);            
            [self.responseQueue removeObjectAtIndex:0];
        }
        
        //General failure from WS protocol
        if (([response.resultStatus isEqualToString:kASRProtocolResponseResultFailure]) && (self.status != ASRSessionStatusRecognizing)) {
            [CPqDASRLog logMessage:[NSString stringWithFormat:@"%ld \n\nGeneral failure from WS protocol", (long)response.errorCode]];
            
            if (response.errorCode && !self.alreadyReturnResult) {
                CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
                recognitionError.code = response.errorCode;
                
                if (response.message) {
                    recognitionError.message = response.message;
                }
                
                [self.delegate cpqdASRDidFailWithError:recognitionError];
            }
            else if (!self.alreadyReturnResult) {
                
                CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
                recognitionError.code = -100;
                
                if (response.message) {
                    recognitionError.message = response.message;
                }
                
                [self.delegate cpqdASRDidFailWithError:recognitionError];
            }
        }
        
        //Error-code found
        else if(response.errorCode && response.errorCode != 0 && response.errorCode) {
            [CPqDASRLog logMessage:[NSString stringWithFormat:@"%ld \n\ERRO-CODE-FOUND", (long)response.errorCode]];
            if (self.alreadyReturnResult) {
                [CPqDASRLog logMessage:@"\n\nAlread Returned Result\n\n"];
            }

            if (!self.alreadyReturnResult) {
                CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
                recognitionError.code = CPqDASRRecognitionErrorCodeFailure;
                [self.delegate cpqdASRDidFailWithError:recognitionError];
            }
        }
        
        //START_OF_SPEECH
        else if ([asrMessage isKindOfClass:[ASRStartSpeechMessage class]]) {
            [CPqDASRLog logMessage:@"\n CPqDASRClientEndpoint START_OF_SPEECH\n"];
            NSTimeInterval time = 0;//TODO for feature implementation
            [self.delegate cpqdASRDidStartSpeech: time];
        }
        
        //END_OF_SPEECH
        else if ([asrMessage isKindOfClass:[ASREndofSpeechMessage class]]) {
            NSTimeInterval time = 0;//TODO for feature implementation
            [self.delegate cpqdASRDidStopSpeech:time];
        }
        
        //START_RECOGNITION
        else if([response.method isEqualToString:kASRProtocolStartRecognition] && [response.result isEqualToString:kASRProtocolResponseResultSuccess] && response.sessionStatus == ASRSessionStatusListening) {
            [CPqDASRLog logMessage:@"\n\nSTART_RECOGNITION CALLED"];
            [self.delegate cpqdASRDidStartListening];
        }
        
        //CANCEL_RECOGNITION
        else if([response.method isEqualToString:kASRProtocolCancelRecognition] && [response.result isEqualToString:kASRProtocolResponseResultSuccess]) {
            [self.delegate cpqdASRDidStopSpeech:0];
        }
        
        //SEND_AUDIO
        else if ([response.method isEqualToString:kASRProtocolSendAudio]
                 && [response.result isEqualToString:kASRProtocolResponseResultSuccess]
                 && self.status == ASRSessionStatusRecognizing) {
            //Last audio packet has been sent. We can call did stop delegate
            NSTimeInterval time = 0; //TODO - For future implementation
            [self.delegate cpqdASRDidStopSpeech:time];
        }
        
        //GET_PARAMETERS or SET_PARAMETERS Response
        else if([response.method isEqualToString:kASRProtocolGetParameters] || [response.method isEqualToString:kASRProtocolSetParameters]) {
            if (!self.alreadyReturnResult) {
                //TODO - check
            }
        }
        //General Failure
        else if ([response.result isEqualToString:kASRProtocolResponseFailure]) {
            CPqDASRRecognitionError * recognitionError = [[CPqDASRRecognitionError alloc] init];
            recognitionError.code = CPqDASRRecognitionErrorCodeFailure;
            [self.delegate cpqdASRDidFailWithError:recognitionError];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [CPqDASRLog logMessage:@"webSocketDidOpen: called"];
    
    if (self.openConnectionBlock != nil) {
        self.openConnectionBlock(true);
        self.openConnectionBlock = nil;
    }
    
    if(self.wsDelegate != nil){
        [self.wsDelegate asrClientEndpointConnectionDidOpen];
    }
}

@end
