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

- (void)dealloc
{
    [table release];
    
    [super dealloc];
}

- (void)setGoto:(NSUInteger)gotoIndex forState:(NSUInteger)state nonTerminalNamed:(NSString *)nonTerminalName
{
    [(NSMutableDictionary *)[table objectAtIndex:state] setObject:[NSNumber numberWithUnsignedInteger:gotoIndex] forKey:nonTerminalName];
}

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    return [(NSNumber *)[(NSDictionary *)[table objectAtIndex:state] objectForKey:rule.name] unsignedIntegerValue];
}

@end
