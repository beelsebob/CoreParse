//
//  CPRegexpRecogniser.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CPRegexpKeywordRecogniser.h"
#import "CPToken.h"
#import "CPKeywordToken.h"

@implementation CPRegexpKeywordRecogniser

- (id)initWithRegexp:(NSRegularExpression *)regexp
{
    self = [super init];
    if (self) {
        _regexp = regexp;
    }
    return self;
}

+ (id)recogniserForRegexp:(NSRegularExpression *)regexp
{
    return [[self alloc] initWithRegexp:regexp];
}

- (void)dealloc
{
    [_regexp release];
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
    NSTextCheckingResult* result = [self.regexp firstMatchInString:tokenString options:0 range:searchRange];
    if (result) {
        NSString* matched = [tokenString substringWithRange:result.range];
        *tokenPosition = result.range.location + result.range.length;
        return [CPKeywordToken tokenWithKeyword:matched];
    }
    return nil;
}

@end
