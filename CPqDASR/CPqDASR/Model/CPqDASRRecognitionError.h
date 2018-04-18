//
//  CPqDASRRecognitionError.h
//  CPqDASR
//
//  Created by rodrigomorbach on 04/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRRecognitionErrorCode.h>

@interface CPqDASRRecognitionError : NSObject

@property (nonatomic, strong) NSString * message;

@property (nonatomic, assign) CPqDASRRecognitionErrorCode code;

@end
