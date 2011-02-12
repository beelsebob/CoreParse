//
//  CPKeywordToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
//

#import "CPKeywordToken.h"

@implementation CPKeywordToken

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
    [super dealloc];
}

- (NSString *)keyword
{
    return self.content;
}

- (void)setKeyword:(NSString *)newKeyword
{
    [self setContent:newKeyword];
}

@end
