//
//  Terminal.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "Terminal.h"

@implementation Terminal
{
    NSString *tokenName;
}

@synthesize tokenName;

+ (id)terminalWithTokenName:(NSString *)tokenName
{
    return [[[Terminal alloc] initWithTokeName:tokenName] autorelease];
}

- (id)initWithTokeName:(NSString *)initTokenName
{
    self = [super init];
    
    if (nil != self)
    {
        self.tokenName = initTokenName;
    }
    
    return self;
}

- (id)init
{
    return [self initWithTokeName:@""];
}

- (void)dealloc
{
    [tokenName release];
    
    [super dealloc];
}

@end
