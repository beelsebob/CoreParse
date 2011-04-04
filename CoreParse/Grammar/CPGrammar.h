//
//  Grammar.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammarSymbol.h"
#import "CPRule.h"

@interface CPGrammar : NSObject
{}

@property (readwrite,retain) NSString *start;

+ (id)grammarWithStart:(NSString *)start rules:(NSArray *)rules;
- (id)initWithStart:(NSString *)start rules:(NSArray *)rules;

+ (id)grammarWithStart:(NSString *)start backusNaurForm:(NSString *)bnf;
- (id)initWithStart:(NSString *)start backusNaurForm:(NSString *)bnf;

- (NSSet *)allRules;
- (NSArray *)allNonTerminalNames;

- (void)addRule:(CPRule *)rule;
- (NSArray *)rulesForNonTerminalWithName:(NSString *)nonTerminalName;

- (CPGrammar *)augmentedGrammar;

- (NSUInteger)indexOfRule:(CPRule *)rule;

- (NSSet *)lr0Closure:(NSSet *)i;
- (NSSet *)lr0GotoKernelWithItems:(NSSet *)i symbol:(CPGrammarSymbol *)symbol;
- (NSArray *)lr0Kernels;

- (NSSet *)lr1Closure:(NSSet *)i;
- (NSSet *)lr1GotoKernelWithItems:(NSSet *)i symbol:(CPGrammarSymbol *)symbol;

- (NSSet *)follow:(NSString *)name;
- (NSSet *)first:(NSArray *)obj;

- (NSString *)uniqueSymbolNameBasedOnName:(NSString *)name;

@end
