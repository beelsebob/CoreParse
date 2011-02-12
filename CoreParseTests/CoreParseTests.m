//
//  CoreParseTests.m
//  CoreParseTests
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CoreParseTests.h"

#import "CoreParse.h"

@implementation CoreParseTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testKeywordTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"{}"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    CPToken *tok3 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPKeywordToken class]] || ![((CPKeywordToken *)tok1).keyword isEqualToString:@"{"] ||
        ![tok2 isKindOfClass:[CPKeywordToken class]] || ![((CPKeywordToken *)tok2).keyword isEqualToString:@"}"] ||
        ![tok3 isKindOfClass:[CPEOFToken class]])
    {
        STFail(@"Incorrect tokenisation of braces");
    }
}

- (void)testIntegerTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.integerValue != 1234 ||
        ![tok2 isKindOfClass:[CPEOFToken class]])
    {
        STFail(@"Incorrect tokenisation of integers");
    }

    tokenStream = [tokeniser tokenise:@"1234abcd"];
    tok1 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.integerValue != 1234)
    {
        STFail(@"Incorrect tokenisation of integers with additional cruft");
    }
}

- (void)testFloatTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser floatRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.doubleValue != 1234.5678 ||
        ![tok2 isKindOfClass:[CPEOFToken class]])
    {
        STFail(@"Incorrect tokenisation of floats");
    }
    
    tokenStream = [tokeniser tokenise:@"1234"];
    if ([tokenStream hasToken])
    {
        STFail(@"Tokenising floats recognises integers as well");
    }
}

- (void)testNumberTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.doubleValue != 1234.5678 ||
        ![tok2 isKindOfClass:[CPEOFToken class]])
    {
        STFail(@"Incorrect tokenisation of numbers");
    }
    
    tokenStream = [tokeniser tokenise:@"1234abcd"];
    tok1 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.integerValue != 1234)
    {
        STFail(@"Incorrect tokenisation of numbers with additional cruft");
    }
}

@end
