//
//  CPqDASRReturnCode.h
//  CPqDASR
//
//  Created by rodrigomorbach on 19/08/16.
//  Copyright © 2016 CPqD. All rights reserved.
//

#ifndef CPqDASRReturnCode_h
#define CPqDASRReturnCode_h

typedef NS_ENUM(NSInteger, ASRReturnCode)
{
    ASRReturnCodeNetworkError = 1001,
    ASRReturnCodeUndefinedURL = 1002,
    ASRReturnCodeInvalidCertificate = 1003,
    ASRReturnCodeInvalidUsernameOrPassword = 1004,
    ASRReturnCodeNetworkTimeout = 1005,
    ASRReturnCodeAudioError = 2001,
    ASRReturnCodeMicPermissionDenied = 2002,
    ASRReturnCodeRecognitionNoMatch = 3001,
    ASRReturnCodeRecognitionNoInputTimeout,
    ASRReturnCodeRecognitionMaxSpeech,
    ASRReturnCodeRecognitionSpeechTooEarly,
    ASRReturnCodeRecognitionTimeout,
    ASRReturnCodeRecognitionNoSpeech,
    ASRReturnCodeRecognitionCanceled,
    ASRReturnCodeFailure,
    //Server error-code
    ASRReturnCodeERRInvalidArgument = 4001,
    ASRReturnCodeERRBufferOverflow,
    ASRReturnCodeERRBadAlloc,
    ASRReturnCodeERRInternalError,
    ASRReturnCodeERRInvalidState,
    ASRReturnCodeERREngineNotFound,
    ASRReturnCodeERRRecogCreate,
    ASRReturnCodeERRSessionNotFound,
    ASRReturnCodeERRPathRead,
    ASRReturnCodeERRRequiredAMNotAllowed,
    ASRReturnCodeERRLMNotFound,
    ASRReturnCodeERRResult,
    ASRReturnCodeERRNotActiveLM,
    ASRReturnCodeERRMaxLicenses,
    ASRReturnCodeERRLicenseNotFound,
    ASRReturnCodeERRLicenseParser,
    ASRReturnCodeERRLicenseExpiration,
    ASRReturnCodeERRLicenseUnAuthorized,
    ASRReturnCodeERRLicenseHardInfo,
    ASRReturnCodeERRNotListenningAudio,
    ASRReturnCodeERRCorruptedLM,
    
    ASRReturnCodeERRBusy = 5001,
    ASRReturnCodeERRInvalidParameter,
    ASRReturnCodeERRInvalidParameterValue,
    
    ASRReturnCodeUndefinedError = 1000
};

#endif /* CPqDASRReturnCode_h */
