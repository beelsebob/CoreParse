//
//  CoreParseTests.m
//  CoreParseTests
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CoreParseTests.h"

#import "CoreParse.h"

#import "CPTestEvaluatorDelegate.h"

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
        STFail(@"Incorrect tokenisation of braces",nil);
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
        STFail(@"Incorrect tokenisation of integers",nil);
    }

    tokenStream = [tokeniser tokenise:@"1234abcd"];
    tok1 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.integerValue != 1234)
    {
        STFail(@"Incorrect tokenisation of integers with additional cruft",nil);
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
        STFail(@"Incorrect tokenisation of floats",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"1234"];
    if ([tokenStream hasToken])
    {
        STFail(@"Tokenising floats recognises integers as well",nil);
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
        STFail(@"Incorrect tokenisation of numbers",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"1234abcd"];
    tok1 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPNumberToken class]] || ((CPNumberToken *)tok1).number.integerValue != 1234)
    {
        STFail(@"Incorrect tokenisation of numbers with additional cruft",nil);
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
        STFail(@"Failed to tokenise white space correctly",nil);
    }
}

- (void)testIdentifierTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"long"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"long jam _ham long _spam59e_53"];
    CPToken *tok1  = [tokenStream popToken];
    CPToken *tok2  = [tokenStream popToken];
    CPToken *tok3  = [tokenStream popToken];
    CPToken *tok4  = [tokenStream popToken];
    CPToken *tok5  = [tokenStream popToken];
    CPToken *tok6  = [tokenStream popToken];
    CPToken *tok7  = [tokenStream popToken];
    CPToken *tok8  = [tokenStream popToken];
    CPToken *tok9  = [tokenStream popToken];
    CPToken *tok10 = [tokenStream popToken];
    
    if (![tok1  isKindOfClass:[CPKeywordToken    class]] || ![((CPKeywordToken *)tok1).keyword       isEqualToString:@"long"       ] ||
        ![tok2  isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok2).whiteSpace isEqualToString:@" "          ] ||
        ![tok3  isKindOfClass:[CPIdentifierToken class]] || ![((CPIdentifierToken *)tok3).identifier isEqualToString:@"jam"        ] ||
        ![tok4  isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok4).whiteSpace isEqualToString:@" "          ] ||
        ![tok5  isKindOfClass:[CPIdentifierToken class]] || ![((CPIdentifierToken *)tok5).identifier isEqualToString:@"_ham"       ] ||
        ![tok6  isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok6).whiteSpace isEqualToString:@" "          ] ||
        ![tok7  isKindOfClass:[CPKeywordToken    class]] || ![((CPKeywordToken *)tok7).keyword       isEqualToString:@"long"       ] ||
        ![tok8  isKindOfClass:[CPWhiteSpaceToken class]] || ![((CPWhiteSpaceToken *)tok8).whiteSpace isEqualToString:@" "          ] ||
        ![tok9  isKindOfClass:[CPIdentifierToken class]] || ![((CPIdentifierToken *)tok9).identifier isEqualToString:@"_spam59e_53"] ||
        ![tok10 isKindOfClass:[CPEOFToken        class]])
    {
        STFail(@"Failed to tokenise identifiers space correctly",nil);
    }
}

