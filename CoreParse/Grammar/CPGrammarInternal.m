//
//  CPGrammarInternal.m
//  CoreParse
//
//  Created by Tom Davie on 04/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammarInternal.h"
#import "CPGrammarPrivate.h"

#import "CPItem.h"
#import "CPLR1Item.h"

#import "NSSetFunctional.h"

@implementation CPGrammar (CPGrammarInternal)

- (CPGrammar *)augmentedGrammar
{
    return [[[CPGrammar alloc] initWithStart:@"s'"
                                       rules:[[self rules] arrayByAddingObject:[CPRule ruleWithName:@"s'" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:[self start]]]]]]
            autorelease];
}

- (NSUInteger)indexOfRule:(CPRule *)rule
{
    return [[self orderedRules] indexOfObject:rule];
}

- (NSString *)description
{
    NSArray *ordered = [self orderedRules];
    NSMutableString *s = [NSMutableString string];
    NSUInteger idx = 0;
    for (CPRule *r in ordered)
    {
        [s appendFormat:@"%3d %@\n", idx, r];
        idx++;
    }
    
    return s;
}

- (NSSet *)lr0Closure:(NSSet *)i
{
    NSMutableSet *j = [i mutableCopy];
    NSMutableArray *processingQueue = [[j allObjects] mutableCopy];
    
    while ([processingQueue count] > 0)
    {
        CPItem *item = [processingQueue objectAtIndex:0];
        CPGrammarSymbol *nextSymbol = [item nextSymbol];
        if (![nextSymbol isTerminal])
        {
            [[self rulesForNonTerminalWithName:[nextSymbol name]] enumerateObjectsUsingBlock:^(CPRule *rule, NSUInteger ix, BOOL *s)
             {
                 CPItem *newItem = [CPItem itemWithRule:rule position:0];
                 if (![j containsObject:newItem])
                 {
                     [processingQueue addObject:newItem];
                     [j addObject:newItem];
                 }
             }];
        }
        
        [processingQueue removeObjectAtIndex:0];
    }
    
    [processingQueue release];
    
    return [j autorelease];
}

- (NSSet *)lr0GotoKernelWithItems:(NSSet *)i symbol:(CPGrammarSymbol *)symbol
{
    return [[i objectsPassingTest:^ BOOL (CPItem *item, BOOL *stop)
             {
                 return [symbol isEqual:[item nextSymbol]];
             }]
            map:^ id (CPItem *item)
            {
                return [item itemByMovingDotRight];
            }];
}

- (NSArray *)lr0Kernels
{
    CPRule *startRule = [[self rulesForNonTerminalWithName:[self start]] objectAtIndex:0];
    NSSet *initialKernel = [NSSet setWithObject:[CPItem itemWithRule:startRule position:0]];
    NSMutableArray *c = [NSMutableArray arrayWithObject:initialKernel];
    NSMutableArray *processingQueue = [NSMutableArray arrayWithObject:initialKernel];
    
    while ([processingQueue count] > 0)
    {
        NSSet *kernel = [processingQueue objectAtIndex:0];
        NSSet *itemSet = [self lr0Closure:kernel];
        NSSet *validNexts = [itemSet map:^ id (CPItem *item) { return [item nextSymbol]; }];
        
        for (CPGrammarSymbol *s in validNexts)
        {
            NSSet *g = [self lr0GotoKernelWithItems:itemSet symbol:s];
            if (![c containsObject:g])
            {
                [processingQueue addObject:g];
                [c addObject:g];
            }
        }
        
        [processingQueue removeObjectAtIndex:0];
    }
    
    return c;
}

- (NSSet *)lr1Closure:(NSSet *)i
{
    NSMutableSet *j = [i mutableCopy];
    NSMutableArray *processingQueue = [[j allObjects] mutableCopy];
    
    while ([processingQueue count] > 0)
    {
        CPLR1Item *item = (CPLR1Item *)[processingQueue objectAtIndex:0];
        NSArray *followingSymbols = [item followingSymbols];
        CPGrammarSymbol *nextSymbol = [followingSymbols count] > 0 ? [followingSymbols objectAtIndex:0] : nil;
        if (![nextSymbol isTerminal])
        {
            NSArray *rs = [self rulesForNonTerminalWithName:[(CPGrammarSymbol *)nextSymbol name]];
            for (CPRule *r in rs)
            {
                NSArray *afterNext = [followingSymbols subarrayWithRange:NSMakeRange(1, [followingSymbols count] - 1)];
                NSArray *afterNextWithTerminal = [afterNext arrayByAddingObject:[item terminal]];
                NSSet *firstAfterNext = [self first:afterNextWithTerminal];
                for (NSString *o in firstAfterNext)
                {
                    CPLR1Item *newItem = [CPLR1Item lr1ItemWithRule:r position:0 terminal:[CPGrammarSymbol terminalWithName:o]];
                    if (![j containsObject:newItem])
                    {
                        [processingQueue addObject:newItem];
                        [j addObject:newItem];
                    }
                }
            }
        }
        
        [processingQueue removeObjectAtIndex:0];
    }
    
    [processingQueue release];
    
    return [j autorelease];
}

- (NSSet *)lr1GotoKernelWithItems:(NSSet *)i symbol:(CPGrammarSymbol *)symbol
{
    return [[i objectsPassingTest:^ BOOL (CPItem *item, BOOL *stop)
             {
                 return [symbol isEqual:[item nextSymbol]];
             }]
            map:^ id (CPItem *item)
            {
                return [item itemByMovingDotRight];
            }];
}

- (NSSet *)follow:(NSString *)name
{
    NSSet *follows = [[self followCache] objectForKey:name];
    
    if (nil == follows)
    {
        NSMutableSet *f = [NSMutableSet setWithObject:@"EOF"];
        for (CPRule *rule in [self allRules])
        {
            NSArray *rightHandSide = [rule rightHandSideElements];
            NSUInteger numElements = [rightHandSide count];
            [rightHandSide enumerateObjectsUsingBlock:^(CPGrammarSymbol *rhsE, NSUInteger idx, BOOL *s)
             {
                 if (![rhsE isTerminal] && [[rhsE name] isEqualToString:name])
                 {
                     if (idx + 1 < numElements)
                     {
                         NSSet *first = [self first:[rightHandSide subarrayWithRange:NSMakeRange(idx+1, [rightHandSide count] - idx - 1)]];
                         NSSet *firstMinusEmpty = [first objectsPassingTest:^ BOOL (NSString *symbolName, BOOL *fstop)
                                                   {
                                                       return ![symbolName isEqualToString:@""];
                                                   }];
                         [f unionSet:firstMinusEmpty];
                     }
                     else if (![[rule name] isEqualToString:name])
                     {
                         [f unionSet:[self follow:[rule name]]];
                     }
                 }
             }];
        }
        
        follows = f;
        [[self followCache] setObject:f forKey:name];
    }
    
    return follows;
}

- (NSSet *)first:(NSArray *)symbols
{
    NSMutableSet *f = [NSMutableSet set];
    
    for (CPGrammarSymbol *symbol in symbols)
    {
        NSSet *f1 = [self firstSymbol:symbol];
        [f unionSet:f1];
        if (![f1 containsObject:@""])
        {
            break;
        }
    }
    
    return f;
}

- (NSString *)uniqueSymbolNameBasedOnName:(NSString *)name
{
    NSString *testName = [[name copy] autorelease];
    NSSet *allSymbols = [self allSymbolNames];
    while ([allSymbols containsObject:testName])
    {
        testName = [NSString stringWithFormat:@"_%@", testName];
    }
    
    return testName;
}

@end
