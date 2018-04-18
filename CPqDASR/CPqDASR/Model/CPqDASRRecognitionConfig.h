//
//  CPqDASRRecognitionConfig.h
//  CPqDASR
//
//  Created by rodrigomorbach on 09/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPqDASRRecognitionConfig : NSObject

@property (nonatomic, strong) NSNumber * continuousMode;
@property (nonatomic, strong) NSNumber * confidenceThreshold;
@property (nonatomic, strong) NSNumber * maxSentences;
@property (nonatomic, strong) NSNumber * noInputTimeoutMilis;
@property (nonatomic, strong) NSNumber * noInputTimeoutEnabled;
@property (nonatomic, strong) NSNumber * recognitionTimeoutSeconds;
@property (nonatomic, strong) NSNumber * headMarginMilis;
@property (nonatomic, strong) NSNumber * tailMarginMilis;
@property (nonatomic, strong) NSNumber * waitEndMilis;
@property (nonatomic, strong) NSNumber * recognitionTimeoutEnabled;
@property (nonatomic, strong) NSNumber * startInputTimers;
@property (nonatomic, strong) NSNumber * endPointerAutoLevelLen;
@property (nonatomic, strong) NSNumber * endPointerLevelMode;
@property (nonatomic, strong) NSNumber * endPointerLevelThreshold;

- (NSDictionary *)getParametersMap;

@end
