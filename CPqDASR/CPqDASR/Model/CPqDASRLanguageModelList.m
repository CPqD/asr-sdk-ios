//
//  CPqDASRLanguageModelList.m
//  CPqDASR
//
//  Created by rodrigomorbach on 10/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#import <CPqDASR/CPqDASRLanguageModelList.h>
#import <Foundation/NSObjCRuntime.h>

NSExceptionName const NSOutOfBoundsException;

@implementation CPqDASRLanguageModelList


- (instancetype)initWithUriList:(NSArray *)uriList
                    grammarList:(NSArray *)grammarList
                 phraseRuleList:(NSArray *)phraseRuleList {
    
    if (grammarList.count > 0) {
        @throw [NSException exceptionWithName:NSOutOfBoundsException reason:@"Only one grammar is supported" userInfo:nil];
    }
    
    if (self = [super init]){
        _uriList = uriList;
        _grammarList = grammarList;
        _phraseRuleList = phraseRuleList;        
    }
    return self;
}

- (void)addInlineGrammar:(NSString *)grammarId body:(NSString *)grammarBody {
    
    if (self.grammarList.count > 0) {
        @throw [NSException exceptionWithName:NSOutOfBoundsException reason:@"Only one grammar is supported" userInfo:nil];            
    }
    
    NSMutableArray<NSArray *> * mGrammarList = [[NSMutableArray alloc] init];
    NSArray * grammar = [[NSArray alloc] initWithObjects:grammarId, grammarBody, nil];
    
    [mGrammarList addObject:grammar];
    
    _grammarList = [NSArray arrayWithArray:mGrammarList];
}

- (void)addURI:(NSString *)uri {
    NSMutableArray * mUriList;
    if (self.uriList != nil) {
        mUriList = [[NSMutableArray alloc] initWithArray:self.uriList];
    } else {
        mUriList = [[NSMutableArray alloc] init];
    }
    
    [mUriList addObject:uri];
    _uriList = [NSArray arrayWithArray:mUriList];
}

- (void)addPhraseRule:(NSString *)phrase {
    NSMutableArray * mPhraseRuleList;
    if (self.uriList != nil) {
        mPhraseRuleList = [[NSMutableArray alloc] initWithArray:self.phraseRuleList];
    } else {
        mPhraseRuleList = [[NSMutableArray alloc] init];
    }
    
    [mPhraseRuleList addObject:phrase];
    _phraseRuleList = [NSArray arrayWithArray:mPhraseRuleList];
}

@end
