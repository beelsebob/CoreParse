//
//  CPNumberToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPNumberToken.h"

@implementation CPNumberToken
{
@private
    NSNumber *number;
}

@synthesize number;

+ (id)tokenWithNumber:(NSNumber *)number
{
    return [[[CPNumberToken alloc] initWithNumber:number] autorelease];
}

- (id)initWithNumber:(NSNumber *)initNumber
{
    self = [super init];
    
    if (nil != self)
    {
        [self setNumber:initNumber];
    }
    
    return self;    
}

- (id)init
{
    return [self initWithNumber:[NSNumber numberWithInteger:0]];
}

- (void)dealloc
{
    [number release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Number: %@>", [self number]];
}

- (NSString *)name
{
    return @"Number";
}

- (NSUInteger)hash
{
    return [[self number] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPNumberToken class]])
    {
        CPNumberToken *other = (CPNumberToken *)object;
        return [[other number] isEqualToNumber:[self number]];
    }
    
    return NO;
}

@end
