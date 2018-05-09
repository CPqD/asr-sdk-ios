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

#import "CPqDASRProtocol.h"
#import "CPqDASRVersionManager.h"
#import "CPqDASRLog.h"
#import "CPqDASRDeviceManager.h"

NSString *const kASRProtocolCarriageReturnNewLine = @"\r\n";

NSString *const kASRProtocolCreateSession = @"CREATE_SESSION";
NSString *const kASRProtocolStartRecognition = @"START_RECOGNITION";
NSString *const kASRProtocolReleaseSession = @"RELEASE_SESSION";
NSString *const kASRProtocolSendAudio = @"SEND_AUDIO";
NSString *const kASRProtocolStopRecognition = @"STOP_RECOGNITION";
NSString *const kASRProtocolRecognitionResult = @"RECOGNITION_RESULT";
NSString *const kASRProtocolRecognitionStartOfSpeech = @"START_OF_SPEECH";
NSString *const kASRProtocolRecognitionEndOfSpeech = @"END_OF_SPEECH";
NSString *const kASRProtocolInvalidAction = @"INVALID_ACTION";
NSString *const kASRProtocolCancelRecognition = @"CANCEL_RECOGNITION";

NSString *const kASRProtocolGetParameters = @"GET_PARAMETERS";
NSString *const kASRProtocolSetParameters = @"SET_PARAMETERS";

NSString *const kASRProtocolResponse = @"RESPONSE";

//Status
NSString *const kASRProtocolResponseStatusRecognizing = @"RECOGNIZING";
NSString *const kASRProtocolResponseStatusListening = @"LISTENING";
NSString *const kASRProtocolResponseStatusIdle = @"IDLE";


//Result-status
NSString *const kASRProtocolResponseResultRecognized = @"RECOGNIZED";
NSString *const kASRProtocolResponseResultProcessing = @"PROCESSING";
NSString *const kASRProtocolResponseResultNoMatch = @"NO_MATCH";
NSString *const kASRProtocolResponseResultNoInputTimeOut = @"NO_INPUT_TIMEOUT";
NSString *const kASRProtocolResponseResultMaxSpeech = @"MAX_SPEECH";
NSString *const kASRProtocolResponseResultEarlySpeech = @"EARLY_SPEECH";
NSString *const kASRProtocolResponseResultRecognitionTimeOut = @"RECOGNITION_TIMEOUT";
NSString *const kASRProtocolResponseResultNoSpeech = @"NO_SPEECH";
NSString *const kASRProtocolResponseResultCanceled = @"CANCELED";
NSString *const kASRProtocolResponseResultFailure = @"FAILURE";


NSString *const kASRProtocolResponseResultSuccess = @"SUCCESS";
NSString *const kASRProtocolResponseFailure = @"FAILURE";
NSString *const kASRProtocolResponseErrorCode = @"ERROR-CODE";
NSString *const kASRProtocolResponseExpires = @"EXPIRES";
NSString *const kASRProtocolResponseMessage = @"MESSAGE";


