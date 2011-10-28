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

#import "CPRHSItemResult.h"

@interface CPShiftReduceParser ()

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token;
- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule;

- (void)error:(CPTokenStream *)tokenStream;

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

#define CPShiftReduceParserGrammarKey     @"g"
#define CPShiftReduceParserActionTableKey @"at"
#define CPShiftReduceParserGotoTableKey   @"gt"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithGrammar:[aDecoder decodeObjectForKey:CPShiftReduceParserGrammarKey]];
    
    if (nil != self)
    {
        [self setActionTable:[aDecoder decodeObjectForKey:CPShiftReduceParserActionTableKey]];
        [self setGotoTable:[aDecoder decodeObjectForKey:CPShiftReduceParserGotoTableKey]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self grammar]     forKey:CPShiftReduceParserGrammarKey];
    [aCoder encodeObject:[self actionTable] forKey:CPShiftReduceParserActionTableKey];
    [aCoder encodeObject:[self gotoTable]   forKey:CPShiftReduceParserGotoTableKey];
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
    CPToken *nextToken = [tokenStream popToken];
    while (1)
    {
        CPShiftReduceAction *action = [self actionForState:[(CPShiftReduceState *)[stateStack lastObject] state] token:nextToken];
        
        if ([action isShiftAction])
        {
            [stateStack addObject:[CPShiftReduceState shiftReduceStateWithObject:nextToken state:[action newState]]];
            nextToken = [tokenStream popToken];
        }
        else if ([action isReduceAction])
        {
            CPRule *reductionRule = [action reductionRule];
            NSUInteger numElements = [[reductionRule rightHandSideElements] count];
            NSMutableArray *components = [NSMutableArray arrayWithCapacity:numElements];
            NSRange stateStackRange = NSMakeRange([stateStack count] - numElements, numElements);
            [stateStack enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:stateStackRange]
                                          options:NSEnumerationReverse
                                       usingBlock:^(CPShiftReduceState *state, NSUInteger idx, BOOL *stop)
             {
                 id o = [state object];
                 if ([o isKindOfClass:[CPRHSItemResult class]])
                 {
                     o = [(CPRHSItemResult *)o contents];
                 }
                 [components insertObject:o atIndex:0];
             }];
            [stateStack removeObjectsInRange:stateStackRange];
                        
            CPSyntaxTree *tree = [CPSyntaxTree syntaxTreeWithRule:reductionRule children:components];
            id result = nil;
            
            Class c = [reductionRule representitiveClass];
            if (nil != c)
            {
                result = [(id<CPParseResult>)[c alloc] initWithSyntaxTree:tree];
            }
            
            if (nil == result)
            {
                result = tree;
                if ([[self delegate] respondsToSelector:@selector(parser:didProduceSyntaxTree:)])
                {
                    result = [[self delegate] parser:self didProduceSyntaxTree:tree];
                }
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
            [self error:tokenStream];
            return nil;
        }
    }
}

- (void)error:(CPTokenStream *)tokenStream
{
    NSLog(@"Parse error on input %@", tokenStream);
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
