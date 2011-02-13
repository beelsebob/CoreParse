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
}

@synthesize content;
@synthesize quoteType;

+ (id)content:(NSString *)content quotedWith:(NSString *)quoteType
{
    return [[[CPQuotedToken alloc] initWithContent:content quoteType:quoteType] autorelease];
}

- (id)initWithContent:(NSString *)initContent quoteType:(NSString *)initQuoteType
{
    self = [super init];
    
    if (nil != self)
    {
        self.content = initContent;
        self.quoteType = initQuoteType;
    }
    
    return self;
}

- (id)init
{
    return [self initWithContent:@"" quoteType:@""];
}

- (void)dealloc
{
    [content release];
    [quoteType release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Quoted: %@ with: %@>", self.content, self.quoteType];
}

@end
