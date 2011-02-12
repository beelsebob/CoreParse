//
//  CPIdentifierToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPIdentifierToken.h"


@implementation CPIdentifierToken
{
    NSString *identifier;
}

@synthesize identifier;

+ (id)tokenWithIdentifier:(NSString *)identifier
{
    return [[(CPIdentifierToken *)[CPIdentifierToken alloc] initWithIdentifier:identifier] autorelease];
}

- (id)initWithIdentifier:(NSString *)initIdentifier
{
    self = [super init];
    
    if (nil != self)
    {
        self.identifier = initIdentifier;
    }
    
    return self;
}

- (id)init
{
    return [self initWithIdentifier:@""];
}

- (void)dealloc
{
    [identifier release];
    [super dealloc];
}

@end
