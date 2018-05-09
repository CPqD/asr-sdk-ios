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

#import <CPqDASR/CPqDASRAudioSource.h>

@interface CPqDASRBufferAudioSource : NSObject <CPqDASRAudioSource>

@property (nonatomic, weak) id<CPqDASRAudioSourceDelegate> delegate;

/**
 @brief Writes the specified data to the circular buffer
 @param data to be written
 @return indicator of success
 */
- (BOOL)write:(NSData *)data;

@end
