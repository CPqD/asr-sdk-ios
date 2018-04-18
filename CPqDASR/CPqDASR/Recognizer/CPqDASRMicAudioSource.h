//
//  CPqDASRMicAudioSource.h
//  CPqDASR
//
//  Created by rodrigomorbach on 05/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRAudioSource.h>
#import <CPqDASR/CPqDASRSampleRate.h>

@protocol CPqDASRMicAudioSourceDelegate <NSObject>

- (void)didFailWithError:(NSError *)error;

@end

@interface CPqDASRMicAudioSource : NSObject <CPqDASRAudioSource>

@property (nonatomic, weak) id<CPqDASRAudioSourceDelegate> delegate;

- (instancetype)initWithDelegate:(id<CPqDASRMicAudioSourceDelegate>)micDelegate andSampleRate:(CPqDASRSampleRate)sampleRate;

- (void)setDetectEndOfSpeech:(BOOL)flag;

@end
