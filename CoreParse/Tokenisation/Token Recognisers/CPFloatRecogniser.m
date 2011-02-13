//
//  CPFloatRecogniser.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPFloatRecogniser.h"

#import "CPNumberToken.h"

@implementation CPFloatRecogniser

@synthesize recognisesInts;

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSScanner *scanner = [NSScanner scannerWithString:tokenString];
    scanner.scanLocation = *tokenPosition;
    double d;
    BOOL success = [scanner scanDouble:&d];
    if (success && !self.recognisesInts)
    {
        NSString *substring = [tokenString substringWithRange:NSMakeRange(*tokenPosition, scanner.scanLocation - *tokenPosition)];
        if ([substring rangeOfString:@"."].location != NSNotFound)
        {
            success = NO;
        }
    }
    if (success)
    {
        *tokenPosition = scanner.scanLocation;
        return [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:d]];
    }
    
    return nil;
}

@end
