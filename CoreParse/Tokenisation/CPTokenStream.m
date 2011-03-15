//
//  CPTokenStream.m
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTokenStream.h"

@interface CPTokenStream ()

@property (readwrite,retain) NSMutableArray *tokens;

@end

@implementation CPTokenStream

@synthesize tokens;

+ (id)tokenStreamWithTokens:(NSArray *)tokens
{
    return [[[self alloc] initWithTokens:tokens] autorelease];
}

- (id)initWithTokens:(NSArray *)initTokens
{
    self = [self init];
    
    if (nil != self)
    {
        [self setTokens:[[initTokens mutableCopy] autorelease]];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTokens:[NSMutableArray array]];
    }
    
    return self;
}

- (void)dealloc
{
    [tokens release];
    
    [super dealloc];
}

- (BOOL)hasToken
{
    return [tokens count] > 0;
}

- (CPToken *)peekToken
{
    @synchronized(self)
    {
        return [[[tokens objectAtIndex:0] retain] autorelease];
    }
}

- (CPToken *)popToken
{
    CPToken *first;
    @synchronized(self)
    {
        first = [[[tokens objectAtIndex:0] retain] autorelease];
        [tokens removeObjectAtIndex:0];
    }
    return first;
}

- (void)pushToken:(CPToken *)token
{
    @synchronized(self)
    {
        [tokens addObject:token];
    }
}

- (void)pushTokens:(NSArray *)newTokens
{
    @synchronized(self)
    {
        [tokens addObjectsFromArray:newTokens];
    }
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    @synchronized(self)
    {
        for (CPToken *tok in tokens)
        {
            [desc appendFormat:@"%@ ", tok];
        }
    }
    
    return desc;
}

- (NSArray *)peekAllRemainingTokens
{
    @synchronized(self)
    {
        return [[tokens copy] autorelease];
    }
}

- (NSUInteger)hash
{
    return [[self peekAllRemainingTokens] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPTokenStream class]])
    {
        CPTokenStream *other = (CPTokenStream *)object;
        return [[other peekAllRemainingTokens] isEqualToArray:[self peekAllRemainingTokens]];
    }
    return NO;
}

@end
