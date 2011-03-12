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

- (NSSet *)firstSymbol:(NSObject *)obj;

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

- (NSSet *)follow:(NSString *)name
{
    NSMutableSet *f = [NSMutableSet setWithObject:@"EOF"];
    [[self allRules] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
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
                      NSSet *first = [self first:[rightHandSide subarrayWithRange:NSMakeRange(idx+1, [rightHandSide count] - idx - 1)]];
                      NSSet *firstMinusEmpty = [first objectsPassingTest:^ BOOL (id fobj, BOOL *fstop)
                                                {
                                                    return ![obj isEqual:@""];
                                                }];
                      [f unionSet:firstMinusEmpty];
                  }
                  else if (![[rule name] isEqualToString:name])
                  {
                      [f unionSet:[self follow:[rule name]]];
                  }
              }
          }];
     }];
    
    return f;
}

- (NSSet *)first:(NSArray *)symbols
{
    NSMutableSet *f = [NSMutableSet set];
    
    for (NSObject *symbol in symbols)
    {
        NSSet *f1 = [self firstSymbol:symbol];
        [f unionSet:f1];
        if (nil == [f1 member:@""])
        {
            break;
        }
    }
    
    return f;
}

- (NSSet *)firstSymbol:(NSObject *)obj
{
    if ([obj isKindOfClass:[CPTerminal class]])
    {
        return [NSSet setWithObject:[(CPTerminal *)obj tokenName]];
    }
    else
    {
        NSMutableSet *f = [NSMutableSet set];
        CPNonTerminal *nt = (CPNonTerminal *)obj;
        NSArray *rs = [self rulesForNonTerminal:nt];
        BOOL containsEmptyRightHandSide = NO;
        for (CPRule *rule in rs)
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
                    NSSet *f1 = [self firstSymbol:[rhs objectAtIndex:element]];
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
