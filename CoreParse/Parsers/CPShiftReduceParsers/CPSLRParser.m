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
- (NSSet *)follow:(NSString *)name underGrammar:(CPGrammar *)g;
- (NSSet *)first:(NSString *)name underGrammar:(CPGrammar *)g;

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
                    NSSet *follow = [self follow:[[item rule] name] underGrammar:aug];
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
    return [self closure:[[i filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (id obj, NSDictionary *substitutions)
                                                        {
                                                            return [symbol isEqual:[obj nextSymbol]];
                                                        }]]
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

- (NSSet *)follow:(NSString *)name underGrammar:(CPGrammar *)g
{
    NSMutableSet *f = [NSMutableSet setWithObject:@"EOF"];
    [[g allRules] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
     {
         CPRule *rule = (CPRule *)obj;
         NSArray *rightHandSide = [rule rightHandSideElements];
         NSUInteger numElements = [rightHandSide count];
         [rightHandSide enumerateObjectsUsingBlock:^(id rhsE, NSUInteger idx, BOOL *s)
          {
              if ([rhsE isKindOfClass:[CPNonTerminal class]] && [[(CPNonTerminal *)rhsE name] isEqualToString:name])
              {
                  if (idx + 1 < numElements)
                  {
                      NSSet *first = [self first:[rightHandSide objectAtIndex:idx+1] underGrammar:g];
                      NSMutableSet *firstMinusEmpty = [[first mutableCopy] autorelease];
                      [firstMinusEmpty minusSet:[NSSet setWithObject:@""]];
                      [f unionSet:firstMinusEmpty];
                      if ([first count] != [firstMinusEmpty count])
                      {
                          BOOL allEmpty = YES;
                          for (NSUInteger newIdx = idx+2; newIdx < numElements && allEmpty; newIdx++)
                          {
                              if (nil == [[self first:[rightHandSide objectAtIndex:idx+1] underGrammar:g] member:@""])
                              {
                                  allEmpty = NO;
                              }
                          }
                          if (allEmpty && ![[rule name] isEqualToString:name])
                          {
                              [f unionSet:[self follow:[rule name] underGrammar:g]];
                          }
                      }
                  }
                  else if (![[rule name] isEqualToString:name])
                  {
                      [f unionSet:[self follow:[rule name] underGrammar:g]];
                  }
              }
          }];
     }];
    
    return f;
}

- (NSSet *)first:(NSObject *)obj underGrammar:(CPGrammar *)g
{
    if ([obj isKindOfClass:[CPTerminal class]])
    {
        return [NSSet setWithObject:[(CPTerminal *)obj tokenName]];
    }
    else
    {
        NSMutableSet *f = [NSMutableSet set];
        CPNonTerminal *nt = (CPNonTerminal *)obj;
        NSArray *rules = [g rulesForNonTerminal:nt];
        BOOL containsEmptyRightHandSide = NO;
        for (CPRule *rule in rules)
        {
            NSArray *rhs = [rule rightHandSideElements];
            NSUInteger numElements = [rhs count];
            if (numElements == 0)
            {
                containsEmptyRightHandSide = YES;
            }
            else
            {
                BOOL allCanBeEmpty = YES;
                for (NSUInteger element = 0; element < numElements && allCanBeEmpty; element++)
                {
                    NSSet *f1 = [self first:[rhs objectAtIndex:element] underGrammar:g];
                    [f unionSet:f1];
                    if (nil == [f1 member:@""])
                    {
                        allCanBeEmpty = NO;
                    }
                }
            }
        }
        if (containsEmptyRightHandSide)
        {
            [f addObject:@""];
        }
        return f;
    }
}

@end
