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
