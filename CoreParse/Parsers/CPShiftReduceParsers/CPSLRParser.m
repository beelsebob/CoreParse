//
//  CPSLRParser.m
//  CoreParse
//
//  Created by Tom Davie on 06/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPSLRParser.h"

#import "CPItem.h"
#import "CPTerminal.h"

#import "NSSetFunctional.h"

@interface CPSLRParser ()

- (BOOL)constructShiftReduceTables;

- (NSSet *)closure:(NSSet *)i underGrammar:(CPGrammar *)g;
- (NSSet *)gotoWithItems:(NSSet *)i symbol:(NSObject *)symbol underGrammar:(CPGrammar *)g;
- (NSArray *)itemsForGrammar:(CPGrammar *)aug;

@end

@implementation CPSLRParser

- (BOOL)constructShiftReduceTables
{
    CPGrammar *aug = [self.grammar augmentedGrammar];
    NSArray *items = [self itemsForGrammar:aug];
    NSUInteger itemCount = [items count];
    
    self.actionTable = [[[CPShiftReduceActionTable alloc] initWithCapacity:itemCount] autorelease];
    self.gotoTable   = [[[CPShiftReduceGotoTable   alloc] initWithCapacity:itemCount] autorelease];
    
    NSUInteger idx = 0;
    for (NSSet *itemsSet in items)
    {
        for (CPItem *item in itemsSet)
        {
            id next = [item nextSymbol];
            if ([next isKindOfClass:[CPTerminal class]])
            {
                CPTerminal *nextTerminal = (CPTerminal *)next;
                NSSet *g = [self gotoWithItems:itemsSet symbol:next underGrammar:aug];
                NSUInteger ix = [items indexOfObject:g];
                [self.actionTable setAction:[CPShiftReduceAction shiftAction:ix] forState:idx tokenName:[nextTerminal tokenName]];
            }
            else if (nil == next)
            {
                if ([[[item rule] name] isEqualToString:@"s'"])
                {
                    [self.actionTable setAction:[CPShiftReduceAction acceptAction] forState:idx tokenName:@"EOF"];
                }
                else
                {
                    NSSet *follow = [aug follow:[[item rule] name]];
                    [follow enumerateObjectsUsingBlock:^(id f, BOOL *fStop)
                     {
                         [self.actionTable setAction:[CPShiftReduceAction reduceAction:[item rule]] forState:idx tokenName:(NSString *)f];
                     }];
                }
            }
        }
        idx++;
    }

    NSArray *allNonTerminalNames = [self.grammar allNonTerminalNames];
    idx = 0;
    for (NSSet *itemsSet in items)
    {
        for (NSString *nonTerminalName in allNonTerminalNames)
        {
            NSSet *g = [self gotoWithItems:itemsSet symbol:[CPNonTerminal nonTerminalWithName:nonTerminalName] underGrammar:aug];
            NSUInteger gotoIndex = [items indexOfObject:g];
            [self.gotoTable setGoto:gotoIndex forState:idx nonTerminalNamed:nonTerminalName];
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
        CPItem *item = (CPItem *)[processingQueue objectAtIndex:0];
        NSObject *nextSymbol = [item nextSymbol];
        if ([nextSymbol isKindOfClass:[CPNonTerminal class]])
        {
            [[g rulesForNonTerminal:(CPNonTerminal *)nextSymbol] enumerateObjectsUsingBlock:^(id o, NSUInteger ix, BOOL *s)
             {
                 CPItem *newItem = [CPItem itemWithRule:(CPRule *)o position:0];
                 if (nil == [j member:newItem])
                 {
                     [processingQueue addObject:newItem];
                 }
                 [j addObject:newItem];
             }];
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
