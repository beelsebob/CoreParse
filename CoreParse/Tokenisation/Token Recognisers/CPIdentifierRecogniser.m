//
//  CPIdentifierTokeniser.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPIdentifierRecogniser.h"

#import "CPIdentifierToken.h"

@implementation CPIdentifierRecogniser

+ (id)identifierRecogniser
{
    return [[[CPIdentifierRecogniser alloc] init] autorelease];
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSCharacterSet *identifierStartCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                                 @"abcdefghijklmnopqrstuvwxyz"
                                                 @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                                 @"_"];
    NSCharacterSet *identifierCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyz"
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                            @"_1234567890"];
    NSScanner *scanner = [NSScanner scannerWithString:tokenString];
    scanner.scanLocation = *tokenPosition;
    [scanner setCharactersToBeSkipped:nil];
    NSString *identifierString;
    NSString *identifierEndString;
    BOOL success = [scanner scanCharactersFromSet:identifierStartCharacters intoString:&identifierString];
    if (success)
    {
        success = [scanner scanCharactersFromSet:identifierCharacters intoString:&identifierEndString];
        if (success)
        {
            identifierString = [identifierString stringByAppendingString:identifierEndString];
        }
        *tokenPosition = scanner.scanLocation;
        return [CPIdentifierToken tokenWithIdentifier:identifierString];
    }
    
    return nil;
}

@end
