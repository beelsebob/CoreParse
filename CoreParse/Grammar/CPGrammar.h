//
//  Grammar.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPNonTerminal.h"
#import "CPRule.h"

@interface CPGrammar : NSObject
{}

@property (readwrite,retain) CPNonTerminal *start;

+ (id)grammarWithStart:(CPNonTerminal *)start rules:(NSArray *)rules;
- (id)initWithStart:(CPNonTerminal *)start rules:(NSArray *)rules;

- (NSSet *)allRules;
- (NSArray *)allNonTerminalNames;

- (void)addRule:(CPRule *)rule;
- (NSArray *)rulesForNonTerminal:(CPNonTerminal *)nonTerminal;

- (CPGrammar *)augmentedGrammar;

- (NSUInteger)indexOfRule:(CPRule *)rule;

- (NSSet *)follow:(NSString *)name;
- (NSSet *)first:(NSObject *)obj;

@end
