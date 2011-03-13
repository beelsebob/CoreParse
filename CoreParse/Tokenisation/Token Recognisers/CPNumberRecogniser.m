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
    [rec setRecognisesInts:YES];
    [rec setRecognisesFloats:NO];
    return rec;
}

+ (id)floatRecogniser
{
    CPNumberRecogniser *rec = [[[CPNumberRecogniser alloc] init] autorelease];
    [rec setRecognisesInts:NO];
    [rec setRecognisesFloats:YES];
    return rec;
}

+ (id)numberRecogniser
{
    CPNumberRecogniser *rec = [[[CPNumberRecogniser alloc] init] autorelease];
    [rec setRecognisesInts:YES];
    [rec setRecognisesFloats:YES];
    return rec;
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSScanner *scanner = [NSScanner scannerWithString:tokenString];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setScanLocation:*tokenPosition];

    if (![self recognisesFloats])
    {
        NSInteger i;
        BOOL success = [scanner scanInteger:&i];
        if (success)
        {
            *tokenPosition = [scanner scanLocation];
            return [CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:i]];
        }
    }
    else
    {
        double d;
        BOOL success = [scanner scanDouble:&d];
        if (success && ![self recognisesInts])
        {
            NSString *substring = [tokenString substringWithRange:NSMakeRange(*tokenPosition, [scanner scanLocation] - *tokenPosition)];
            if ([substring rangeOfString:@"."].location == NSNotFound && [substring rangeOfString:@"e"].location)
            {
                success = NO;
            }
        }
        if (success)
        {
            *tokenPosition = [scanner scanLocation];
            return [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:d]];
        }
    }
    
    return nil;
}

@end
