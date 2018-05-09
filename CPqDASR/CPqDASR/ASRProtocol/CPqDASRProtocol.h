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


#import <Foundation/Foundation.h>
#import "CPqDASRReturnCode.h"
#import <CPqDASR/CPqDASRRecognitionStatus.h>

//Constants
extern NSString *const kASRProtocolWSURL;
extern NSString *const kASRProtocolCarriageReturnNewLine;

extern NSString *const kASRProtocolCreateSession;
extern NSString *const kASRProtocolStartRecognition;
extern NSString *const kASRProtocolReleaseSession;
extern NSString *const kASRProtocolSendAudio;
extern NSString *const kASRProtocolStopRecognition;
extern NSString *const kASRProtocolRecognitionResult;
extern NSString *const kASRProtocolRecognitionEndOfSpeech;
extern NSString *const kASRProtocolInvalidAction;
extern NSString *const kASRProtocolCancelRecognition;

extern NSString *const kASRProtocolGetParameters;
extern NSString *const kASRProtocolSetParameters;

extern NSString *const kASRProtocolResponse;
extern NSString *const kASRProtocolResponseStatusRecognizing;
extern NSString *const kASRProtocolResponseStatusListening;
extern NSString *const kASRProtocolResponseStatusIdle;


extern NSString *const kASRProtocolResponseFailure;
extern NSString *const kASRProtocolResponseErrorCode;
extern NSString *const kASRProtocolResponseExpires;
extern NSString *const kASRProtocolResponseMessage;
extern NSString *const kASRProtocolResponseResultSuccess;

//Result-Status
extern NSString *const kASRProtocolResponseResultRecognized;
extern NSString *const kASRProtocolResponseResultProcessing;
extern NSString *const kASRProtocolResponseResultNoInputTimeOut;
extern NSString *const kASRProtocolResponseResultMaxSpeech;
extern NSString *const kASRProtocolResponseResultEarlySpeech;
extern NSString *const kASRProtocolResponseResultNoSpeech;
extern NSString *const kASRProtocolResponseResultCanceled;
extern NSString *const kASRProtocolResponseResultNoMatch;
extern NSString *const kASRProtocolResponseResultRecognitionTimeOut;
extern NSString *const kASRProtocolResponseResultFailure;

//Error-code possible values
extern NSString *const kASRProtocolERRGeneric;
extern NSString *const kASRProtocolERRInvalidArgument;
extern NSString *const kASRProtocolERRBufferOverflow;
extern NSString *const kASRProtocolERRBadAlloc;
extern NSString *const kASRProtocolERRInternalError;
extern NSString *const kASRProtocolERRInvalidState;
extern NSString *const kASRProtocolERREngineNotFound;
extern NSString *const kASRProtocolERRRecogCreate;
extern NSString *const kASRProtocolERRSessionNotFound;
extern NSString *const kASRProtocolERRPathRead;
extern NSString *const kASRProtocolERRArgInvalid;
extern NSString *const kASRProtocolERRFileOpen;
extern NSString *const kASRProtocolERRResult;
extern NSString *const kASRProtocolERRNotActiveLM;
extern NSString *const kASRProtocolERRMaxLicenses;
extern NSString *const kASRProtocolERRLicenseNotFound;
extern NSString *const kASRProtocolERRLicenseParser;
extern NSString *const kASRProtocolERRLicenseExpiration;
extern NSString *const kASRProtocolERRLicenseUnAuthorized;
extern NSString *const kASRProtocolERRLicenseHardInfo;
extern NSString *const kASRProtocolERRNotListenningAudio;

extern NSString *const kASRProtocolERRBusy;
extern NSString *const kASRProtocolERRInvalidParameter;
extern NSString *const kASRProtocolERRInvalidParameterValue;
extern NSString *const kASRProtocolERRCorruptedLM;


//ASRProtocol Enums
typedef NS_ENUM(NSInteger, ASRSessionStatus)
{
    //NO session has been created
    ASRSessionStatusIdle = 0,
    //START_RECOGITION has returned Success == true
    ASRSessionStatusListening,
    //Last packet has been sent using SEND_AUDIO
    ASRSessionStatusRecognizing
};

@interface ASRMessage : NSObject

