//
//  CPTestMapCSSTokenisingDelegate.m
//  CoreParse
//
//  Created by Tom Davie on 15/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTestMapCSSTokenisingDelegate.h"

#import <CoreParse/CoreParse.h>

@implementation CPTestMapCSSTokenisingDelegate
{
    BOOL justTokenisedObject;
}

- (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token
{
    return YES;
}

- (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token
{
    NSString *name = [token name];
    if ([token isKindOfClass:[CPWhiteSpaceToken class]])
    {
        if (justTokenisedObject)
        {
            return [NSArray arrayWithObject:token];
        }
        else
        {
            return [NSArray array];
        }
    }
    
    justTokenisedObject = NO;
    if ([name isEqualToString:@"Comment"])
    {
        return [NSArray array];
    }

    if ([name isEqualToString:@"node"] || [name isEqualToString:@"way" ] || [name isEqualToString:@"relation"] ||
        [name isEqualToString:@"area"] || [name isEqualToString:@"line"] || [name isEqualToString:@"*"])
    {
        justTokenisedObject = YES;
    }

    return [NSArray arrayWithObject:token];
}

@end
