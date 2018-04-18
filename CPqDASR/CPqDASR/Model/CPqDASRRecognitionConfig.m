//
//  CPqDASRRecognitionConfig.m
//  CPqDASR
//
//  Created by rodrigomorbach on 09/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import "CPqDASRRecognitionConfig.h"

NSString * kNoInputTimeoutEnabledKey = @"noInputTimeout.enabled";
NSString * kNoInputTimeoutValueKey = @"noInputTimeout.value";
NSString * kRecognitionTimeoutEnabledKey = @"recognitionTimeout.enabled";
NSString * kRecognitionTimeoutValueKey = @"recognitionTimeout.value";

NSString * kDecoderStartInputTimersKey = @"decoder.startInputTimers";
NSString * kDecoderMaxSentencesKey = @"decoder.maxSentences";
NSString * kDecoderContinuousModeKey = @"decoder.continuousMode";
NSString * kDecoderConfidenceThresholdKey = @"decoder.confidenceThreshold";


NSString * kEndpointerHeadMarginKey = @"endpointer.headMargin";
NSString * kEndpointerTailMarginKey = @"endpointer.tailMargin";
NSString * kEndpointerWaitEndKey = @"endpointer.waitEnd";
NSString * kEndpointerLeveThresholdKey = @"endpointer.levelThreshold";
NSString * kEndpointerLevelModeKey = @"endpointer.levelMode";
NSString * kEndpointerAutoLevelLenKey = @"endpointer.autoLevelLen";



@interface CPqDASRRecognitionConfig()

@end

@implementation CPqDASRRecognitionConfig

- (NSDictionary *)getParametersMap {
    
    NSMutableDictionary * map = [[NSMutableDictionary alloc] init];
    
    if (self.noInputTimeoutEnabled != nil) {
        NSString * value = [self booleanStringFromNumber:self.noInputTimeoutEnabled];
        [map setObject:value forKey: kNoInputTimeoutEnabledKey];
    }
    
    if (self.noInputTimeoutMilis != nil) {
        NSString * value = [NSString stringWithFormat:@"%@", self.noInputTimeoutMilis];
        [map setObject:value forKey: kNoInputTimeoutValueKey];
    }
    
    if (self.recognitionTimeoutEnabled != nil) {
        NSString * value = [self booleanStringFromNumber: self.noInputTimeoutEnabled];
        [map setObject:value forKey: kRecognitionTimeoutEnabledKey];
    }
    
    if (self.recognitionTimeoutSeconds != nil) {
        NSString * value = [NSString stringWithFormat:@"%@", self.self.recognitionTimeoutSeconds];;
        [map setObject:value forKey: kRecognitionTimeoutValueKey];
    }
    
    if (self.startInputTimers != nil) {
        NSString * value = [self booleanStringFromNumber:self.startInputTimers];
        [map setObject:value forKey: kDecoderStartInputTimersKey];
    }
    
    if (self.maxSentences != nil) {
        NSString * value = [NSString stringWithFormat: @"%@", self.maxSentences];
        [map setObject:value forKey: kDecoderMaxSentencesKey];
    }
    
    if (self.endPointerLevelMode != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.endPointerLevelMode];
        [map setObject:value forKey: kEndpointerLevelModeKey];
    }
    
    if (self.endPointerAutoLevelLen != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.endPointerAutoLevelLen];
        [map setObject:value forKey: kEndpointerAutoLevelLenKey];
    }
    
    if (self.headMarginMilis != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.headMarginMilis];
        [map setObject:value forKey: kEndpointerHeadMarginKey];
    }
    
    if (self.tailMarginMilis != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.tailMarginMilis];
        [map setObject:value forKey: kEndpointerTailMarginKey];
    }
    
    if (self.waitEndMilis != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.waitEndMilis];
        [map setObject:value forKey: kEndpointerWaitEndKey];
    }
    
    if (self.endPointerLevelThreshold != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.endPointerLevelThreshold];
        [map setObject:value forKey: kEndpointerLeveThresholdKey];
    }
    
    if (self.continuousMode != nil){
        NSString * value = [self booleanStringFromNumber:self.continuousMode];
        [map setObject:value forKey: kDecoderContinuousModeKey];
    }
    
    if (self.confidenceThreshold != nil){
        NSString * value = [NSString stringWithFormat: @"%@", self.confidenceThreshold];
        [map setObject:value forKey: kDecoderConfidenceThresholdKey];
    }

    return [NSDictionary dictionaryWithDictionary:map];
    
}

- (NSString *)booleanStringFromNumber:(NSNumber *)booleanNumber {
    NSString * value = ([booleanNumber boolValue] == YES) ? @"true" : @"false";
    return value;
}


@end
