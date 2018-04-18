//
//  CPqDASRLanguageModelList.h
//  CPqDASR
//
//  Created by rodrigomorbach on 10/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

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
