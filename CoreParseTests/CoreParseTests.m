//
//  CoreParseTests.m
//  CoreParseTests
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
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

- (void)testExample
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"{}"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    CPToken *tok3 = [tokenStream popToken];
    
    if (![tok1.content isEqualToString:@"{"] || ![tok2.content isEqualToString:@"}"] || ![tok3 isKindOfClass:[CPEOFToken class]])
    {
        STFail(@"Incorrect tokenisation");
    }
}

@end
