//
//  Grammar.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammar.h"

@interface CPGrammar ()

@property (readwrite,copy) NSArray *rules;

@end

@implementation CPGrammar
{
    NSMutableDictionary *rules;
}

@synthesize start;

- (NSArray *)rules
{
    __block NSMutableArray *rs = [NSMutableArray arrayWithCapacity:[rules count]];
    
    [[rules allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [rs addObjectsFromArray:obj];
     }];
    
    return rs;
}

- (void)setRules:(NSArray *)newRules
{
    @synchronized(self)
    {
        [rules release];
        rules = [NSMutableDictionary dictionaryWithCapacity:[newRules count]];
        
        [newRules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             [self addRule:obj];
         }];
    }
}

+ (id)grammarWithStart:(CPNonTerminal *)start rules:(NSArray *)rules
{
    return [[[CPGrammar alloc] initWithStart:start rules:rules] autorelease];
}

- (id)initWithStart:(CPNonTerminal *)initStart rules:(NSArray *)initRules;
{
    self = [super init];
    
    if (nil != self)
    {
        self.start = initStart;
        self.rules = initRules;
    }
    
    return self;
}

- (id)init
{
    return [self initWithStart:nil rules:[NSArray array]];
}

- (void)dealloc
{
    [start release];
    [rules release];
    
    [super dealloc];
}

- (void)addRule:(CPRule *)rule
{
    NSMutableArray *arr = [rules objectForKey:rule.name];
    if (nil == arr)
    {
        arr = [NSMutableArray array];
        [rules setObject:arr forKey:rule.name];
    }
    [arr addObject:rule];
}

- (NSArray *)rulesForNonTerminal:(CPNonTerminal *)nonTerminal
{
    return [rules objectForKey:nonTerminal.name];
}

@end
