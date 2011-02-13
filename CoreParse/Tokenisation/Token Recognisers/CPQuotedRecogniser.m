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
{
@private
    NSString *startQuote;
    NSString *endQuote;
    NSString *escapedEndQuote;
    NSString *escapedEscape;
}

@synthesize startQuote;
@synthesize endQuote;
@synthesize escapedEndQuote;
@synthesize escapedEscape;
@synthesize maximumLength;

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote
{
    return [CPQuotedRecogniser quotedRecogniserWithStartQuote:startQuote endQuote:endQuote escapedEndQuote:nil escapedEscape:nil];
}

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapedEndQuote:(NSString *)escapedEndQuote escapedEscape:(NSString *)escapedEscape
{
    return [CPQuotedRecogniser quotedRecogniserWithStartQuote:startQuote endQuote:endQuote escapedEndQuote:escapedEndQuote escapedEscape:escapedEscape maximumLength:NSNotFound];
}

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapedEndQuote:(NSString *)escapedEndQuote escapedEscape:(NSString *)escapedEscape maximumLength:(NSUInteger)maximumLength
{
    return [[[CPQuotedRecogniser alloc] initWithStartQuote:startQuote endQuote:endQuote escapedEndQuote:escapedEndQuote escapedEscape:escapedEscape maximumLength:maximumLength] autorelease];
}

- (id)initWithStartQuote:(NSString *)initStartQuote endQuote:(NSString *)initEndQuote escapedEndQuote:(NSString *)initEscapedEndQuote escapedEscape:(NSString *)initEscapedEscape maximumLength:(NSUInteger)initMaximumLength
{
    self = [super init];
    
    if (nil != self)
    {
        self.startQuote      = initStartQuote;
        self.endQuote        = initEndQuote;
        self.escapedEndQuote = initEscapedEndQuote;
        self.escapedEscape   = initEscapedEscape;
        self.maximumLength   = initMaximumLength;
    }
    
    return self;
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSUInteger inputLength = [tokenString length];
    NSUInteger startQuoteLength = [self.startQuote length];
    NSUInteger endQuoteLength = [self.endQuote length];
    NSRange searchRange = NSMakeRange(*tokenPosition, MIN(inputLength - *tokenPosition,startQuoteLength + endQuoteLength + maximumLength));
    NSRange range = [tokenString rangeOfString:self.startQuote options:NSLiteralSearch | NSAnchoredSearch range:searchRange];
    if (NSNotFound != range.location)
    {
        searchRange.location = searchRange.location + range.length;
        searchRange.length   = searchRange.length   - range.length;
        
        NSRange endRange          = [tokenString rangeOfString:self.endQuote        options:NSLiteralSearch range:searchRange];
        NSRange escapeEndRange    = nil == self.escapedEndQuote ? NSMakeRange(NSNotFound, 0) : [tokenString rangeOfString:self.escapedEndQuote options:NSLiteralSearch range:searchRange];
        NSRange escapeEscapeRange = nil == self.escapedEscape   ? NSMakeRange(NSNotFound, 0) : [tokenString rangeOfString:self.escapedEscape   options:NSLiteralSearch range:searchRange];
        
        while (NSNotFound != endRange.location && searchRange.location < inputLength)
        {
            if (endRange.location < escapeEndRange.location && endRange.location < escapeEscapeRange.location)
            {
                NSUInteger startLocation = *tokenPosition;
                NSUInteger contentStart = startLocation + startQuoteLength;
                *tokenPosition = endRange.location + endRange.length;
                return [CPQuotedToken content:[tokenString substringWithRange:NSMakeRange(contentStart, *tokenPosition - contentStart - endQuoteLength)] quotedWith:self.startQuote];
            }
            else
            {
                if (escapeEndRange.location < escapeEscapeRange.location)
                {
                    NSUInteger consumedStringLength = escapeEndRange.location + escapeEndRange.length - searchRange.location;
                    searchRange.location = escapeEndRange.location + escapeEndRange.length;
                    searchRange.length   = searchRange.length - consumedStringLength;
                }
                else
                {
                    NSUInteger consumedStringLength = escapeEscapeRange.location + escapeEscapeRange.length - searchRange.location;
                    searchRange.location = escapeEscapeRange.location + escapeEscapeRange.length;
                    searchRange.length   = searchRange.length - consumedStringLength;
                }
                
                if (endRange.location < searchRange.location)
                {
                    endRange = [tokenString rangeOfString:self.endQuote options:NSLiteralSearch range:searchRange];
                }
                if (escapeEndRange.location < searchRange.location)
                {
                    escapeEndRange = [tokenString rangeOfString:self.escapedEndQuote options:NSLiteralSearch range:searchRange];
                }
                if (escapeEscapeRange.location < searchRange.location)
                {
                    escapeEscapeRange = [tokenString rangeOfString:self.escapedEscape options:NSLiteralSearch range:searchRange];
                }
            }
        }
    }
    
    return nil;
}

@end
