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
    NSMutableSet *tokensToIgnore;
    NSMutableArray *tokens;
}

@property (readwrite,retain) NSMutableArray *tokens;

- (void)filterTokens;

@end

@implementation CPTokenStream

@synthesize tokens;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        self.tokens = [NSMutableArray array];
        tokensToIgnore = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [tokensToIgnore release];
    [tokens release];
    [super dealloc];
}

- (void)beginIgnoringTokenNamed:(NSString *)tokenName
{
    @synchronized(self)
    {
        [tokensToIgnore addObject:tokenName];
    }
}

- (BOOL)hasToken
{
    BOOL has;
    @synchronized(self)
    {
        [self filterTokens];
        has = [tokens count] > 0;
    }
    
    return has;
}

- (CPToken *)peekToken
{
    @synchronized(self)
    {
        [self filterTokens];
    }
    return [[[tokens objectAtIndex:0] retain] autorelease];
}

- (CPToken *)popToken
{
    CPToken *first;
    @synchronized(self)
    {
        [self filterTokens];
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

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    @synchronized(self)
    {
        [self filterTokens];
        [tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             [desc appendFormat:@"%@ ", obj];
         }];
    }
    
    return desc;
}

- (void)filterTokens
{
    [tokens filterUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (id obj, NSDictionary *bindings)
                                  {
                                      return nil == [tokensToIgnore member:[(CPToken *)obj name]];
                                  }]];
}

- (NSArray *)peekAllRemainingTokens
{
    @synchronized(self)
    {
        [self filterTokens];
        return [[tokens copy] autorelease];
    }
}

@end
