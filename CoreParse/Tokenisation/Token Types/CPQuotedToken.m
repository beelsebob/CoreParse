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

+ (id)content:(NSString *)content quotedWith:(NSString *)quoteType name:(NSString *)name
{
    return [[[CPQuotedToken alloc] initWithContent:content quoteType:quoteType name:name] autorelease];
}

- (id)initWithContent:(NSString *)initContent quoteType:(NSString *)initQuoteType name:(NSString *)initName
{
    self = [super init];
    
    if (nil != self)
    {
        [self setContent:initContent];
        [self setQuoteType:initQuoteType];
        name = [initName copy];
    }
    
    return self;
}

- (id)init
{
    return [self initWithContent:@"" quoteType:@"" name:@""];
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
    return [NSString stringWithFormat:@"<%@: %@>", [self name], [self content]];
}

- (NSString *)name
{
    return name;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPQuotedToken class]])
    {
        CPQuotedToken *other = (CPQuotedToken *)object;
        return [[other content] isEqualToString:[self content]] && [[other name] isEqualToString:[self name]] && [[other quoteType] isEqualToString:[self quoteType]];
    }
    return NO;
}

@end
