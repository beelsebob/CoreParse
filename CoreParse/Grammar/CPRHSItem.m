//
//  CPRHSItem.m
//  CoreParse
//
//  Created by Thomas Davie on 26/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRHSItem.h"

@implementation CPRHSItem

@synthesize contents;
@synthesize repeats;
@synthesize mayNotExist;

- (NSUInteger)hash
{
    return [[self contents] hash] << 2 + ([self repeats] ? 0x2 : 0x0) + ([self mayNotExist] ? 0x1 : 0x0);
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPRHSItem class]])
    {
        CPRHSItem *i = (CPRHSItem *)object;
        return [[self contents] isEqualToArray:[i contents]] && [self repeats] == [i repeats] && [self mayNotExist] == [i mayNotExist];
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    CPRHSItem *other = [[CPRHSItem allocWithZone:zone] init];
    [other setContents:[self contents]];
    [other setRepeats:[self repeats]];
    [other setMayNotExist:[self mayNotExist]];
    return other;
}

@end
