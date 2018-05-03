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