//Error-Code possible values
NSString *const kASRProtocolERRGeneric = @"ERR_GENERIC";
NSString *const kASRProtocolERRInvalidArgument = @"ERR_INVALID_ARGUMENT";
NSString *const kASRProtocolERRBufferOverflow = @"ERR_BUFFER_OVERFLOW";
NSString *const kASRProtocolERRBadAlloc = @"ERR_BAD_ALLOC";
NSString *const kASRProtocolERRInternalError = @"ERR_INTERNAL_ERROR";
NSString *const kASRProtocolERRInvalidState = @"ERR_INVALID_STATE";
NSString *const kASRProtocolERREngineNotFound = @"ERR_ENGINE_NOT_FOUND";
NSString *const kASRProtocolERRRecogCreate = @"ERR_RECOG_CREATE";
NSString *const kASRProtocolERRSessionNotFound = @"ERR_SESSION_NOT_FOUND";
NSString *const kASRProtocolERRPathRead = @"ERR_PATH_READ";
NSString *const kASRProtocolERRArgInvalid = @"ERR_ARG_INVALID";
NSString *const kASRProtocolERRFileOpen = @"ERR_FILE_OPEN";
NSString *const kASRProtocolERRResult = @"ERR_RESULT";
NSString *const kASRProtocolERRNotActiveLM = @"ERR_NO_ACTIVE_LM";
NSString *const kASRProtocolERRCorruptedLM = @"ERR_CORRUPTED_LM";
NSString *const kASRProtocolERRMaxLicenses = @"ERR_MAX_LICENSES";
NSString *const kASRProtocolERRLicenseNotFound = @"ERR_LIC_NOT_FOUND";
NSString *const kASRProtocolERRLicenseParser = @"ERR_LIC_PARSER";
NSString *const kASRProtocolERRLicenseExpiration = @"ERR_LIC_EXPIRATION";
NSString *const kASRProtocolERRLicenseUnAuthorized = @"ERR_LIC_UNAUTHORIZED";
NSString *const kASRProtocolERRLicenseHardInfo = @"ERR_LIC_HARD_INFO";
NSString *const kASRProtocolERRNotListenningAudio = @"ERR_NOT_LISTENNING_AUDIO";


NSString *const kASRProtocolERRBusy = @"ERROR_BUSY";
NSString *const kASRProtocolERRInvalidParameter = @"ERROR_INVALID_PARAMETER";
NSString *const kASRProtocolERRInvalidParameterValue = @"ERROR_INVALID_PARAMETER_VALUE";

@interface ASRProtocolEncoder()

//Provide a response object base on the received message
+ (ASRResponseMessage *)parseWSMessage:(NSString *)message;

@end

@implementation ASRProtocolEncoder


