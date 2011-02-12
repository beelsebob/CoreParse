//
//  CPIntegerRecogniser.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPNumberRecogniser.h"

#import "CPNumberToken.h"

@implementation CPNumberRecogniser

@synthesize recognisesInts;
@synthesize recognisesFloats;

+ (id)integerRecogniser
{
    CPNumberRecogniser *rec = [[[CPNumberRecogniser alloc] init] autorelease];
    rec.recognisesInts = YES;
    rec.recognisesFloats = NO;
    return rec;
}

+ (id)floatRecogniser
{
    CPNumberRecogniser *rec = [[[CPNumberRecogniser alloc] init] autorelease];
    rec.recognisesInts = NO;
    rec.recognisesFloats = YES;
    return rec;
}

+ (id)numberRecogniser
{
    CPNumberRecogniser *rec = [[[CPNumberRecogniser alloc] init] autorelease];
    rec.recognisesInts = YES;
    rec.recognisesFloats = YES;
    return rec;
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    if (!self.recognisesFloats)
    {
        NSScanner *scanner = [NSScanner scannerWithString:tokenString];
        scanner.scanLocation = *tokenPosition;
        NSInteger i;
        BOOL success = [scanner scanInteger:&i];
        if (success)
        {
            *tokenPosition = scanner.scanLocation;
            return [CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:i]];
        }
    }
    else
    {
        NSScanner *scanner = [NSScanner scannerWithString:tokenString];
        scanner.scanLocation = *tokenPosition;
        double d;
        BOOL success = [scanner scanDouble:&d];
        if (success && !self.recognisesInts)
        {
            NSString *substring = [tokenString substringWithRange:NSMakeRange(*tokenPosition, scanner.scanLocation - *tokenPosition)];
            if ([substring rangeOfString:@"."].location == NSNotFound)
            {
                success = NO;
            }
        }
        if (success)
        {
            *tokenPosition = scanner.scanLocation;
            return [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:d]];
        }
    }
    
    return nil;
}

@end
