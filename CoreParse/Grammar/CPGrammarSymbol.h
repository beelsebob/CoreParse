//
//  CPGrammarSymbol.h
//  CoreParse
//
//  Created by Tom Davie on 13/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CPGrammarSymbol : NSObject
{}

@property (readwrite, copy  ) NSString *name;
@property (readwrite, assign) BOOL isTerminal;

+ (id)nonTerminalWithName:(NSString *)name;
- (id)initWithNonTerminalName:(NSString *)name;

+ (id)terminalWithName:(NSString *)name;
- (id)initWithTerminalName:(NSString *)name;

@end
