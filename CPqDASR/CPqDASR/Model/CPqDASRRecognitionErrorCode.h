//
//  CPqDASRRecognitionErrorCode.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#ifndef CPqDASRRecognitionErrorCode_h
#define CPqDASRRecognitionErrorCode_h

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, CPqDASRRecognitionErrorCode){
        CPqDASRRecognitionErrorCodeSessionTimeout = 0,
        CPqDASRRecognitionErrorCodeConnectionFailure,
        CPqDASRRecognitionErrorCodeUnauthorized,

        CPqDASRRecognitionErrorCodeFailure = 100
};

#endif /* CPqDASRRecognitionErrorCode_h */
