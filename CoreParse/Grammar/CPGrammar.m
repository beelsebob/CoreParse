//
//  Grammar.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammar.h"
#import "CPTerminal.h"

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
        rules = [[NSMutableDictionary dictionaryWithCapacity:[newRules count]] retain];
        
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

- (NSSet *)allRules
{
    NSMutableSet *rs = [NSMutableSet setWithCapacity:[rules count]];
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [rs addObjectsFromArray:obj];
     }];
    return rs;
}

- (NSArray *)orderedRules
{
    return [[[self allRules] allObjects] sortedArrayUsingComparator:^ NSComparisonResult (id obj1, id obj2)
            {
                CPRule *r1 = (CPRule *)obj1;
                CPRule *r2 = (CPRule *)obj2;
                NSComparisonResult r = [[r1 name] compare:[r2 name]];
                return NSOrderedSame != r ? r : ([[r1 rightHandSideElements] count] < [[r2 rightHandSideElements] count] ? NSOrderedAscending : ([[r1 rightHandSideElements] count] > [[r2 rightHandSideElements] count] ? NSOrderedDescending : NSOrderedSame));
            }];
    
}

- (NSArray *)allNonTerminalNames
{
    NSMutableArray *nonTerminals = [NSMutableArray arrayWithCapacity:[rules count]];
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [nonTerminals addObject:key];
     }];
    return nonTerminals;
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

- (CPGrammar *)augmentedGrammar
{
    return [[[CPGrammar alloc] initWithStart:[CPNonTerminal nonTerminalWithName:@"s'"]
                                       rules:[self.rules arrayByAddingObject:[CPRule ruleWithName:@"s'" rightHandSideElements:[NSArray arrayWithObject:self.start]]]]
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

@end
