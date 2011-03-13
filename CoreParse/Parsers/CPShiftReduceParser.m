//
//  CPLALR1Parser.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceParserProtectedMethods.h"

#import "CPShiftReduceAction.h"
#import "CPShiftReduceState.h"

#import "CPGrammarSymbol.h"

@interface CPShiftReduceParser ()

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token;
- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule;

@end

@implementation CPShiftReduceParser

@synthesize actionTable;
@synthesize gotoTable;

- (id)initWithGrammar:(CPGrammar *)grammar
{
    self = [super initWithGrammar:grammar];
    
    if (nil != self)
    {
        BOOL succes = [self constructShiftReduceTables];
        if (!succes)
        {
            [self release];
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [actionTable release];
    [gotoTable release];
    
    [super dealloc];
}

- (BOOL)constructShiftReduceTables
{
    NSLog(@"CPShiftReduceParser is abstract, use one of it's concrete subclasses instead");
    return NO;
}

- (id)parse:(CPTokenStream *)tokenStream
{
    NSMutableArray *stateStack = [NSMutableArray arrayWithObject:[CPShiftReduceState shiftReduceStateWithObject:nil state:0]];
    while (1)
    {
        CPToken *nextToken = [tokenStream peekToken];
        CPShiftReduceAction *action = [self actionForState:[(CPShiftReduceState *)[stateStack lastObject] state] token:nextToken];
        
        if ([action isShiftAction])
        {
            [stateStack addObject:[CPShiftReduceState shiftReduceStateWithObject:nextToken state:[action newState]]];
            [tokenStream popToken];
        }
        else if ([action isReduceAction])
        {
            CPRule *reductionRule = [action reductionRule];
            NSUInteger numElements = [[reductionRule rightHandSideElements] count];
            NSMutableArray *components = [NSMutableArray arrayWithCapacity:numElements];
            [stateStack enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([stateStack count] - numElements, numElements)]
                                          options:NSEnumerationConcurrent | NSEnumerationReverse
                                       usingBlock:^(CPShiftReduceState *state, NSUInteger idx, BOOL *stop)
             {
                 [components insertObject:[state object] atIndex:0];
                 [stateStack removeLastObject];
             }];
            
            CPSyntaxTree *tree = [CPSyntaxTree syntaxTreeWithRule:reductionRule children:components];
            id result = tree;
            if ([[self delegate] respondsToSelector:@selector(parser:didProduceSyntaxTree:)])
            {
                result = [[self delegate] parser:self didProduceSyntaxTree:tree];
            }
            
            NSUInteger newState = [self gotoForState:[(CPShiftReduceState *)[stateStack lastObject] state] rule:reductionRule];
            [stateStack addObject:[CPShiftReduceState shiftReduceStateWithObject:result state:newState]];
        }
        else if ([action isAccept])
        {
            return [(CPShiftReduceState *)[stateStack lastObject] object];
        }
        else
        {
            NSLog(@"Parse error on input %@", nextToken);
            return nil;
        }
    }
}

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token
{
    return [[self actionTable] actionForState:state token:token];
}

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    return [[self gotoTable] gotoForState:state rule:rule];
}

@end
