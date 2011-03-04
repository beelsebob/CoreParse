//
//  CPQuotedToken.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPQuotedToken.h"


@implementation CPQuotedToken
{
@private
    NSString *content;
    NSString *quoteType;
    NSString *name;
}

@synthesize content;
@synthesize quoteType;

+ (id)content:(NSString *)content quotedWith:(NSString *)quoteType tokenName:(NSString *)name
{
    return [[[CPQuotedToken alloc] initWithContent:content quoteType:quoteType tokenName:name] autorelease];
}

- (id)initWithContent:(NSString *)initContent quoteType:(NSString *)initQuoteType tokenName:(NSString *)initName
{
    self = [super init];
    
    if (nil != self)
    {
        self.content = initContent;
        self.quoteType = initQuoteType;
        name = [initName copy];
    }
    
    return self;
}

- (id)init
{
    return [self initWithContent:@"" quoteType:@"" tokenName:@""];
}

- (void)dealloc
{
    [content release];
    [quoteType release];
    [name release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", self.name, self.content];
}

- (NSString *)name
{
    return name;
}

@end