@property (nonatomic) NSString * handle;

@property (nonatomic) NSString * contentType;

@property (nonatomic) NSString * contentlength;

@property (nonatomic) NSString * appName;

@property (nonatomic) NSString * appVersion;

@property (nonatomic, strong) NSString * method;

@property (nonatomic) NSData * payload;

- (instancetype)initWithMessage:(NSString *)message;

//Subclasses should override this
- (NSString *)createMessage;

@end

//Response objects
@interface ASRResponseMessage: ASRMessage

@property (nonatomic) NSString * result;

@property (nonatomic, copy) NSString * message;

@property (nonatomic) NSInteger errorCode;

@property (nonatomic) NSString * expires;

@property (nonatomic, assign) ASRSessionStatus sessionStatus;

@property (nonatomic) NSString * resultStatus;

- (ASRReturnCode)returnCodeFromErrorMessage:(NSString *)errorMessage;

@end

/**
 Recognition objects
 */
@interface ASRRecognitionResultWord : NSObject

@property (nonatomic, strong) NSString * text;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) NSTimeInterval endTime;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface ASRRecognitionResultAlternative: NSObject

@property (nonatomic, strong) NSString * text;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, strong) NSArray * interpretations;

@property (nonatomic, strong) NSArray <NSNumber *> * intepretationScoreList;

@property (nonatomic, strong) NSString * languageModel;

@property (nonatomic, strong) NSArray <ASRRecognitionResultWord *> * words;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface ASRRecognitionResult : NSObject

@property (nonatomic, strong) NSArray <ASRRecognitionResultAlternative *> * alternatives;

@property (nonatomic) CPqDASRRecognitionStatus recognitionStatus;

@property (nonatomic, assign) NSInteger speechSegmentIndex;

@property (nonatomic, assign) BOOL lastSpeechSegment;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, assign) BOOL finalResult;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface ASRRecognitionResultMessage: ASRResponseMessage

//Hold all attributes of result response
@property (nonatomic, strong) NSDictionary * resultDictionary;

@property (nonatomic) CPqDASRRecognitionStatus recognitionStatus;

@property (nonatomic, strong) ASRRecognitionResult * recognitionResult;

@property (nonatomic, assign) BOOL isFinalResult;

@end


/**
 End of recognition objects
 */
@interface ASREndofSpeechMessage : ASRResponseMessage

@end


@interface ASRStartSpeechMessage : ASRResponseMessage

@end

//Request Objects
@interface ASRCreateSession : ASRMessage

@property (nonatomic) NSString * userAgent;

@end

@interface ASRSendAudio : ASRMessage

@property (nonatomic) BOOL lastPacket;

@end

@class LanguageModel;

@interface ASRStartRecognition : ASRMessage

@property (nonatomic) NSDictionary * parameters;

@property (nonatomic) NSString * grammar;

@property (nonatomic) LanguageModel * languageModel;

@end

/**
 *@todo - Not used
 */
@interface ASRStopRecognition : ASRMessage

@end

@interface ASRReleaseSession: ASRMessage

@end

@interface ASRCancelRecognition : ASRMessage

@end

@interface ASRGetParametersMessage : ASRMessage

@property (nonatomic, copy) NSString * parameters;

@end

@interface ASRSetParametersMessage : ASRMessage

- (void)setRecognitionParameters:(NSDictionary *)headers;

@end

@interface LanguageModel : NSObject

@property (nonatomic, copy) NSString * uri;

@property (nonatomic, copy) NSString * definition;

//Content-ID
@property (nonatomic, copy) NSString * _id;

@property (nonatomic, copy) NSString * contentType;

- (NSString *)createMessage;

@end

@interface DefineGrammarMessage : ASRMessage

@property (nonatomic, strong) LanguageModel * languageModel;

@end

@interface InterpretText : ASRMessage

@property (nonatomic, strong) LanguageModel * languageModel;

@property (nonatomic, strong) NSString * text;

@property (nonatomic, strong) NSString * accept;

@end

@interface StartInputTimersMessage : ASRMessage

@end

@interface ASRProtocolEncoder : NSObject

+ (ASRMessage *)decode:(NSString *)receivedMessage;

@end
