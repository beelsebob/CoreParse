//
//  CPTokenStream.m
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTokenStream.h"

@interface CPTokenStream ()
{
    NSMutableArray *tokens;
}

@property (readwrite,retain) NSMutableArray *tokens;

@end

@implementation CPTokenStream

@synthesize tokens;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        self.tokens = [NSMutableArray array];
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
    return [[[tokens objectAtIndex:0] retain] autorelease];
}

- (CPToken *)popToken
{
    CPToken *first = [[[tokens objectAtIndex:0] retain] autorelease];
    [tokens removeObjectAtIndex:0];
    return first;
}

- (void)addToken:(CPToken *)token
{
    [tokens addObject:token];
}

@end
