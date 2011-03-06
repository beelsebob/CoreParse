//
//  CPRecursiveDescentParser.m
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRecursiveDescentParser.h"

#import "CPNonTerminal.h"
#import "CPTerminal.h"

@interface CPRecursiveDescentParser ()

- (id)parsePossibleRules:(NSArray *)rules tokenStream:(CPTokenStream *)tokenStream;
- (id)parseRule:(CPRule *)rule tokenStream:(CPTokenStream *)tokenStream;

@end

@implementation CPRecursiveDescentParser

- (id)parse:(CPTokenStream *)tokenStream
{
    CPGrammar *grammar = self.grammar;
    NSArray *rules = [grammar rulesForNonTerminal:grammar.start];
    return [self parsePossibleRules:rules tokenStream:tokenStream];
}

- (id)parsePossibleRules:(NSArray *)rules tokenStream:(CPTokenStream *)tokenStream
{
    __block id result;
    
    [rules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         result = [[self parseRule:obj tokenStream:tokenStream] retain];
         *stop = nil != result;
     }];
    
    return [result autorelease];
}

- (id)parseRule:(CPRule *)rule tokenStream:(CPTokenStream *)tokenStream
{
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:[[rule rightHandSideElements] count]];
    __block BOOL errored = NO;
    
    [rule.rightHandSideElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[CPTerminal class]])
         {
             if ([[[tokenStream peekToken] name] isEqualToString:[((CPTerminal *)obj) tokenName]])
             {
                 [components addObject:[tokenStream popToken]];
             }
             else
             {
                 errored = YES;
                 *stop = YES;
             }
         }
         else
         {
             id parse = [self parsePossibleRules:[self.grammar rulesForNonTerminal:obj] tokenStream:tokenStream];
             if (nil != parse)
             {
                 [components addObject:parse];
             }
             else
             {
                 errored = YES;
                 *stop = YES;
             }
         }
     }];
    
    if (!errored)
    {
        CPSyntaxTree *tree = [CPSyntaxTree syntaxTreeWithRule:rule children:components];
        if ([self.delegate respondsToSelector:@selector(parser:didProduceSyntaxTree:)])
        {
            return [self.delegate parser:self didProduceSyntaxTree:tree];
        }
        else
        {
            return tree;
        }
    }
    
    return nil;
}

@end
