//
//  CPGrammarPrivate.h
//  CoreParse
//
//  Created by Tom Davie on 04/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammar.h"

@interface CPGrammar (CPGrammarPrivate)

@property (readwrite,copy  ) NSArray *rules;

@property (readwrite,strong) NSMutableDictionary *rulesByNonTerminal;
@property (readwrite,strong) NSMutableDictionary *followCache;

- (NSArray *)orderedRules;

- (NSSet *)allSymbolNames;
- (NSSet *)symbolNamesInRules:(NSArray *)rules;
- (NSSet *)firstSymbol:(CPGrammarSymbol *)obj;

@end
