//
//  CPLR1Parser.m
//  CoreParse
//
//  Created by Tom Davie on 12/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPLR1Parser.h"

#import "CPLR1Item.h"
#import "NSSetFunctional.h"

@interface CPLR1Parser ()

- (BOOL)constructShiftReduceTables;

- (NSSet *)closure:(NSSet *)i underGrammar:(CPGrammar *)g;
- (NSSet *)gotoWithItems:(NSSet *)i symbol:(NSObject *)symbol underGrammar:(CPGrammar *)g;
- (NSArray *)itemsForGrammar:(CPGrammar *)aug;

@end

@implementation CPLR1Parser

- (BOOL)constructShiftReduceTables
{
    CPGrammar *aug = [[self grammar] augmentedGrammar];
    NSArray *items = [self itemsForGrammar:aug];
    NSUInteger itemCount = [items count];
    
    [self setActionTable:[[[CPShiftReduceActionTable alloc] initWithCapacity:itemCount] autorelease]];
    [self setGotoTable:[[[CPShiftReduceGotoTable   alloc] initWithCapacity:itemCount] autorelease]];
    
    NSUInteger idx = 0;
    for (NSSet *itemsSet in items)
    {
        for (CPLR1Item *item in itemsSet)
        {
            CPGrammarSymbol *next = [item nextSymbol];
            if ([next isTerminal])
            {
                NSSet *g = [self gotoWithItems:itemsSet symbol:next underGrammar:aug];
                NSUInteger ix = [items indexOfObject:g];
                BOOL success = [[self actionTable] setAction:[CPShiftReduceAction shiftAction:ix] forState:idx name:[next name]];
                if (!success)
                {
                    return NO;
                }
            }
            else if (nil == next)
            {
                if ([[[item rule] name] isEqualToString:@"s'"])
                {
                    BOOL success = [[self actionTable] setAction:[CPShiftReduceAction acceptAction] forState:idx name:@"EOF"];
                    if (!success)
                    {
                        return NO;
                    }
                }
                else
                {
                    BOOL success = [[self actionTable] setAction:[CPShiftReduceAction reduceAction:[item rule]] forState:idx name:[[item terminal] name]];
                    if (!success)
                    {
                        return NO;
                    }
                }
            }
        }
        idx++;
    }
    
    NSArray *allNonTerminalNames = [[self grammar] allNonTerminalNames];
    idx = 0;
    for (NSSet *itemsSet in items)
    {
        for (NSString *nonTerminalName in allNonTerminalNames)
        {
            NSSet *g = [self gotoWithItems:itemsSet symbol:[CPGrammarSymbol nonTerminalWithName:nonTerminalName] underGrammar:aug];
            NSUInteger gotoIndex = [items indexOfObject:g];
            BOOL success = [[self gotoTable] setGoto:gotoIndex forState:idx nonTerminalNamed:nonTerminalName];
            if (!success)
            {
                return NO;
            }
        }
        idx++;
    }
    
    return YES;
}

- (NSSet *)closure:(NSSet *)i underGrammar:(CPGrammar *)g
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
            NSArray *rules = [g rulesForNonTerminalWithName:[(CPGrammarSymbol *)nextSymbol name]];
            for (CPRule *r in rules)
            {
                NSArray *afterNext = [followingSymbols subarrayWithRange:NSMakeRange(1, [followingSymbols count] - 1)];
                NSArray *afterNextWithTerminal = [afterNext arrayByAddingObject:[item terminal]];
                NSSet *firstAfterNext = [g first:afterNextWithTerminal];
                for (NSString *o in firstAfterNext)
                {
                    CPLR1Item *newItem = [CPLR1Item lr1ItemWithRule:r position:0 terminal:[CPGrammarSymbol terminalWithName:o]];
                    if (nil == [j member:newItem])
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

- (NSSet *)gotoWithItems:(NSSet *)i symbol:(NSObject *)symbol underGrammar:(CPGrammar *)g
{
    return [self closure:[[i objectsPassingTest:^ BOOL (CPItem *item, BOOL *stop)
                           {
                               return [symbol isEqual:[item nextSymbol]];
                           }]
                          map:^ id (CPItem *item)
                          {
                              return [item itemByMovingDotRight];
                          }] underGrammar:g];
}

- (NSArray *)itemsForGrammar:(CPGrammar *)aug
{
    CPRule *startRule = [[aug rulesForNonTerminalWithName:@"s'"] objectAtIndex:0];
    NSSet *initialItemSet = [self closure:[NSSet setWithObject:[CPLR1Item lr1ItemWithRule:startRule position:0 terminal:[CPGrammarSymbol terminalWithName:@"EOF"]]] underGrammar:aug];
    NSMutableArray *c = [NSMutableArray arrayWithObject:initialItemSet];
    NSMutableArray *processingQueue = [NSMutableArray arrayWithObject:initialItemSet];
    
    while ([processingQueue count] > 0)
    {
        NSSet *itemSet = [processingQueue objectAtIndex:0];
        NSSet *validNexts = [itemSet map:^ id (CPItem *item)
                             {
                                 return [item nextSymbol];
                             }];
        
        [validNexts enumerateObjectsUsingBlock:^(CPGrammarSymbol *s, BOOL *st)
         {
             NSSet *g = [self gotoWithItems:itemSet symbol:s underGrammar:aug];
             if (![c containsObject:g])
             {
                 [processingQueue addObject:g];
                 [c addObject:g];
             }
         }];
        
        [processingQueue removeObjectAtIndex:0];
    }
    
    return c;
}

@end