- (void)testQuotedTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" tokenName:@"Comment"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */"];
    CPToken *tok1 = [tokenStream popToken];
    CPToken *tok2 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok1).quoteType isEqualToString:@"/*"] || ![((CPQuotedToken *)tok1).content isEqualToString:@" abcde ghi "] ||
        ![tok2 isKindOfClass:[CPEOFToken    class]])
    {
        STFail(@"Failed to tokenise comment",nil);
    }
    
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" tokenName:@"String"]];
    tokenStream = [tokeniser tokenise:@"/* abc */\"def\""];
    tok1 = [tokenStream popToken];
    tok2 = [tokenStream popToken];
    CPToken *tok3 = [tokenStream popToken];
    
    if (![tok1 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok1).quoteType isEqualToString:@"/*"] || ![((CPQuotedToken *)tok1).content isEqualToString:@" abc "] ||
        ![tok2 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok2).quoteType isEqualToString:@"\""] || ![((CPQuotedToken *)tok2).content isEqualToString:@"def"  ] ||
        ![tok3 isKindOfClass:[CPEOFToken    class]])
    {
        STFail(@"Failed to tokenise comment and string",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"\"def\\\"\""];
    tok1 = [tokenStream popToken];
    tok2 = [tokenStream popToken];
    if (![tok1 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok1).quoteType isEqualToString:@"\""] || ![((CPQuotedToken *)tok1).content isEqualToString:@"def\\\""] ||
        ![tok2 isKindOfClass:[CPEOFToken    class]])
    {
        STFail(@"Failed to tokenise string with quote in it",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"\"def\\\\\""];
    tok1 = [tokenStream popToken];
    tok2 = [tokenStream popToken];
    if (![tok1 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok1).quoteType isEqualToString:@"\""] || ![((CPQuotedToken *)tok1).content isEqualToString:@"def\\\\"] ||
        ![tok2 isKindOfClass:[CPEOFToken    class]])
    {
        STFail(@"Failed to tokenise string with backslash in it",nil);
    }
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapedEndQuote:nil escapedEscape:nil maximumLength:1 tokenName:@"Character"]];
    tokenStream = [tokeniser tokenise:@"'a''bc'"];
    tok1 = [tokenStream popToken];
    if (![tok1 isKindOfClass:[CPQuotedToken class]] || ![((CPQuotedToken *)tok1).quoteType isEqualToString:@"'"] || ![((CPQuotedToken *)tok1).content isEqualToString:@"a"] ||
        [tokenStream hasToken])
    {
        STFail(@"Failed to correctly tokenise characters",nil);
    }
}

- (void)testMapCSSTokenisation
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"node"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"way"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"relation"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"["]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"]"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"."]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@";"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@import"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"|z"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"-"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"!="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"=~"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@":"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"eval"]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" tokenName:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" tokenName:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapedEndQuote:@"\\'" escapedEscape:@"\\\\" tokenName:@"String"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" tokenName:@"String"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"node[highway=trunk] { line-width: 5.0; label: \"jam\"; } // Zomg boobs!\n /* Haha, fooled you */ relation[type=multipolygon] { line-width: 0.0; }"];
    [tokenStream beginIgnoringTokenNamed:@"Whitespace"];
    
    if (![[tokenStream peekAllRemainingTokens] isEqualToArray:
          [NSArray arrayWithObjects:
           [CPKeywordToken tokenWithKeyword:@"node"],
           [CPKeywordToken tokenWithKeyword:@"["],
           [CPIdentifierToken tokenWithIdentifier:@"highway"],
           [CPKeywordToken tokenWithKeyword:@"="],
           [CPIdentifierToken tokenWithIdentifier:@"trunk"],
           [CPKeywordToken tokenWithKeyword:@"]"],
           [CPKeywordToken tokenWithKeyword:@"{"],
           [CPIdentifierToken tokenWithIdentifier:@"line-width"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPNumberToken tokenWithNumber:[NSNumber numberWithFloat:5.0f]],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPIdentifierToken tokenWithIdentifier:@"label"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPQuotedToken content:@"jam" quotedWith:@"\"" tokenName:@"String"],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPKeywordToken tokenWithKeyword:@"}"],
           [CPQuotedToken content:@" Zomg boobs!" quotedWith:@"//" tokenName:@"Comment"],
           [CPQuotedToken content:@" Haha, fooled you " quotedWith:@"/*" tokenName:@"Comment"],
           [CPKeywordToken tokenWithKeyword:@"relation"],
           [CPKeywordToken tokenWithKeyword:@"["],
           [CPIdentifierToken tokenWithIdentifier:@"type"],
           [CPKeywordToken tokenWithKeyword:@"="],
           [CPIdentifierToken tokenWithIdentifier:@"multipolygon"],
           [CPKeywordToken tokenWithKeyword:@"]"],
           [CPKeywordToken tokenWithKeyword:@"{"],
           [CPIdentifierToken tokenWithIdentifier:@"line-width"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPNumberToken tokenWithNumber:[NSNumber numberWithFloat:0.0f]],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPKeywordToken tokenWithKeyword:@"}"],
           [CPEOFToken eof],
           nil]])
    {
        STFail(@"Tokenisation of MapCSS failed", nil);
    }
}

