//
//  CPEOFToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPEOFToken.h"


@implementation CPEOFToken

+ (id)eof
{
    return [[[CPEOFToken alloc] init] autorelease];
}

- (NSString *)description
{
    return @"<EOF>";
}

- (NSString *)name
{
    return @"EOF";
}

- (NSUInteger)hash
{
    return 0;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CPEOFToken class]];
}

@end
