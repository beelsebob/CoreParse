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
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"{"], [CPKeywordToken tokenWithKeyword:@"}"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Incorrect tokenisation of braces",nil);
    }
}

- (void)testIntegerTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234"];
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [CPEOFToken eof], nil]]])
    {
        STFail(@"Incorrect tokenisation of integers",nil);
    }

    tokenStream = [tokeniser tokenise:@"1234abcd"];
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], nil]]])
    {
        STFail(@"Incorrect tokenisation of integers with additional cruft",nil);
    }
}

- (void)testFloatTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser floatRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [CPEOFToken eof], nil]]])
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
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [CPEOFToken eof], nil]]])
    {
        STFail(@"Incorrect tokenisation of numbers",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"1234abcd"];
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], nil]]])
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
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                    [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:12.34]], [CPWhiteSpaceToken whiteSpace:@" "],
                                                                    [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:56.78]], [CPWhiteSpaceToken whiteSpace:@"\t"],
                                                                    [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:90]]   , [CPEOFToken eof], nil]]])
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
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                    [CPKeywordToken tokenWithKeyword:@"long"]             , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                    [CPIdentifierToken tokenWithIdentifier:@"jam"]        , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                    [CPIdentifierToken tokenWithIdentifier:@"_ham"]       , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                    [CPKeywordToken tokenWithKeyword:@"long"]             , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                    [CPIdentifierToken tokenWithIdentifier:@"_spam59e_53"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Failed to tokenise identifiers space correctly",nil);
    }
}

- (void)testQuotedTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */"];
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Failed to tokenise comment",nil);
    }
    
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" name:@"String"]];
    tokenStream = [tokeniser tokenise:@"/* abc */\"def\""];
    
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abc " quotedWith:@"/*" name:@"Comment"], [CPQuotedToken content:@"def" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Failed to tokenise comment and string",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"\"def\\\"\""];
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"def\\\"" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Failed to tokenise string with quote in it",nil);
    }
    
    tokenStream = [tokeniser tokenise:@"\"def\\\\\""];
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"def\\\\" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]]])
    {
        STFail(@"Failed to tokenise string with backslash in it",nil);
    }
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapedEndQuote:nil escapedEscape:nil maximumLength:1 name:@"Character"]];
    tokenStream = [tokeniser tokenise:@"'a''bc'"];
    if (![tokenStream isEqual:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"a" quotedWith:@"'" name:@"Character"], nil]]])
    {
        STFail(@"Failed to correctly tokenise characters",nil);
    }
}

- (void)testMapCSSTokenisation
{
    NSCharacterSet *identifierCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyz"
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                            @"0123456789-_"];
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"node"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"way"      invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"relation" invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"area"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"line"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
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
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapedEndQuote:@"\\'" escapedEscape:@"\\\\" name:@"String"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" name:@"String"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"node[highway=\"trunk\"] { line-width: 5.0; label: jam; } // Zomg boobs!\n /* Haha, fooled you */ relation[type=\"multipolygon\"] { line-width: 0.0; }"];
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([[token name] isEqualToString:@"Whitespace"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    
    if (![tokenStream isEqualTo:[CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
           [CPKeywordToken tokenWithKeyword:@"node"],
           [CPKeywordToken tokenWithKeyword:@"["],
           [CPIdentifierToken tokenWithIdentifier:@"highway"],
           [CPKeywordToken tokenWithKeyword:@"="],
           [CPQuotedToken content:@"trunk" quotedWith:@"\"" name:@"String"],
           [CPKeywordToken tokenWithKeyword:@"]"],
           [CPKeywordToken tokenWithKeyword:@"{"],
           [CPIdentifierToken tokenWithIdentifier:@"line-width"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPNumberToken tokenWithNumber:[NSNumber numberWithFloat:5.0f]],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPIdentifierToken tokenWithIdentifier:@"label"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPIdentifierToken tokenWithIdentifier:@"jam"],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPKeywordToken tokenWithKeyword:@"}"],
           [CPQuotedToken content:@" Zomg boobs!" quotedWith:@"//" name:@"Comment"],
           [CPQuotedToken content:@" Haha, fooled you " quotedWith:@"/*" name:@"Comment"],
           [CPKeywordToken tokenWithKeyword:@"relation"],
           [CPKeywordToken tokenWithKeyword:@"["],
           [CPIdentifierToken tokenWithIdentifier:@"type"],
           [CPKeywordToken tokenWithKeyword:@"="],
           [CPQuotedToken content:@"multipolygon" quotedWith:@"\"" name:@"String"],
           [CPKeywordToken tokenWithKeyword:@"]"],
           [CPKeywordToken tokenWithKeyword:@"{"],
           [CPIdentifierToken tokenWithIdentifier:@"line-width"],
           [CPKeywordToken tokenWithKeyword:@":"],
           [CPNumberToken tokenWithNumber:[NSNumber numberWithFloat:0.0f]],
           [CPKeywordToken tokenWithKeyword:@";"],
           [CPKeywordToken tokenWithKeyword:@"}"],
           [CPEOFToken eof],
           nil]]])
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
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([[token name] isEqualToString:@"Whitespace"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    
    CPRule *tE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    CPRule *aE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@"+"], [CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    CPRule *fT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    CPRule *mT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], [CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    CPRule *iF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    CPRule *pF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"("], [CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    CPSLRParser *parser = [CPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestEvaluatorDelegate alloc] init] autorelease]];
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
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([[token name] isEqualToString:@"Whitespace"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    
    CPRule *tE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    CPRule *aE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@"+"], [CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    CPRule *fT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    CPRule *mT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], [CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    CPRule *iF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    CPRule *pF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"("], [CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    CPLR1Parser *parser = [CPLR1Parser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    if ([result intValue] != 157)
    {
        STFail(@"Parsed expression had incorrect value", nil);
    }
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"b"]];
    tokenStream = [tokeniser tokenise:@"aaabab"];
    CPRule *s  = [CPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"b"], [CPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    CPRule *b1 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"a"], [CPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    CPRule *b2 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol terminalWithName:@"b"]]];
    grammar = [CPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:s, b1, b2, nil]];
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