+ (ASRMessage *)decode:(NSString *)receivedMessage {
    
    ASRMessage * responseMessage = nil;
    
    NSArray * explodedResponse = [receivedMessage componentsSeparatedByString:kASRProtocolCarriageReturnNewLine];
    
    NSString * messageType = [[[explodedResponse objectAtIndex:0] componentsSeparatedByString:@" "]lastObject];
    
    if ([messageType isEqualToString:kASRProtocolRecognitionResult]) {
        responseMessage = [[ASRRecognitionResultMessage alloc] initWithMessage:receivedMessage];
    }
    else if ([messageType isEqualToString:kASRProtocolRecognitionStartOfSpeech]) {
        responseMessage = [[ASRStartSpeechMessage alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolRecognitionEndOfSpeech]) {
        responseMessage = [[ASREndofSpeechMessage alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolCreateSession]) {
        responseMessage = [[ASRCreateSession alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolSendAudio]) {
        responseMessage = [[ASRSendAudio alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolStartRecognition]){
        responseMessage = [[ASRStartRecognition alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolStopRecognition]){
        responseMessage = [[ASRStopRecognition alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolCancelRecognition]){
        responseMessage = [[ASRCancelRecognition alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolGetParameters]){
        responseMessage = [[ASRGetParametersMessage alloc] initWithMessage:receivedMessage];
    }
    else if([messageType isEqualToString:kASRProtocolSetParameters]){
        responseMessage = [[ASRSetParametersMessage alloc] initWithMessage:receivedMessage];
    }
    else {
        responseMessage = [self parseWSMessage:receivedMessage];
    }
    return responseMessage;
    
}

+ (ASRResponseMessage *)parseWSMessage:(NSString *) message {
    NSArray * explodedResponse = [message componentsSeparatedByString:@"\r\n"];
    
    ASRResponseMessage * stt = [[ASRResponseMessage alloc] init];
    @try {
        for (NSString * value in explodedResponse) {
            NSArray * explodedValue = [value componentsSeparatedByString:@":"];
            if (explodedValue.count > 1) {
                NSString * key = [[[explodedValue firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
                NSString * value = [[explodedValue lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if([key isEqualToString:@"SESSION-STATUS"]) {
                    if([value isEqualToString:kASRProtocolResponseStatusRecognizing]){
                        stt.sessionStatus = ASRSessionStatusRecognizing;
                    }
                    else if([value isEqualToString:kASRProtocolResponseStatusIdle]) {
                        stt.sessionStatus = ASRSessionStatusIdle;
                    }
                    else if([value isEqualToString:kASRProtocolResponseStatusListening]) {
                        stt.sessionStatus = ASRSessionStatusListening;
                    }
                }
                if ([key isEqualToString:@"RESULT-STATUS"]) {
                    stt.resultStatus = value;
                }
                else if ([key  isEqualToString:@"METHOD"]) {
                    stt.method = value;
                }
                else if ([key isEqualToString:@"RESULT"]) {
                    stt.result = value;
                }
                else if([key isEqualToString:kASRProtocolResponseErrorCode])
                {
                    stt.errorCode = [stt returnCodeFromErrorMessage:value];
                }
                else if([key isEqualToString:kASRProtocolResponseExpires])
                {
                    stt.expires = value;
                }
                else if([key isEqualToString:kASRProtocolResponseMessage]){
                    stt.message = value;
                }
            }
        }
    }
    @catch (NSException *exception) {
        [CPqDASRLog logMessage:@"Error parsing response"];
    }
    
    return stt;
}

@end

@implementation ASRMessage

- (instancetype)init {
    if (self = [super init]) {
        self.appVersion = @"2.3";
        self.appName = @"ASR";
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super init]) {
        
        NSArray * explodedMessage = [message componentsSeparatedByString:kASRProtocolCarriageReturnNewLine];
        
        for (NSString * value in explodedMessage) {
            
            NSArray * explodedValue = [value componentsSeparatedByString:@":"];
            if (explodedValue.count > 1) {
                NSString * key = [[[explodedValue firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
                NSString * value = [[explodedValue lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([key isEqualToString:@"METHOD"]) {
                    self.method = value;
                }
                else if ([key isEqualToString:@"HANDLE"]) {
                    self.handle = value;
                }
            }
        }
    }
    return self;
}

- (NSString *)createMessage {
    return [NSString stringWithFormat:@"%@ %@ %@ %@\r\n", self.appName, self.appVersion, self.method, self.handle];
}

@end

@implementation ASRCreateSession

- (instancetype)init {
    if (self = [super init]) {
        if (![[CPqDASRDeviceManager sharedDeviceManager] isUUIDStoredInKeyChain]) {
            [[CPqDASRDeviceManager sharedDeviceManager] storeUUIDInKeyChain];
        }
        
        self.userAgent = [NSString stringWithFormat:@"User-agent: model=%@; manufacturer=%@; os=%@; os_version=%@; app_name=%@; app_version=%@; lib_name=%@; lib_version=%@; phone_id=%@\r\n", [[CPqDASRDeviceManager sharedDeviceManager] deviceModel], [[CPqDASRDeviceManager sharedDeviceManager] deviceManufacturer], [[CPqDASRDeviceManager sharedDeviceManager] platform], [[CPqDASRDeviceManager sharedDeviceManager] platformVersion], [CPqDASRVersionManager appName], [CPqDASRVersionManager appVersion], [CPqDASRVersionManager libName], [CPqDASRVersionManager libVersion], [[CPqDASRDeviceManager sharedDeviceManager] getIdentifierFromKeyChain]];
        
        self.method = kASRProtocolCreateSession;
    }
    return self;
}

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    
    //Add User-agent
    message = [message stringByAppendingString: self.userAgent];
    
    return message;
}

@end

@implementation ASRStartRecognition

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolStartRecognition;
    }
    return self;
    
}

- (NSString *)createMessage {
    
    NSString * message = [super createMessage];
    
    NSString * languageModelContent = [self.languageModel createMessage];
    
    self.contentlength = [NSString stringWithFormat:@"%ld", (long)[languageModelContent length]];
    
    message = [message stringByAppendingString:[NSString stringWithFormat:@"Content-Length:%@\r\nContent-Type:%@\r\n", self.contentlength, self.languageModel.contentType]];
    
    if (self.parameters != nil) {
        NSArray * allKeys = [self.parameters allKeys];
        
        for (NSString * key in allKeys) {
            NSString * v = [self.parameters objectForKey:key];
            message = [message stringByAppendingString:[NSString stringWithFormat:@"%@: %@\r\n", key, v]];
        }
    }
    
    message = [message stringByAppendingString: [NSString stringWithFormat:@"\r\n%@\r\n", languageModelContent]];
        
    return message;
}

@end

@implementation ASRSendAudio

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolSendAudio;
    }
    return self;
}

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    NSString * lastPacket = (self.lastPacket) ? @"true" : @"false";
    
    message = [message stringByAppendingString:[NSString stringWithFormat:@"LastPacket:%@\r\nContent-Length:%@\r\nContent-Type:%@\r\n\r\n", lastPacket, self.contentlength,self.contentType]];
    return message;
    
}

@end

@implementation ASRStopRecognition

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolStopRecognition;
    }
    return self;
}

- (NSString *)createMessage
{
    NSString * message = [super createMessage];
    return message;
}

@end

@implementation ASRCancelRecognition

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolCancelRecognition;
    }
    return self;
}

- (NSString *)createMessage {
    return [super createMessage];
}

@end

@implementation ASRReleaseSession

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolReleaseSession;
    }
    return self;
}

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    return message;
}

@end

@implementation ASRStartSpeechMessage

@end

@implementation ASRGetParametersMessage

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolGetParameters;
    }
    return self;
}

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    message = [message stringByAppendingString:self.parameters];
    return message;
}

