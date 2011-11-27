//
//  CPQuotedRecogniser.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPQuotedRecogniser.h"

#import "CPQuotedToken.h"

@implementation CPQuotedRecogniser

@synthesize startQuote;
@synthesize endQuote;
@synthesize escapeSequence;
@synthesize escapeReplacer;
@synthesize maximumLength;
@synthesize name;

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote name:(NSString *)name
{
    return [CPQuotedRecogniser quotedRecogniserWithStartQuote:startQuote endQuote:endQuote escapeSequence:nil name:name];
}

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapeSequence:(NSString *)escapeSequence name:(NSString *)name
{
    return [CPQuotedRecogniser quotedRecogniserWithStartQuote:startQuote endQuote:endQuote escapeSequence:escapeSequence maximumLength:NSNotFound name:name];
}

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapeSequence:(NSString *)escapeSequence maximumLength:(NSUInteger)maximumLength name:(NSString *)name
{
    return [[[CPQuotedRecogniser alloc] initWithStartQuote:startQuote endQuote:endQuote escapeSequence:escapeSequence maximumLength:maximumLength name:name] autorelease];
}

- (id)initWithStartQuote:(NSString *)initStartQuote endQuote:(NSString *)initEndQuote escapeSequence:(NSString *)initEscapeSequence maximumLength:(NSUInteger)initMaximumLength name:(NSString *)initName
{
    self = [super init];
    
    if (nil != self)
    {
        [self setStartQuote:initStartQuote];
        [self setEndQuote:initEndQuote];
        [self setEscapeSequence:initEscapeSequence];
        [self setMaximumLength:initMaximumLength];
        [self setName:initName];
    }
    
    return self;
}

#define CPQuotedRecogniserStartQuoteKey     @"Q.s"
#define CPQuotedRecogniserEndQuoteKey       @"Q.e"
#define CPQuotedRecogniserEscapeSequenceKey @"Q.es"
#define CPQuotedRecogniserMaximumLengthKey  @"Q.m"
#define CPQuotedRecogniserNameKey           @"Q.n"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        [self setStartQuote:[aDecoder decodeObjectForKey:CPQuotedRecogniserStartQuoteKey]];
        [self setEndQuote:[aDecoder decodeObjectForKey:CPQuotedRecogniserEndQuoteKey]];
        [self setEscapeSequence:[aDecoder decodeObjectForKey:CPQuotedRecogniserEscapeSequenceKey]];
        @try
        {
            [self setMaximumLength:[aDecoder decodeIntegerForKey:CPQuotedRecogniserMaximumLengthKey]];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Warning, value for maximum length too long for this platform, allowing infinite lengths");
            [self setMaximumLength:NSNotFound];
        }
        [self setName:[aDecoder decodeObjectForKey:CPQuotedRecogniserNameKey]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (nil != [self escapeReplacer])
    {
        NSLog(@"Warning: encoding CPQuoteRecogniser with an escapeReplacer set.  This will not be recreated when decoded.");
    }
    [aCoder encodeObject:[self startQuote]     forKey:CPQuotedRecogniserStartQuoteKey];
    [aCoder encodeObject:[self endQuote]       forKey:CPQuotedRecogniserEndQuoteKey];
    [aCoder encodeObject:[self escapeSequence] forKey:CPQuotedRecogniserEscapeSequenceKey];
    [aCoder encodeInteger:[self maximumLength] forKey:CPQuotedRecogniserMaximumLengthKey];
    [aCoder encodeObject:[self name]           forKey:CPQuotedRecogniserNameKey];
}

- (void)dealloc
{
    [startQuote release];
    [endQuote release];
    [escapeSequence release];
    [escapeReplacer release];
    [name release];
    
    [super dealloc];
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSString *sq = [self startQuote];
    NSString *eq = [self endQuote];
    NSString *es = [self escapeSequence];
    NSString *(^er)(NSString *tokenStream, NSUInteger *quotePosition) = [self escapeReplacer];
    NSUInteger startQuoteLength = [sq length];
    NSUInteger endQuoteLength = [eq length];

    NSUInteger inputLength = [tokenString length];
    NSRange searchRange = NSMakeRange(*tokenPosition, MIN(inputLength - *tokenPosition,startQuoteLength + endQuoteLength + maximumLength));
    NSRange range = [tokenString rangeOfString:sq options:NSLiteralSearch | NSAnchoredSearch range:searchRange];
    
    NSMutableString *outputString = [NSMutableString string];
    
    if (NSNotFound != range.location)
    {
        searchRange.location = searchRange.location + range.length;
        searchRange.length   = searchRange.length   - range.length;
        
        NSRange endRange    = [tokenString rangeOfString:eq options:NSLiteralSearch range:searchRange];
        NSRange escapeRange = nil == es  ? NSMakeRange(NSNotFound, 0) : [tokenString rangeOfString:es options:NSLiteralSearch range:searchRange];
        
        while (NSNotFound != endRange.location && searchRange.location < inputLength)
        {
            if (endRange.location < escapeRange.location)
            {
                *tokenPosition = endRange.location + endRange.length;
                [outputString appendString:[tokenString substringWithRange:NSMakeRange(searchRange.location, endRange.location - searchRange.location)]];
                return [CPQuotedToken content:outputString quotedWith:sq name:[self name]];
            }
            else
            {
                NSUInteger quotedPosition = escapeRange.location + escapeRange.length;
                NSString *escapedStuff = nil;
                if (nil != er)
                {
                    escapedStuff = er(tokenString, &quotedPosition);
                }
                if (nil == escapedStuff)
                {
                    escapedStuff = [tokenString substringWithRange:NSMakeRange(escapeRange.location + escapeRange.length, 1)];
                    quotedPosition += 1;
                }
                [outputString appendFormat:@"%@%@", [tokenString substringWithRange:NSMakeRange(searchRange.location, escapeRange.location - searchRange.location)], escapedStuff];
                searchRange.length   = searchRange.location + searchRange.length - quotedPosition;
                searchRange.location = quotedPosition;
                
                if (endRange.location < searchRange.location)
                {
                    endRange    = [tokenString rangeOfString:eq options:NSLiteralSearch range:searchRange];
                }
                if (escapeRange.location < searchRange.location)
                {
                    escapeRange = [tokenString rangeOfString:es options:NSLiteralSearch range:searchRange];
                }
            }
        }
    }
    
    return nil;
}

@end