- (void)testSLR
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    [tokenStream beginIgnoringTokenNamed:@"Whitespace"];
    
    CPRule *tE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[CPNonTerminal nonTerminalWithName:@"t"]] tag:0];
    CPRule *aE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"e"], [CPTerminal terminalWithTokenName:@"+"], [CPNonTerminal nonTerminalWithName:@"t"], nil] tag:1];
    CPRule *fT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[CPNonTerminal nonTerminalWithName:@"f"]] tag:2];
    CPRule *mT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"t"], [CPTerminal terminalWithTokenName:@"*"], [CPNonTerminal nonTerminalWithName:@"f"], nil] tag:3];
    CPRule *iF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[CPTerminal terminalWithTokenName:@"Number"]] tag:4];
    CPRule *pF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"("], [CPNonTerminal nonTerminalWithName:@"e"], [CPTerminal terminalWithTokenName:@")"], nil] tag:5];
    CPGrammar *grammar = [CPGrammar grammarWithStart:[CPNonTerminal nonTerminalWithName:@"e"] rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    CPSLRParser *parser = [CPSLRParser parserWithGrammar:grammar];
    parser.delegate = [[[CPTestEvaluatorDelegate alloc] init] autorelease];
    NSNumber *result = [parser parse:tokenStream];
    
    if ([result intValue] != 157)
    {
        STFail(@"Parsed expression had incorrect value", nil);
    }
}

- (void)testLR1
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    [tokenStream beginIgnoringTokenNamed:@"Whitespace"];
    
    CPRule *tE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[CPNonTerminal nonTerminalWithName:@"t"]] tag:0];
    CPRule *aE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"e"], [CPTerminal terminalWithTokenName:@"+"], [CPNonTerminal nonTerminalWithName:@"t"], nil] tag:1];
    CPRule *fT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[CPNonTerminal nonTerminalWithName:@"f"]] tag:2];
    CPRule *mT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"t"], [CPTerminal terminalWithTokenName:@"*"], [CPNonTerminal nonTerminalWithName:@"f"], nil] tag:3];
    CPRule *iF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[CPTerminal terminalWithTokenName:@"Number"]] tag:4];
    CPRule *pF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"("], [CPNonTerminal nonTerminalWithName:@"e"], [CPTerminal terminalWithTokenName:@")"], nil] tag:5];
    CPGrammar *grammar = [CPGrammar grammarWithStart:[CPNonTerminal nonTerminalWithName:@"e"] rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    CPLR1Parser *parser = [CPLR1Parser parserWithGrammar:grammar];
    parser.delegate = [[[CPTestEvaluatorDelegate alloc] init] autorelease];
    NSNumber *result = [parser parse:tokenStream];
    
    if ([result intValue] != 157)
    {
        STFail(@"Parsed expression had incorrect value", nil);
    }
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"b"]];
    tokenStream = [tokeniser tokenise:@"aaabab"];
    CPRule *s  = [CPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"b"], [CPNonTerminal nonTerminalWithName:@"b"], nil]];
    CPRule *b1 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"a"], [CPNonTerminal nonTerminalWithName:@"b"], nil]];
    CPRule *b2 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObject:[CPTerminal terminalWithTokenName:@"b"]]];
    grammar = [CPGrammar grammarWithStart:[CPNonTerminal nonTerminalWithName:@"s"] rules:[NSArray arrayWithObjects:s, b1, b2, nil]];
    parser = [CPLR1Parser parserWithGrammar:grammar];
    CPSyntaxTree *tree = [parser parse:tokenStream];
    
    CPSyntaxTree *bTree = [CPSyntaxTree syntaxTreeWithRule:b2 children:[NSArray arrayWithObject:[CPKeywordToken tokenWithKeyword:@"b"]]];
    CPSyntaxTree *abTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], bTree, nil]];
    CPSyntaxTree *aabTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], abTree, nil]];
    CPSyntaxTree *aaabTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], aabTree, nil]];
    CPSyntaxTree *sTree = [CPSyntaxTree syntaxTreeWithRule:s children:[NSArray arrayWithObjects:aaabTree, abTree, nil]];
    
    if (![tree isEqual:sTree])
    {
        STFail(@"Parsing LR1 grammar failed", nil);
    }
}

@end
