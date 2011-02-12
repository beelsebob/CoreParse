//
//  CPKeywordToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPKeywordToken.h"

@implementation CPKeywordToken
{
@private
    NSString *keyword;
}

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

@end
