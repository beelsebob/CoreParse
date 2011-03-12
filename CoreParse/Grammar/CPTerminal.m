//
//  Terminal.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTerminal.h"

@implementation CPTerminal

@synthesize tokenName;

+ (id)terminalWithTokenName:(NSString *)tokenName
{
    return [[[CPTerminal alloc] initWithTokeName:tokenName] autorelease];
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

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CPTerminal class]] && [((CPTerminal *)object).tokenName isEqualToString:self.tokenName];
}

- (NSUInteger)hash
{
    return [self.tokenName hash];
}

- (NSString *)description
{
    return self.tokenName;
}

@end
