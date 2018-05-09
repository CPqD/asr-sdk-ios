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
