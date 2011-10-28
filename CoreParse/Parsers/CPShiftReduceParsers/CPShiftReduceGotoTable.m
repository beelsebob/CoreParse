//
//  CPShiftReduceGotoTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceGotoTable.h"


@implementation CPShiftReduceGotoTable
{
    NSArray *table;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    
    if (nil != self)
    {
        NSMutableArray *initTable = [NSMutableArray arrayWithCapacity:capacity];
        for (NSUInteger buildingState = 0; buildingState < capacity; buildingState++)
        {
            [initTable addObject:[NSMutableDictionary dictionary]];
        }
        table = [initTable retain];
    }
    
    return self;
}

#define CPShiftReduceGotoTableTableKey @"t"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        table = [[aDecoder decodeObjectForKey:CPShiftReduceGotoTableTableKey] retain];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:table forKey:CPShiftReduceGotoTableTableKey];
}

- (void)dealloc
{
    [table release];
    
    [super dealloc];
}

- (BOOL)setGoto:(NSUInteger)gotoIndex forState:(NSUInteger)state nonTerminalNamed:(NSString *)nonTerminalName
{
    NSMutableDictionary *row = [table objectAtIndex:state];
    if (nil != [row objectForKey:nonTerminalName] && [[row objectForKey:nonTerminalName] unsignedIntegerValue] != gotoIndex)
    {
        return NO;
    }
    [row setObject:[NSNumber numberWithUnsignedInteger:gotoIndex] forKey:nonTerminalName];
    return YES;
}

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    return [(NSNumber *)[(NSDictionary *)[table objectAtIndex:state] objectForKey:[rule name]] unsignedIntegerValue];
}

@end
