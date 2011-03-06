//
//  CPShiftReduceActionTable.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceActionTable.h"


@implementation CPShiftReduceActionTable
{
    NSArray *table;
}

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token
{
    return [(NSDictionary *)[table objectAtIndex:state] objectForKey:token.name];
}

@end
