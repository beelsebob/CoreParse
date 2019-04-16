//
//  CPShiftReduceGotoTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceGotoTable.h"
#import "CPRule.h"

@interface CPShiftReduceGotoTable()

@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *table;
@property (nonatomic, assign) NSUInteger capacity;

@end

@implementation CPShiftReduceGotoTable

- (id)initWithCapacity:(NSUInteger)initCapacity
{
    self = [super init];
    
    if (nil != self)
    {
        _capacity = initCapacity;
        _table = [NSMutableArray arrayWithCapacity:initCapacity];
        for (NSUInteger buildingState = 0; buildingState < _capacity; buildingState++)
        {
            _table[buildingState] = [[NSMutableDictionary alloc] init];
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
        NSArray *rows = [aDecoder decodeObjectForKey:CPShiftReduceGotoTableTableKey];
        _capacity = [rows count];
        _table = [rows mutableCopy];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_table forKey:CPShiftReduceGotoTableTableKey];
}

- (BOOL)setGoto:(NSUInteger)gotoIndex forState:(NSUInteger)state nonTerminalNamed:(NSString *)nonTerminalName
{
    NSMutableDictionary *row = _table[state];
    if (nil != [row objectForKey:nonTerminalName] && [[row objectForKey:nonTerminalName] unsignedIntegerValue] != gotoIndex)
    {
        return NO;
    }
    [row setObject:[NSNumber numberWithUnsignedInteger:gotoIndex] forKey:nonTerminalName];
    return YES;
}

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    return [(NSNumber *)[_table[state] objectForKey:[rule name]] unsignedIntegerValue];
}

@end
