//
//  CPShiftReduceActionTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceActionTable.h"

#import "CPItem.h"
#import "CPGrammarSymbol.h"
#import "CPShiftReduceAction.h"

@implementation CPShiftReduceActionTable
{
    NSMutableArray *table;
    NSUInteger capacity;
}

- (id)initWithCapacity:(NSUInteger)initCapacity
{
    self = [super init];
    
    if (nil != self)
    {
        capacity = initCapacity;
        table = [NSMutableArray arrayWithCapacity:capacity];
        
        for (NSUInteger buildingState = 0; buildingState < capacity; buildingState++)
        {
            [table addObject:[[NSMutableDictionary alloc] init]];
        }
    }
    
    return self;
}

#define CPShiftReduceActionTableTableKey @"t"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        table = [aDecoder decodeObjectForKey:CPShiftReduceActionTableTableKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:table forKey:CPShiftReduceActionTableTableKey];
}

- (BOOL)setAction:(CPShiftReduceAction *)action forState:(NSUInteger)state name:(NSString *)token
{
    NSMutableDictionary *row = table[state];
    if (nil != [row objectForKey:token] && ![[row objectForKey:token] isEqualToShiftReduceAction:action])
    {
        return NO;
    }
    [row setObject:action forKey:token];
    return YES;
}

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token
{
    NSMutableDictionary *row = table[state];
    return [row objectForKey:token.name];
}

- (NSSet *)acceptableTokenNamesForState:(NSUInteger)state
{
    NSMutableSet *toks = [NSMutableSet set];
    NSMutableDictionary *row = table[state];
    
    for (NSString *tok in row)
    {
        if (nil != [row objectForKey:tok])
        {
            [toks addObject:tok];
        }
    }
    return [toks copy];
}

- (NSString *)description
{
    if (capacity > 0)
    {
        NSMutableString *s = [NSMutableString string];
        NSMutableSet *keys = [NSMutableSet set];
        NSUInteger width = 3;
        for (NSUInteger state = 0; state < capacity; state++)
        {
            [keys addObjectsFromArray:[table[state] allKeys]];
        }
        for (NSString *key in keys)
        {
            width = MAX(width, [key length]);
        }
        NSArray *orderedKeys = [keys allObjects];
        [s appendString:@"State | "];
        for (NSString *key in orderedKeys)
        {
            [s appendFormat:@"%@", key];
            NSUInteger numSpaces = 1 + width - [key length];
            for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
            {
                [s appendString:@" "];
            }
        }
        [s appendString:@"\n"];
        
        NSUInteger idx = 0;
        for (NSUInteger state = 0; state < capacity; state++)
        {
            NSDictionary *row = table[state];
            [s appendFormat:@"%5ld | ", (long)idx];
            for (NSString *key in orderedKeys)
            {
                CPShiftReduceAction *action = [row objectForKey:key];
                NSUInteger numSpaces;
                if (nil == action)
                {
                    numSpaces = 1 + width;
                }
                else
                {
                    [s appendFormat:@"%@", action];
                    numSpaces = 1 + width - [[action description] length];
                }
                for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
                {
                    [s appendString:@" "];
                }
            }
            [s appendString:@"\n"];
            idx++;
        }
             
        return s;
    }
    
    return @"";
}

- (NSString *)descriptionWithGrammar:(CPGrammar *)g
{
    if (capacity > 0)
    {
        NSMutableString *s = [NSMutableString string];
        NSMutableSet *keys = [NSMutableSet set];
        NSUInteger width = 3;
        for (NSUInteger state = 0; state < capacity; state++)
        {
            [keys addObjectsFromArray:[table[state] allKeys]];
        }
        for (NSString *key in keys)
        {
            width = MAX(width, [key length]);
        }
        NSArray *orderedKeys = [keys allObjects];
        [s appendString:@"State | "];
        for (NSString *key in orderedKeys)
        {
            [s appendFormat:@"%@", key];
            NSUInteger numSpaces = 1 + width - [key length];
            for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
            {
                [s appendString:@" "];
            }
        }
        [s appendString:@"\n"];
        
        NSUInteger idx = 0;
        for (NSUInteger state = 0; state < capacity; state++)
        {
            NSDictionary *row = table[state];
            [s appendFormat:@"%5ld | ", (long)idx];
            for (NSString *key in orderedKeys)
            {
                CPShiftReduceAction *action = [row objectForKey:key];
                NSUInteger numSpaces;
                if (nil == action)
                {
                    numSpaces = 1 + width;
                }
                else
                {
                    [s appendFormat:@"%@", [action descriptionWithGrammar:g]];
                    numSpaces = 1 + width - [[action descriptionWithGrammar:g] length];
                }
                for (NSUInteger numAdded = 0; numAdded < numSpaces; numAdded++)
                {
                    [s appendString:@" "];
                }
            }
            [s appendString:@"\n"];
            idx++;
        }
        
        return s;
    }
    
    return @"";
}

@end
