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

@synthesize initialCharacters;
@synthesize identifierCharacters;

+ (id)identifierRecogniser
{
    return [[[CPIdentifierRecogniser alloc] initWithInitialCharacters:nil identifierCharacters:nil] autorelease];
}

+ (id)identifierRecogniserWithInitialCharacters:(NSCharacterSet *)initialCharacters identifierCharacters:(NSCharacterSet *)identifierCharacters
{
    return [[[CPIdentifierRecogniser alloc] initWithInitialCharacters:initialCharacters identifierCharacters:identifierCharacters] autorelease];
}

- (id)initWithInitialCharacters:(NSCharacterSet *)initInitialCharacters identifierCharacters:(NSCharacterSet *)initIdentifierCharacters
{
    self = [super init];
    
    if (nil != self)
    {
        [self setInitialCharacters:initInitialCharacters];
        [self setIdentifierCharacters:initIdentifierCharacters];
    }
    
    return self;
}

- (void)dealloc
{
    [initialCharacters release];
    [identifierCharacters release];
    
    [super dealloc];
}

- (CPToken *)recogniseTokenInString:(NSString *)tokenString currentTokenPosition:(NSUInteger *)tokenPosition
{
    NSCharacterSet *identifierStartCharacters = nil == [self initialCharacters] ? [NSCharacterSet characterSetWithCharactersInString:
                                                                                   @"abcdefghijklmnopqrstuvwxyz"
                                                                                   @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                                                                   @"_"] : [self initialCharacters];
    NSCharacterSet *idCharacters = nil == [self identifierCharacters] ? [NSCharacterSet characterSetWithCharactersInString:
                                                                         @"abcdefghijklmnopqrstuvwxyz"
                                                                         @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                                                         @"_-1234567890"] : [self identifierCharacters];
    NSScanner *scanner = [NSScanner scannerWithString:tokenString];
    [scanner setScanLocation:*tokenPosition];
    [scanner setCharactersToBeSkipped:nil];
    NSString *identifierString;
    NSString *identifierEndString;
    BOOL success = [scanner scanCharactersFromSet:identifierStartCharacters intoString:&identifierString];
    if (success)
    {
        success = [scanner scanCharactersFromSet:idCharacters intoString:&identifierEndString];
        if (success)
        {
            identifierString = [identifierString stringByAppendingString:identifierEndString];
        }
        *tokenPosition = [scanner scanLocation];
        return [CPIdentifierToken tokenWithIdentifier:identifierString];
    }
    
    return nil;
}

@end
