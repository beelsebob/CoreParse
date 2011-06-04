//
//  CPGrammarInternal.h
//  CoreParse
//
//  Created by Tom Davie on 04/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammar.h"

@interface CPGrammar (CPGrammarInternal)

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