- (void)testBNFGrammarGeneration
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([[token name] isEqualToString:@"Whitespace"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    
    CPRule *e1 = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:0];
    CPRule *e2 = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@"+"], [CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    
    CPRule *t1 = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:2];
    CPRule *t2 = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], [CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    
    CPRule *f1 = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"Number"], nil] tag:4];
    CPRule *f2 = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"("], [CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:e1,e2,t1,t2,f1,f2, nil]];
    NSString *testGrammar =
        @"0 e ::= <t>;"
        @"1 e ::= <e> \"+\" <t>;"
        @"2 t ::= <f>;"
        @"3 t ::= <t> \"*\" <f>;"
        @"4 f ::= \"Number\";"
        @"5 f ::= \"(\" <e> \")\";";
    CPGrammar *grammar1 = [CPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar];
    
    if (![grammar isEqual:grammar1])
    {
        STFail(@"Crating grammar from BNF failed", nil);
    }
    
    CPParser *parser = [CPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    if ([result intValue] != 157)
    {
        STFail(@"Parsed expression had incorrect value", nil);
    }
}

- (void)testMapCSSParsing
{
    NSCharacterSet *identifierCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyz"
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                            @"0123456789-_"];
    NSCharacterSet *initialIdCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                           @"abcdefghijklmnopqrstuvwxyz"
                                           @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                           @"_-"];
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"node"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"way"      invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"relation" invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"area"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"line"     invalidFollowingCharacters:identifierCharacters]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"["]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"]"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"."]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@","]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@";"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@import"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"url"]];
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
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapedEndQuote:@"\\'" escapedEscape:@"\\\\" name:@"String"]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" name:@"String"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniserWithInitialCharacters:initialIdCharacters identifierCharacters:identifierCharacters]];
    
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"ruleset"
                                      backusNaurForm:
                          @"ruleset      ::= <rule> | <ruleset> <rule>;"
                          @"rule         ::= <selectors> <declarations> | <import>;"
                          @"import       ::= \"@import\" \"url\" \"(\" \"String\" \")\" \"Identifier\";"
                          @"selectors    ::= <selector> | <selectors> \",\" <selector>;"
                          @"selector     ::= <subselector> | <selector> <subselector>;"
                          @"subselector  ::= <object> <zoom> | <object> <zoom> <tests> | <class>;"
                          @"zoom         ::= \"|z\" <range> | ;"
                          @"range        ::= \"Number\" | \"Number\" \"-\" \"Number\";"
                          @"tests        ::= <test> | <tests> <test>;"
                          @"test         ::= \"[\" <condition> \"]\";"
                          @"condition    ::= <key> <binary> <value> | <unary> <key> | <key>;"
                          @"key          ::= \"Identifier\";"
                          @"value        ::= \"String\";"
                          @"binary       ::= \"=\" | \"!=\" | \"=~\" | \"<\" | \">\" | \"<=\" | \">=\";"
                          @"unary        ::= \"-\" | \"!\";"
                          @"class        ::= \".\" \"Identifier\";"
                          @"object       ::= \"node\" | \"way\" | \"relation\" | \"area\" | \"line\" | \"*\";"
                          @"declarations ::= <declaration> | <declarations> <declaration>;"
                          @"declaration  ::= \"{\" <styleset> \"}\" | \"{\" \"}\";"
                          @"styleset     ::= <style> | <styleset> <style>;"
                          @"style        ::= <styledef> \";\";"
                          @"styledef     ::= <key> \":\" <unquoted>;"
                          @"unquoted     ::= \"Number\" | \"Identifier\";"];
    CPParser *parser = [CPSLRParser parserWithGrammar:grammar];
    
    
    CPTokenStream *tokenStream = [tokeniser tokenise:
                                  @"node[highway=\"trunk\"]"
                                  @"{"
                                  @"  line-width: 5.0;"
                                  @"  label: jam;"
                                  @"} // Zomg boobs!\n"
                                  @"/* Haha, fooled you */"
                                  @"relation[type=\"multipolygon\"]"
                                  @"{"
                                  @"  line-width: 0.0;"
                                  @"}"];
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([[token name] isEqualToString:@"Whitespace"] || [[token name] isEqualToString:@"Comment"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    CPSyntaxTree *tree = [parser parse:tokenStream];
    
    if (nil == tree)
    {
        STFail(@"Failed to parse MapCSS", nil);
    }
    NSLog(@"%@", tree);
}

@end
