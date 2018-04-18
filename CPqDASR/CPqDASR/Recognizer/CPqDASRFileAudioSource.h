//
//  CPqDASRFileAudioSource.h
//  CPqDASR
//
//  Created by rodrigomorbach on 17/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRAudioSource.h>

@interface CPqDASRFileAudioSource : NSObject <CPqDASRAudioSource>

@property (nonatomic, weak) id<CPqDASRAudioSourceDelegate> delegate;

- (instancetype)initWithFilePath:(NSString *)path;

@end
