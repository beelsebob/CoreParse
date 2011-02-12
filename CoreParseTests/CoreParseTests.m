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

- (void)testWhiteSpaceTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"12.34 56.78\t90"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    CPToken *tok3 = [tokenStream popToken];
    CPToken *tok4 = [tokenStream popToken];
    CPToken *tok5 = [tokenStream popToken];
    CPToken *tok6 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken     class]] || ((CPNumberToken *)tok1).number.doubleValue != 12.34 ||
        ![tok2 isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok2).whiteSpace isEqualToString:@" "] ||
        ![tok3 isKindOfClass:[CPNumberToken     class]] || ((CPNumberToken *)tok3).number.doubleValue != 56.78 ||
        ![tok4 isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok4).whiteSpace isEqualToString:@"\t"] ||
        ![tok5 isKindOfClass:[CPNumberToken     class]] || ((CPNumberToken *)tok5).number.doubleValue != 90 ||
        ![tok6 isKindOfClass:[CPEOFToken        class]])
    {
        STFail(@"Failed to tokenise white space correctly");
    }
}

@end
