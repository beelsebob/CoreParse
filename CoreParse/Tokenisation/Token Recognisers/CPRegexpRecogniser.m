//
//  CPRegexpRecogniser.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CPRegexpRecogniser.h"
#import "CPToken.h"
#import "CPKeywordToken.h"

@implementation CPRegexpRecogniser

@synthesize regexp;
@synthesize callback;

- (id)initWithRegexp:(NSRegularExpression *)initRegexp callback:(CPRegexpKeywordRecogniserCallbackBlock)initCallback
{
    self = [super init];
    if (self) {
        regexp = initRegexp;
        callback = initCallback;
    }
    return self;
}

+ (id)recogniserForRegexp:(NSRegularExpression *)regexp callback:(CPRegexpKeywordRecogniserCallbackBlock)callback
{
    return [[self alloc] initWithRegexp:regexp callback:callback];
}

- (void)dealloc
{
    [callback release];
    [regexp release];
    [super dealloc];
}

#pragma mark - NSCoder

#define CPRegexpRecogniserRegexpKey @"R.r"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        [self setRegexp:[aDecoder decodeObjectForKey:CPRegexpRecogniserRegexpKey]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self regexp] forKey:CPRegexpRecogniserRegexpKey];
}

#pragma mark - CPRecognizer

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    long inputLength = [tokenString length];
    NSRange searchRange = NSMakeRange(*tokenPosition, inputLength - *tokenPosition);
    NSTextCheckingResult* result = [[self regexp] firstMatchInString:tokenString options:0 range:searchRange];
    if (nil != result && nil != callback && result.range.location == *tokenPosition)
    {
        *tokenPosition = result.range.location + result.range.length;
        return callback(tokenString, result);
    }
    return nil;
}

@end
