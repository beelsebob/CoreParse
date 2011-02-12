//
//  CPKeywordRecogniser.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
//

#import "CPKeywordRecogniser.h"

@interface CPKeywordRecogniser ()
{
@private
    NSString *keyword;
}

@end

@implementation CPKeywordRecogniser

@synthesize keyword;

+ (id)recogniserForKeyword:(NSString *)keyword
{
    return [[[CPKeywordRecogniser alloc] initWithKeyword:keyword] autorelease];
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

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSString *kw = self.keyword;
    NSUInteger kwLength = [kw length];
    if ([tokenString length] - *tokenPosition >= kwLength)
    {
        if ([[tokenString substringWithRange:NSMakeRange(*tokenPosition, kwLength)] isEqualToString:kw])
        {
            *tokenPosition = *tokenPosition + kwLength;
            return [CPKeywordToken tokenWithKeyword:kw];
        }
    }
    
    return nil;
}

@end
