//
//  CPKeywordToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPKeywordToken.h"

@implementation CPKeywordToken

@synthesize keyword;

+ (id)tokenWithKeyword:(NSString *)keyword
{
    return [[[CPKeywordToken alloc] initWithKeyword:keyword] autorelease];
}

- (id)initWithKeyword:(NSString *)initKeyword
{
    self = [super init];
    
    if (nil != self)
    {
        self.keyword = initKeyword;
    }
    
    return self;
}

- (id)init
{
    return [self initWithKeyword:@" "];
}

- (void)dealloc
{
    [keyword release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Keyword: %@>", self.keyword];
}

- (NSString *)name
{
    return self.keyword;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPKeywordToken class]])
    {
        CPKeywordToken *other = (CPKeywordToken *)object;
        return [[other keyword] isEqualToString:[self keyword]];
    }
    
    return NO;
}

@end
