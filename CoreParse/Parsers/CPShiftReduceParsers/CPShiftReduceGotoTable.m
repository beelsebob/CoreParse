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

- (NSUInteger)gotoForState:(NSUInteger)state rule:(CPRule *)rule
{
    return [(NSNumber *)[(NSDictionary *)[table objectAtIndex:state] objectForKey:rule.name] unsignedIntegerValue];
}

@end
