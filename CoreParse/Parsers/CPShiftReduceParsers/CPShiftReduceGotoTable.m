//
//  CPShiftReduceGotoTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceGotoTable.h"
#import "CPRule.h"

@implementation CPShiftReduceGotoTable
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
        
        for (NSUInteger i = 0; i < initCapacity; ++i)
        {
            [table addObject:[[NSMutableDictionary alloc] init]];
        }
    }
    
    return self;
}

#define CPShiftReduceGotoTableTableKey @"t"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        table = [aDecoder decodeObjectForKey:CPShiftReduceGotoTableTableKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:table forKey:CPShiftReduceGotoTableTableKey];
}

- (BOOL)setGoto:(NSUInteger)gotoIndex forState:(NSUInteger)state nonTerminalNamed:(NSString *)nonTerminalName
{
    NSMutableDictionary *row = table[state];
    if (nil != [row objectForKey:nonTerminalName] && [[row objectForKey:nonTerminalName] unsignedIntegerValue] != gotoIndex)
    {
        return NO;
    }
    [row setObject:[NSNumber numberWithUnsignedInteger:gotoIndex] forKey:nonTerminalName];
    return YES;
}

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    NSMutableDictionary *row = table[state];
    return [(NSNumber *)[row objectForKey:[rule name]] unsignedIntegerValue];
}

@end
