//
//  CPToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPToken.h"

@implementation CPToken

- (NSString *)name
{
    [NSException raise:@"Abstract method called exception" format:@"CPToken is abstract, and should not have name called."];
    return @"";
}

- (NSUInteger)hash
{
    return [[self name] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPToken class]])
    {
        CPToken *other = (CPToken *)object;
        return [[self name] isEqualToString:[other name]];
    }
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>", [self name]];
}

@end
