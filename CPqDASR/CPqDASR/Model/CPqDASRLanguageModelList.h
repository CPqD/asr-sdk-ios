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

@interface CPqDASRLanguageModelList : NSObject

/** the language model URI list. */
@property (nonatomic, strong, readonly) NSArray <NSString *> * uriList;

/** the inline grammar body list. */
@property (nonatomic, strong, readonly) NSArray <NSArray *> * grammarList;

/** the phrase rule list. */
@property (nonatomic, strong, readonly) NSArray <NSString *> * phraseRuleList;


- (instancetype)initWithUriList:(NSArray *)uriList
                    grammarList:(NSArray *)grammarList
                 phraseRuleList:(NSArray *)phraseRuleList;

/**
 * Adds a new grammar content.
 *
 * @param grammarId
 *            the grammar identification.
 * @param grammarBody
 *            the grammar body content.
 */
- (void)addInlineGrammar:(NSString *)grammarId body:(NSString *)grammarBody;

/**
 * Adds a new language model URI.
 *
 * @param uri
 *            the languagem model URI.
 */
- (void)addURI:(NSString *)uri;

/**
 * Adds a new phrase rule.
 *
 * @param phrase
 *            the phrase rule.
 */
- (void)addPhraseRule:(NSString *)phrase;

@end
