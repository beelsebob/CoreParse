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

@implementation CPLR1Parser

- (NSSet *)closure:(NSSet *)i underGrammar:(CPGrammar *)g
{
    NSMutableSet *j = [i mutableCopy];
    NSMutableArray *processingQueue = [[j allObjects] mutableCopy];
    
    while ([processingQueue count] > 0)
    {
        CPLR1Item *item = (CPLR1Item *)[processingQueue objectAtIndex:0];
        NSArray *followingSymbols = [item followingSymbols];
        NSObject *nextSymbol = [followingSymbols count] > 0 ? [followingSymbols objectAtIndex:0] : nil;
        if ([nextSymbol isKindOfClass:[CPNonTerminal class]])
        {
            NSArray *rules = [g rulesForNonTerminal:(CPNonTerminal *)nextSymbol];
            for (CPRule *r in rules)
            {
                NSArray *afterNext = [followingSymbols subarrayWithRange:NSMakeRange(1, [followingSymbols count] - 1)];
                NSArray *afterNextWithTerminal = [afterNext arrayByAddingObject:[item terminal]];
                NSSet *firstAfterNext = [g first:afterNextWithTerminal];
                for (NSObject *o in firstAfterNext)
                {
                    if ([o isKindOfClass:[CPTerminal class]])
                    {
                        CPLR1Item *newItem = [CPLR1Item lr1ItemWithRule:r position:0 terminal:(CPTerminal *)o];
                        if (nil == [j member:newItem])
                        {
                            [processingQueue addObject:newItem];
                            [j addObject:newItem];
                        }
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
    return [self closure:[[i objectsPassingTest:^ BOOL (id obj, BOOL *stop)
                           {
                               return [symbol isEqual:[obj nextSymbol]];
                           }]
                          map:^ id (id obj)
                          {
                              return [(CPItem *)obj itemByMovingDotRight];
                          }] underGrammar:g];
}

- (NSArray *)itemsForGrammar:(CPGrammar *)aug
{
    CPRule *startRule = [[aug rulesForNonTerminal:[CPNonTerminal nonTerminalWithName:@"s'"]] objectAtIndex:0];
    NSSet *initialItemSet = [self closure:[NSSet setWithObject:[CPItem itemWithRule:startRule position:0]] underGrammar:aug];
    NSMutableArray *c = [NSMutableArray arrayWithObject:initialItemSet];
    NSMutableArray *processingQueue = [NSMutableArray arrayWithObject:initialItemSet];
    
    while ([processingQueue count] > 0)
    {
        NSSet *itemSet = [processingQueue objectAtIndex:0];
        NSSet *validNexts = [itemSet map:^ id (id obj) { return [(CPItem *)obj nextSymbol]; }];
        
        [validNexts enumerateObjectsUsingBlock:^(id o, BOOL *s)
         {
             NSSet *g = [self gotoWithItems:itemSet symbol:o underGrammar:aug];
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
