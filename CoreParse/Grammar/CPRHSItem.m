//
//  CPRHSItem.m
//  CoreParse
//
//  Created by Thomas Davie on 26/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRHSItem.h"

@implementation CPRHSItem

@synthesize alternatives = _alternatives;
@synthesize repeats = _repeats;
@synthesize mayNotExist = _mayNotExist;
@synthesize tag = _tag;
@synthesize shouldCollapse = _shouldCollapse;

- (NSUInteger)hash
{
    return [[self alternatives] hash] << 2 + ([self repeats] ? 0x2 : 0x0) + ([self mayNotExist] ? 0x1 : 0x0);
}

- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[CPRHSItem class]] &&
            [[self alternatives] isEqualToArray:[object alternatives]] &&
            [self repeats] == [object repeats] &&
            [self mayNotExist] == [object mayNotExist] &&
            [self shouldCollapse] == [object shouldCollapse] &&
            (([self tag] == nil && [object tag] == nil) ||
             [[self tag] isEqualToString:[object tag]]));
}

- (id)copyWithZone:(NSZone *)zone
{
    CPRHSItem *other = [[CPRHSItem allocWithZone:zone] init];
    [other setAlternatives:[self alternatives]];
    [other setRepeats:[self repeats]];
    [other setMayNotExist:[self mayNotExist]];
    [other setTag:[self tag]];
    [other setShouldCollapse:[self shouldCollapse]];
    return other;
}

- (void)dealloc
{
    [_alternatives release];
    [_tag release];
    
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    if ([[self alternatives] count] != 1 || [[[self alternatives] objectAtIndex:0] count] != 1)
    {
        [desc appendString:@"("];
    }
    NSUInteger i = 0;
    for (NSArray *components in [self alternatives])
    {
        i++;
        NSUInteger j = 0;
        for (id comp in components)
        {
            j++;
            if (j != [components count])
            {
                [desc appendFormat:@"%@ ", comp];
            }
            else
            {
                [desc appendFormat:@"%@", comp];
            }
        }
        
        if (i != [[self alternatives] count])
        {
            [desc appendString:@"| "];
        }
    }
    if ([[self alternatives] count] != 1 || [[[self alternatives] objectAtIndex:0] count] != 1)
    {
        [desc appendString:@")"];
    }
    [desc appendString:[self repeats] ? ([self mayNotExist] ? @"*" : @"+") : ([self mayNotExist] ? @"?" : @"")];
    return desc;
}

@end