@end

@interface ASRSetParametersMessage()

@property (nonatomic, copy) NSDictionary * headers;

@end

@implementation ASRSetParametersMessage

- (instancetype)init {
    if (self = [super init]) {
        self.method = kASRProtocolSetParameters;
    }
    return self;
}

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    
    NSArray * allKeys = [self.headers allKeys];
    for (NSString * key in allKeys) {
        NSString * v = [self.headers objectForKey:key];
        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@: %@\r\n", key, v]];
    }
    
    return message;
}

- (void)setRecognitionParameters:(NSDictionary *)headers{
    self.headers = headers;
}

@end



//Response implementations
@implementation ASRResponseMessage

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super initWithMessage:message]) {
        
        NSArray * explodedMessage = [message componentsSeparatedByString:kASRProtocolCarriageReturnNewLine];
        
        for (NSString * value in explodedMessage) {
            
            NSArray * explodedValue = [value componentsSeparatedByString:@":"];
            if (explodedValue.count > 1) {
                NSString * key = [[[explodedValue firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
                NSString * value = [[explodedValue lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([key isEqualToString:@"RESULT-STATUS"]) {
                    self.resultStatus = value;
                }
                else if([key isEqualToString:@"SESSION-STATUS"]) {
                    if([value isEqualToString:kASRProtocolResponseStatusRecognizing]){
                        self.sessionStatus = ASRSessionStatusRecognizing;
                    }
                    else if([value isEqualToString:kASRProtocolResponseStatusIdle]) {
                        self.sessionStatus = ASRSessionStatusIdle;
                    }
                    else if([value isEqualToString:kASRProtocolResponseStatusListening]) {
                        self.sessionStatus = ASRSessionStatusListening;
                    }
                }
                else if ([key isEqualToString:@"RESULT"]) {
                    self.result = value;
                }
                else if([key isEqualToString:kASRProtocolResponseErrorCode])
                {
                    self.errorCode = [self returnCodeFromErrorMessage:value];
                }
                else if([key isEqualToString:kASRProtocolResponseExpires])
                {
                    self.expires = value;
                }
            }
        }
    }
    return self;
}


- (ASRReturnCode)returnCodeFromErrorMessage:(NSString *)errorMessage {
    errorMessage = [[errorMessage uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([errorMessage isEqualToString:kASRProtocolERRInvalidArgument]) {
        return ASRReturnCodeERRInvalidArgument;
    }
    if([errorMessage isEqualToString:kASRProtocolERRBufferOverflow])
    {
        return ASRReturnCodeERRBufferOverflow;
    }
    if([errorMessage isEqualToString:kASRProtocolERRBadAlloc])
    {
        return ASRReturnCodeERRBadAlloc;
    }
    if([errorMessage isEqualToString:kASRProtocolERRInternalError])
    {
        return ASRReturnCodeERRInternalError;
    }
    if([errorMessage isEqualToString:kASRProtocolERRInvalidState])
    {
        return ASRReturnCodeERRInvalidState;
    }
    if([errorMessage isEqualToString:kASRProtocolERREngineNotFound])
    {
        return ASRReturnCodeERREngineNotFound;
    }
    if([errorMessage isEqualToString:kASRProtocolERRRecogCreate])
    {
        return ASRReturnCodeERRRecogCreate;
    }
    if([errorMessage isEqualToString:kASRProtocolERRSessionNotFound])
    {
        return ASRReturnCodeERRSessionNotFound;
    }
    if ([errorMessage isEqualToString:kASRProtocolERRPathRead]) {
        return ASRReturnCodeERRPathRead;
    }
    if([errorMessage isEqualToString:kASRProtocolERRArgInvalid])
    {
        return ASRReturnCodeERRRequiredAMNotAllowed;
    }
    if([errorMessage isEqualToString:kASRProtocolERRFileOpen])
    {
        return ASRReturnCodeERRLMNotFound;
    }
    if([errorMessage isEqualToString:kASRProtocolERRResult])
    {
        return ASRReturnCodeERRResult;
    }
    if([errorMessage isEqualToString:kASRProtocolERRNotActiveLM])
    {
        return ASRReturnCodeERRNotActiveLM;
    }
    if([errorMessage isEqualToString:kASRProtocolERRMaxLicenses])
    {
        return ASRReturnCodeERRMaxLicenses;
    }
    if([errorMessage isEqualToString:kASRProtocolERRLicenseNotFound])
    {
        return ASRReturnCodeERRLicenseNotFound;
    }
    if([errorMessage isEqualToString:kASRProtocolERRLicenseParser])
    {
        return ASRReturnCodeERRLicenseParser;
    }
    if([errorMessage isEqualToString:kASRProtocolERRLicenseExpiration])
    {
        return ASRReturnCodeERRLicenseExpiration;
    }
    if([errorMessage isEqualToString:kASRProtocolERRLicenseUnAuthorized])
    {
        return ASRReturnCodeERRLicenseUnAuthorized;
    }
    if([errorMessage isEqualToString:kASRProtocolERRLicenseHardInfo])
    {
        return ASRReturnCodeERRLicenseHardInfo;
    }
    if([errorMessage isEqualToString:kASRProtocolERRNotListenningAudio])
    {
        return ASRReturnCodeERRNotListenningAudio;
    }
    if ([errorMessage isEqualToString:kASRProtocolERRBusy]) {
        return ASRReturnCodeERRBusy;
    }
    if ([errorMessage isEqualToString:kASRProtocolERRInvalidParameter]) {
        return ASRReturnCodeERRInvalidParameter;
    }
    if ([errorMessage isEqualToString:kASRProtocolERRInvalidParameterValue]) {
        return ASRReturnCodeERRInvalidParameterValue;
    }
    if ([errorMessage isEqualToString:kASRProtocolERRCorruptedLM]) {
        return ASRReturnCodeERRCorruptedLM;
    }
    
    return ASRReturnCodeUndefinedError;
}


@end

NSString *const kASRRecognitionResultText = @"text";

NSString *const kASRRecognitionResultScore = @"score";

NSString *const kASRRecognitionResultAlternatives = @"alternatives";

NSString *const kASRRecognitionResultStatus = @"result_status";

NSString *const kASRRecognitionResultSegmentIndex = @"segment_index";

NSString *const kASRRecognitionResultLastSegment = @"last_segment";

NSString *const kASRRecognitionResultStartTime = @"start_time";

NSString *const kASRRecognitionResultEndTime = @"end_time";

NSString *const kASRRecognitionResultFinalResult = @"final_result";


NSString *const kASRRecognitionResultAlternativeLanguageModel = @"lm";

NSString *const kASRRecognitionResultAlternativeInterpretationsScore = @"interpretation_scores";

NSString *const kASRRecognitionResultAlternativeInterpretations = @"interpretations";

NSString *const kASRRecognitionResultAlternativeWords = @"words";


@implementation ASRRecognitionResultMessage

- (instancetype)initWithMessage:(NSString *)message {
    
    if (self = [super initWithMessage:message]) {
        
        NSString * payload = [[message componentsSeparatedByString:@"\r\n\r\n"] lastObject];
        if (payload) {
            
            self.payload = [payload dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError * error = nil;
            NSDictionary * receivedPayload = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (!error) {                
                ASRRecognitionResult * result = [[ASRRecognitionResult alloc] initWithDictionary: receivedPayload];
                self.recognitionResult = result;
                self.recognitionStatus = result.recognitionStatus;
                self.isFinalResult = result.finalResult;
            }
            else{
                NSMutableDictionary * resultDictionary = [[NSMutableDictionary alloc]init];
                [resultDictionary setObject:self.resultStatus forKey:@"status"];
                self.resultDictionary = [NSDictionary dictionaryWithDictionary:resultDictionary];
            }
        }
    }
    return self;
}



@end

@implementation ASREndofSpeechMessage

@end

@implementation ASRRecognitionResultAlternative

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.text = [dict objectForKey:kASRRecognitionResultText] ? :@"" ;
        _score = [dict objectForKey: kASRRecognitionResultScore] ? [[dict objectForKey:kASRRecognitionResultScore] integerValue] : 0;
        _interpretations = [dict objectForKey:kASRRecognitionResultAlternativeInterpretations]?:@[];
        
        NSMutableArray * words = [[NSMutableArray alloc] init];
        
        NSArray * wordsArray = [dict objectForKey:kASRRecognitionResultAlternativeWords];
        
        for (NSDictionary * item in wordsArray) {
            [words addObject: [[ASRRecognitionResultWord alloc] initWithDictionary:item]];
        }
        
        _intepretationScoreList = [dict objectForKey:kASRRecognitionResultAlternativeInterpretationsScore];
        
        _words = words;
        
        _languageModel = [dict objectForKey:kASRRecognitionResultAlternativeLanguageModel];
        
    }
    return self;
}

@end

@implementation ASRRecognitionResultWord

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]){
        _text = [dict objectForKey:kASRRecognitionResultText];
        _score = [[dict objectForKey:kASRRecognitionResultScore] integerValue];
        _startTime = [[dict objectForKey:kASRRecognitionResultStartTime] doubleValue];
        _endTime = [[dict objectForKey:kASRRecognitionResultEndTime] doubleValue];
    }
    return self;
}

@end

@implementation ASRRecognitionResult

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
     
        NSMutableArray * mutableAlternatives = [[NSMutableArray alloc] init];
        for (NSDictionary * alternative in [dict objectForKey:kASRRecognitionResultAlternatives]) {
            [mutableAlternatives addObject:[[ASRRecognitionResultAlternative alloc] initWithDictionary:alternative]];
        }
        _alternatives = [NSArray arrayWithArray:mutableAlternatives];
        
        _recognitionStatus = [self statusFromString:[dict objectForKey:kASRRecognitionResultStatus]];
        
        _speechSegmentIndex = [[dict objectForKey:kASRRecognitionResultSegmentIndex] integerValue];
        _startTime = [[dict objectForKey:kASRRecognitionResultStartTime] doubleValue];
        _endTime = [[dict objectForKey:kASRRecognitionResultEndTime] doubleValue];
        _lastSpeechSegment = [[dict objectForKey:kASRRecognitionResultLastSegment] boolValue];
        
        BOOL isFinalResult = [[dict objectForKey:kASRRecognitionResultFinalResult] boolValue];
               
        _finalResult = isFinalResult;
        
    }
    return self;
}


- (CPqDASRRecognitionStatus)statusFromString:(NSString *)status {
    [CPqDASRLog logMessage:[NSString stringWithFormat:@"statusFromString called for status %@", status]];

    if ([status isEqualToString:kASRProtocolResponseResultProcessing]) {
        return CPqDASRRecognitionStatusProcessing;
    }
    if ([status isEqualToString:kASRProtocolResponseResultNoMatch]) {
        return CPqDASRRecognitionStatusNoMatch;
    }
    if ([status isEqualToString:kASRProtocolResponseResultNoInputTimeOut]) {
        return CPqDASRRecognitionStatusNoInputTimeout;
    }
    if ([status isEqualToString:kASRProtocolResponseResultMaxSpeech]) {
        return CPqDASRRecognitionStatusMaxSpeech;
    }
    if ([status isEqualToString:kASRProtocolResponseResultEarlySpeech]) {
        return CPqDASRRecognitionStatusEarlySpeech;
    }
    if ([status isEqualToString:kASRProtocolResponseResultRecognitionTimeOut]) {
        return CPqDASRRecognitionStatusRecognitionTimeout;
    }
    if ([status isEqualToString:kASRProtocolResponseResultNoSpeech]) {
        return CPqDASRRecognitionStatusNoSpeech;
    }
    if ([status isEqualToString:kASRProtocolResponseResultCanceled]) {
        return CPqDASRRecognitionStatusCanceled;
    }
    if ([status isEqualToString:kASRProtocolResponseResultFailure]) {
        return CPqDASRRecognitionStatusFailure;
    }
    
    return CPqDASRRecognitionStatusRecognized;
}

@end


@implementation LanguageModel

- (NSString *)createMessage {
    NSString * message = @"";
    
    if (self.uri != nil && ![self.uri isEqualToString:@""]) {
        self.contentType = @"text/uri-list";
        message = [NSString stringWithFormat:@"%@", self.uri];
    } else if(self._id && self.definition != nil) {
        //TODO
    }
    
    return message;
}

@end

@implementation DefineGrammarMessage

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    
    NSString * languageModelContent = [self.languageModel createMessage];
    
    self.contentlength = [NSString stringWithFormat:@"%ld", (long)[languageModelContent length]];
    
    message = [message stringByAppendingString:[NSString stringWithFormat:@"Content-Length:%@\r\nContent-Type:%@\r\n", self.contentlength, self.languageModel.contentType]];
    
    message = [message stringByAppendingString: [NSString stringWithFormat:@"\r\n%@\r\n", languageModelContent]];
    
    return message;
}

@end

@implementation InterpretText

- (NSString *)createMessage {
    NSString * message = [super createMessage];
    
    NSString * languageModelContent = [self.languageModel createMessage];
    self.contentlength = [NSString stringWithFormat:@"%ld", (long)[languageModelContent length]];
    
    message = [message stringByAppendingString:[NSString stringWithFormat:@"Content-Length:%@\r\nContent-Type:%@\r\n", self.contentlength, self.languageModel.contentType]];
    
    message = [message stringByAppendingString: [NSString stringWithFormat:@"\r\n%@\r\n", languageModelContent]];
    return message;
}

@end







