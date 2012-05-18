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
#import "CPTestErrorEvaluatorDelegate.h"
#import "CPTestWhiteSpaceIgnoringDelegate.h"
#import "CPTestMapCSSTokenisingDelegate.h"
#import "CPTestErrorHandlingDelegate.h"

#import "Expression.h"

@interface CoreParseTests ()

- (void)runMapCSSTokeniser:(CPTokenStream *)result;

@end

@implementation CoreParseTests
{
    NSString *mapCssInput;
    CPParser *mapCssParser;
    CPTokeniser *mapCssTokeniser;
}

- (void)setUpMapCSS
{
    NSCharacterSet *identifierCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyz"
                                            @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                            @"0123456789-_"];
    NSCharacterSet *initialIdCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                           @"abcdefghijklmnopqrstuvwxyz"
                                           @"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                           @"_-"];
    mapCssTokeniser = [[CPTokeniser alloc] init];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"node"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"way"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"relation" invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"area"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"line"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"canvas"   invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"url"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"eval"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"rgba"     invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"rgb"      invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"pt"       invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"px"       invalidFollowingCharacters:identifierCharacters]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"["]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"]"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"."]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@","]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@";"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@import"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"|z"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"-"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"!="]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"=~"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">"]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<="]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">="]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"="]];
    [mapCssTokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@":"]];
    [mapCssTokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [mapCssTokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    [mapCssTokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [mapCssTokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" name:@"Comment"]];
    [mapCssTokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/"  endQuote:@"/"  escapeSequence:@"\\" name:@"Regex"]];
    [mapCssTokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'"  endQuote:@"'"  escapeSequence:@"\\" name:@"String"]];
    [mapCssTokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"]];
    [mapCssTokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniserWithInitialCharacters:initialIdCharacters identifierCharacters:identifierCharacters]];
    [mapCssTokeniser setDelegate:[[[CPTestMapCSSTokenisingDelegate alloc] init] autorelease]];
    
    mapCssInput = @"node[highway=\"trunk\"]"
    @"{"
    @"  line-width: 5.0;"
    @"  label: jam;"
    @"} // Zomg boobs!\n"
    @"/* Haha, fooled you */"
    @"way relation[type=\"multipolygon\"]"
    @"{"
    @"  line-width: 0.0;"
    @"}";
    
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"ruleset"
                                      backusNaurForm:
                          @"ruleset       ::= <rule>*;"
                          @"rule          ::= <selector> <commaSelector>* <declaration>+ | <import>;"
                          @"import        ::= '@import' 'url' '(' 'String' ')' 'Identifier';"
                          @"commaSelector ::= ',' <selector>;"
                          @"selector      ::= <subselector>+;"
                          @"subselector   ::= <object> 'Whitespace' | <object> <zoom> <test>* | <class>;"
                          @"zoom          ::= '|z' <range> | ;"
                          @"range         ::= 'Number' | 'Number' '-' 'Number';"
                          @"test          ::= '[' <condition> ']';"
                          @"condition     ::= <key> <binary> <value> | <unary> <key> | <key>;"
                          @"key           ::= 'Identifier';"
                          @"value         ::= 'String' | 'Regex';"
                          @"binary        ::= '=' | '!=' | '=~' | '<' | '>' | '<=' | '>=';"
                          @"unary         ::= '-' | '!';"
                          @"class         ::= '.' 'Identifier';"
                          @"object        ::= 'node' | 'way' | 'relation' | 'area' | 'line' | '*';"
                          @"declaration   ::= '{' <style>+ '}' | '{' '}';"
                          @"style         ::= <styledef> ';';"
                          @"styledef      ::= <key> ':' <unquoted>;"
                          @"unquoted      ::= 'Number' | 'Identifier';"];
    mapCssParser = [[CPLALR1Parser alloc] initWithGrammar:grammar];
}

- (void)tearDownMapCSS
{
    [mapCssParser release];
    [mapCssTokeniser release];
}

- (void)testKeywordTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"{}"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"{"], [CPKeywordToken tokenWithKeyword:@"}"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of braces", nil);
}

- (void)testIntegerTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of integers", nil);

    tokenStream = [tokeniser tokenise:@"1234abcd"];
    expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [CPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of integers with additional cruft", nil);
}

- (void)testFloatTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser floatRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of floats", nil);
    
    tokenStream = [tokeniser tokenise:@"1234"];
    expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObject:[CPErrorToken errorWithMessage:nil]]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Tokenising floats recognises integers as well", nil);
}

- (void)testNumberTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];

    CPTokenStream *tokenStream = [tokeniser tokenise:@"1234.5678"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:1234.5678]], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of numbers", nil);
    
    tokenStream = [tokeniser tokenise:@"1234abcd"];
    expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPNumberToken tokenWithNumber:[NSNumber numberWithInteger:1234]], [CPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrect tokenisation of numbers with additional cruft", nil);
}

- (void)testWhiteSpaceTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"12.34 56.78\t90"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                               [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:12.34]], [CPWhiteSpaceToken whiteSpace:@" "],
                                                                               [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:56.78]], [CPWhiteSpaceToken whiteSpace:@"\t"],
                                                                               [CPNumberToken tokenWithNumber:[NSNumber numberWithDouble:90]]   , [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Failed to tokenise white space correctly", nil);
}

- (void)testIdentifierTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"long"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"long jam _ham long _spam59e_53"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                               [CPKeywordToken tokenWithKeyword:@"long"]             , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                               [CPIdentifierToken tokenWithIdentifier:@"jam"]        , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                               [CPIdentifierToken tokenWithIdentifier:@"_ham"]       , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                               [CPKeywordToken tokenWithKeyword:@"long"]             , [CPWhiteSpaceToken whiteSpace:@" "],
                                                                               [CPIdentifierToken tokenWithIdentifier:@"_spam59e_53"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Failed to tokenise identifiers space correctly", nil);
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniserWithInitialCharacters:[NSCharacterSet characterSetWithCharactersInString:@"abc"]
                                                                               identifierCharacters:[NSCharacterSet characterSetWithCharactersInString:@"def"]]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    tokenStream = [tokeniser tokenise:@"adef abdef"];
    expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                                [CPIdentifierToken tokenWithIdentifier:@"adef"], [CPWhiteSpaceToken whiteSpace:@" "],
                                                                [CPIdentifierToken tokenWithIdentifier:@"a"], [CPIdentifierToken tokenWithIdentifier:@"bdef"],
                                                                [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Incorrectly tokenised identifiers", nil);
}

- (void)testQuotedTokeniser
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */"];
    CPTokenStream *expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise comment", nil);
    
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"]];
    tokenStream = [tokeniser tokenise:@"/* abc */\"def\""];
    expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abc " quotedWith:@"/*" name:@"Comment"], [CPQuotedToken content:@"def" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise comment and string", nil);
    
    tokenStream = [tokeniser tokenise:@"\"def\\\"\""];
    expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"def\"" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise string with quote in it", nil);
    
    tokenStream = [tokeniser tokenise:@"\"def\\\\\""];
    expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"def\\" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to tokenise string with backslash in it", nil);

    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    CPQuotedRecogniser *rec = [CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"];
    [rec setEscapeReplacer:^ NSString * (NSString *str, NSUInteger *loc)
     {
         if ([str length] > *loc)
         {
             switch ([str characterAtIndex:*loc])
             {
                 case 'b':
                     *loc = *loc + 1;
                     return @"\b";
                 case 'f':
                     *loc = *loc + 1;
                     return @"\f";
                 case 'n':
                     *loc = *loc + 1;
                     return @"\n";
                 case 'r':
                     *loc = *loc + 1;
                     return @"\r";
                 case 't':
                     *loc = *loc + 1;
                     return @"\t";
                 default:
                     break;
             }
         }
         return nil;
     }];
    [tokeniser addTokenRecogniser:rec];
    tokenStream = [tokeniser tokenise:@"\"\\n\\r\\f\""];
    expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"\n\r\f" quotedWith:@"\"" name:@"String"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to correctly tokenise string with recognised escape chars", nil);
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"'" endQuote:@"'" escapeSequence:nil maximumLength:1 name:@"Character"]];
    tokenStream = [tokeniser tokenise:@"'a''bc'"];
    expectdTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@"a" quotedWith:@"'" name:@"Character"], [CPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectdTokenStream, @"Failed to correctly tokenise characters", nil);
}

- (void)testTokeniserError
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"/* abcde ghi */ abc /* def */"];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [CPErrorToken errorWithMessage:nil], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Inserting error token and bailing failed", nil);
    
    [tokeniser setDelegate:[[[CPTestErrorHandlingDelegate alloc] init] autorelease]];
    tokenStream = [tokeniser tokenise:@"/* abcde ghi */ abc /* def */"];
    expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:[CPQuotedToken content:@" abcde ghi " quotedWith:@"/*" name:@"Comment"], [CPErrorToken errorWithMessage:nil], [CPQuotedToken content:@" def " quotedWith:@"/*" name:@"Comment"], [CPEOFToken eof], nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Inserting error token and continuing according to delegate failed.", nil);
}

- (void)testTokenLineColumnNumbers
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"long"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"/* blah\nblah blah\n blah */ long jam\n\nlong ham"];
    NSUInteger tokenLines[]     = {0, 2 , 2 , 2 , 2 , 2 , 4 , 4 , 4 , 4 };
    NSUInteger tokenColumns[]   = {0, 8 , 9 , 13, 14, 17, 0 , 4 , 5 , 8 };
    NSUInteger tokenPositions[] = {0, 26, 27, 31, 32, 35, 37, 41, 42, 45};
    NSUInteger tokenNumber = 0;
    CPToken *token = nil;
    while ((token = [tokenStream popToken]))
    {
        STAssertEquals([token lineNumber     ], tokenLines  [tokenNumber]  , @"Line number for token %lu is incorrect", tokenNumber, nil);
        STAssertEquals([token columnNumber   ], tokenColumns[tokenNumber]  , @"Column number for token %lu is incorrect", tokenNumber, nil);
        STAssertEquals([token characterNumber], tokenPositions[tokenNumber], @"Character nmber for token %lu is incorrect", tokenNumber, nil);
        tokenNumber++;
    }
}

- (void)testMapCSSTokenisation
{
    [self setUpMapCSS];
    
    CPTokenStream *tokenStream = [mapCssTokeniser tokenise:mapCssInput];
    CPTokenStream *expectedTokenStream = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
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
                                                                               [CPKeywordToken tokenWithKeyword:@"way"],
                                                                               [CPWhiteSpaceToken whiteSpace:@" "],
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
                                                                               nil]];
    STAssertEqualObjects(tokenStream, expectedTokenStream, @"Tokenisation of MapCSS failed", nil);
    
    [self tearDownMapCSS];
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
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
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
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using SLR parser", nil);
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
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
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
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using LR(1) parser", nil);
    
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
    
    STAssertEqualObjects(tree, sTree, @"Parsing LR(1) grammar failed when using LR(1) parser", nil);
}

- (void)testLALR1
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"*10 = 5"];
    
    CPRule *sL = [CPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"l"], [CPGrammarSymbol terminalWithName:@"="], [CPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    CPRule *sR = [CPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    CPRule *lM = [CPRule ruleWithName:@"l" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"r"], nil]];
    CPRule *lN = [CPRule ruleWithName:@"l" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"Number"], nil]];
    CPRule *rL = [CPRule ruleWithName:@"r" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"l"], nil]];
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:sL, sR, lM, lN, rL, nil]];
    CPLALR1Parser *parser = [CPLALR1Parser parserWithGrammar:grammar];
    CPSyntaxTree *tree = [parser parse:tokenStream];
    
    CPSyntaxTree *tenTree  = [CPSyntaxTree syntaxTreeWithRule:lN children:[NSArray arrayWithObject:[CPNumberToken tokenWithNumber:[NSNumber numberWithInt:10]]]];
    CPSyntaxTree *fiveTree = [CPSyntaxTree syntaxTreeWithRule:lN children:[NSArray arrayWithObject:[CPNumberToken tokenWithNumber:[NSNumber numberWithInt:5]]]];
    CPSyntaxTree *tenRTree = [CPSyntaxTree syntaxTreeWithRule:rL children:[NSArray arrayWithObject:tenTree]];
    CPSyntaxTree *starTenTree = [CPSyntaxTree syntaxTreeWithRule:lM children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"*"], tenRTree, nil]];
    CPSyntaxTree *fiveRTree = [CPSyntaxTree syntaxTreeWithRule:rL children:[NSArray arrayWithObject:fiveTree]];
    CPSyntaxTree *wholeTree = [CPSyntaxTree syntaxTreeWithRule:sL children:[NSArray arrayWithObjects:starTenTree, [CPKeywordToken tokenWithKeyword:@"="], fiveRTree, nil]];
    
    STAssertEqualObjects(tree, wholeTree, @"Parsing LALR(1) grammar failed", nil);
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    CPRule *tE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"t"]] tag:0];
    CPRule *aE = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@"+"], [CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    CPRule *fT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol nonTerminalWithName:@"f"]] tag:2];
    CPRule *mT = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], [CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    CPRule *iF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol terminalWithName:@"Number"]] tag:4];
    CPRule *pF = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"("], [CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    grammar = [CPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:tE, aE, fT, mT, iF, pF, nil]];
    parser = [CPLALR1Parser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value when using LALR(1) parser", nil);
    
    tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"b"]];
    tokenStream = [tokeniser tokenise:@"aaabab"];
    CPRule *s  = [CPRule ruleWithName:@"s" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"b"], [CPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    CPRule *b1 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"a"], [CPGrammarSymbol nonTerminalWithName:@"b"], nil]];
    CPRule *b2 = [CPRule ruleWithName:@"b" rightHandSideElements:[NSArray arrayWithObject:[CPGrammarSymbol terminalWithName:@"b"]]];
    grammar = [CPGrammar grammarWithStart:@"s" rules:[NSArray arrayWithObjects:s, b1, b2, nil]];
    parser = [CPLALR1Parser parserWithGrammar:grammar];
    tree = [parser parse:tokenStream];
    
    CPSyntaxTree *bTree = [CPSyntaxTree syntaxTreeWithRule:b2 children:[NSArray arrayWithObject:[CPKeywordToken tokenWithKeyword:@"b"]]];
    CPSyntaxTree *abTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], bTree, nil]];
    CPSyntaxTree *aabTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], abTree, nil]];
    CPSyntaxTree *aaabTree = [CPSyntaxTree syntaxTreeWithRule:b1 children:[NSArray arrayWithObjects:[CPKeywordToken tokenWithKeyword:@"a"], aabTree, nil]];
    CPSyntaxTree *sTree = [CPSyntaxTree syntaxTreeWithRule:s children:[NSArray arrayWithObjects:aaabTree, abTree, nil]];
    
    STAssertEqualObjects(tree, sTree, @"Parsing LR(1) grammar failed when using LALR(1) parser", nil);
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
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2 * 5 + 9) * 8"];
    
    CPRule *e1 = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:0];
    CPRule *e2 = [CPRule ruleWithName:@"e" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@"+"], [CPGrammarSymbol nonTerminalWithName:@"t"], nil] tag:1];
    
    CPRule *t1 = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:2];
    CPRule *t2 = [CPRule ruleWithName:@"t" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"t"], [CPGrammarSymbol terminalWithName:@"*"], [CPGrammarSymbol nonTerminalWithName:@"f"], nil] tag:3];
    
    CPRule *f1 = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"Number"], nil] tag:4];
    CPRule *f2 = [CPRule ruleWithName:@"f" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"("], [CPGrammarSymbol nonTerminalWithName:@"e"], [CPGrammarSymbol terminalWithName:@")"], nil] tag:5];
    
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" rules:[NSArray arrayWithObjects:e1,e2,t1,t2,f1,f2, nil]];
    NSString *testGrammar =
        @"0 e ::= <t>;"
        @"1 e ::= <e> '+' <t>;"
        @"2 t ::= <f>;"
        @"3 t ::= <t> '*' <f>;"
        @"4 f ::= 'Number';"
        @"5 f ::= '(' <e> ')';";
    CPGrammar *grammar1 = [CPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar];
    
    STAssertEqualObjects(grammar, grammar1, @"Crating grammar from BNF failed", nil);
        
    CPParser *parser = [CPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 157, @"Parsed expression had incorrect value", nil);
}

- (void)testSingleQuotesInGrammars
{
    NSString *testGrammar1 =
        @"e ::= <t>;"
        @"e ::= <e> \"+\" <t>;"
        @"t ::= <f>;"
        @"t ::= <t> \"*\" <f>;"
        @"f ::= \"Number\";"
        @"f ::= \"(\" <e> \")\";";
    NSString *testGrammar2 =
        @"e ::= <t>;"
        @"e ::= <e> '+' <t>;"
        @"t ::= <f>;"
        @"t ::= <t> '*' <f>;"
        @"f ::= \"Number\";"
        @"f ::= '(' <e> ')';";
    
    STAssertEqualObjects([CPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar1], [CPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar2], @"Grammars using double and single quotes were not equal", nil);
}

- (void)testMapCSSTokenisationPt
{
    [self setUpMapCSS];
    CPTokenStream *t1 = [mapCssTokeniser tokenise:@"way { jam: 0.0 pt; }"];
    CPTokenStream *t2 = [CPTokenStream tokenStreamWithTokens:[NSArray arrayWithObjects:
                                                              [CPKeywordToken tokenWithKeyword:@"way"],
                                                              [CPWhiteSpaceToken whiteSpace:@" "],
                                                              [CPKeywordToken tokenWithKeyword:@"{"],
                                                              [CPIdentifierToken tokenWithIdentifier:@"jam"],
                                                              [CPKeywordToken tokenWithKeyword:@":"],
                                                              [CPNumberToken tokenWithNumber:[NSNumber numberWithFloat:0.0f]],
                                                              [CPKeywordToken tokenWithKeyword:@"pt"],
                                                              [CPKeywordToken tokenWithKeyword:@";"],
                                                              [CPKeywordToken tokenWithKeyword:@"}"],
                                                              [CPEOFToken eof],
                                                              nil]];
    STAssertEqualObjects(t1, t2, @"Tokenised MapCSS with size specifier incorrectly", nil);
    
    [self tearDownMapCSS];
}

- (void)testMapCSSParsing
{
    [self setUpMapCSS];
    CPSyntaxTree *tree = [mapCssParser parse:[mapCssTokeniser tokenise:mapCssInput]];
    
    STAssertNotNil(tree, @"Failed to parse MapCSS", nil);
    
    [self tearDownMapCSS];
}

- (void)testParallelParsing
{
    [self setUpMapCSS];
    CPTokenStream *stream = [[[CPTokenStream alloc] init] autorelease];
    [NSThread detachNewThreadSelector:@selector(runMapCSSTokeniser:) toTarget:self withObject:stream];
    CPSyntaxTree *tree1 = [mapCssParser parse:stream];
    CPSyntaxTree *tree2 = [mapCssParser parse:[mapCssTokeniser tokenise:mapCssInput]];
    
    STAssertEqualObjects(tree1, tree2, @"Parallel parse of MapCSS failed", nil);
    
    [self tearDownMapCSS];
}

- (void)testParseResultParsing
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + 9 + 2 + 7"];
    
    NSString *testGrammar =
        @"Expression ::= <Term> | <Expression> '+' <Term>;"
        @"Term       ::= 'Number';";
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"Expression" backusNaurForm:testGrammar];
    CPParser *parser = [CPSLRParser parserWithGrammar:grammar];
    Expression *e = [parser parse:tokenStream];
    
    STAssertEqualObjects([e description], @"(((((<Number: 5>)) <Keyword: +> (<Number: 9>)) <Keyword: +> (<Number: 2>)) <Keyword: +> (<Number: 7>))", @"Syntax tree description doesn't match!");
  
    // commented out because CPSyntaxTree doesn't have a -value method. Caused the test to fail.
    // TODO: Write a better test. :)
//    STAssertEquals([e value], 23.0f, @"Parsing with ParseResult protocol produced incorrect result: %f", [e value]);
}

- (void)runMapCSSTokeniser:(CPTokenStream *)result
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [mapCssTokeniser tokenise:mapCssInput into:result];
    [pool drain];
}

- (void)testJSONParsing
{
    CPJSONParser *jsonParser = [[[CPJSONParser alloc] init] autorelease];
    id<NSObject> result = [jsonParser parse:@"{\"a\":\"b\", \"c\":true, \"d\":5.93, \"e\":[1,2,3], \"f\":null}"];
    
    NSDictionary *expectedResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"b"                             , @"a",
                                    [NSNumber numberWithBool:YES]    , @"c",
                                    [NSNumber numberWithDouble:5.93] , @"d",
                                    [NSArray arrayWithObjects:
                                     [NSNumber numberWithDouble:1],
                                     [NSNumber numberWithDouble:2],
                                     [NSNumber numberWithDouble:3],
                                     nil]                            , @"e",
                                    [NSNull null]                    , @"f",
                                    nil];
    STAssertEqualObjects(result, expectedResult, @"Failed to parse JSON", nil);
}

- (void)testEBNF
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"b"]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *starGrammarString = @"A ::= 'b''a'*;";
    CPGrammar *starGrammar = [CPGrammar grammarWithStart:@"A" backusNaurForm:starGrammarString];
    CPParser *starParser = [CPLALR1Parser parserWithGrammar:starGrammar];
    CPSyntaxTree *starTree = [starParser parse:tokenStream];
    tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *plusGrammarString = @"A ::= 'b''a'+;";
    CPGrammar *plusGrammar = [CPGrammar grammarWithStart:@"A" backusNaurForm:plusGrammarString];
    CPParser *plusParser = [CPLALR1Parser parserWithGrammar:plusGrammar];
    CPSyntaxTree *plusTree = [plusParser parse:tokenStream];
    tokenStream = [tokeniser tokenise:@"baaa"];
    NSString *queryGrammarString = @"A ::= 'b''a''a''a''a'?;";
    CPGrammar *queryGrammar = [CPGrammar grammarWithStart:@"A" backusNaurForm:queryGrammarString];
    CPParser *queryParser = [CPLALR1Parser parserWithGrammar:queryGrammar];
    CPSyntaxTree *queryTree = [queryParser parse:tokenStream];
    tokenStream = [tokeniser tokenise:@"baaab"];
    NSString *parenGrammarString = @"A ::= 'b'('a')*'b';";
    CPGrammar *parenGrammar = [CPGrammar grammarWithStart:@"A" backusNaurForm:parenGrammarString];
    CPParser *parenParser = [CPLALR1Parser parserWithGrammar:parenGrammar];
    CPSyntaxTree *parenTree = [parenParser parse:tokenStream];
    
    STAssertNotNil(starTree, @"EBNF star parser produced nil result", nil);
    NSArray *as = [[starTree children] objectAtIndex:1];
    if (![[(CPKeywordToken *)[[starTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(CPKeywordToken *)[as objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[as objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[as objectAtIndex:2] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF star parser did not correctly parse its result", nil);
    }
    STAssertNotNil(plusTree, @"EBNF plus parser produced nil result", nil);
    as = [[plusTree children] objectAtIndex:1];
    if (![[(CPKeywordToken *)[[plusTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(CPKeywordToken *)[as objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[as objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[as objectAtIndex:2] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF plus parser did not correctly parse its result", nil);
    }
    STAssertNotNil(queryTree, @"EBNF query parser produced nil result", nil);
    as = [[queryTree children] objectAtIndex:4];
    if (![[(CPKeywordToken *)[[queryTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        ![[(CPKeywordToken *)[[queryTree children] objectAtIndex:1] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[[queryTree children] objectAtIndex:2] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[[queryTree children] objectAtIndex:3] keyword] isEqualToString:@"a"] ||
        [as count] != 0)
    {
        STFail(@"EBNF query parser did not correctly parse its result", nil);
    }
    STAssertNotNil(parenTree, @"EBNF paren parser produced nil result", nil);
    as = [[parenTree children] objectAtIndex:1];
    if (![[(CPKeywordToken *)[[parenTree children] objectAtIndex:0] keyword] isEqualToString:@"b"] ||
        [as count] != 3 ||
        ![[(CPKeywordToken *)[(NSArray *)[as objectAtIndex:0] objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[(NSArray *)[as objectAtIndex:1] objectAtIndex:0] keyword] isEqualToString:@"a"] ||
        ![[(CPKeywordToken *)[(NSArray *)[as objectAtIndex:2] objectAtIndex:0] keyword] isEqualToString:@"a"])
    {
        STFail(@"EBNF paren parser did not correctly parse its result", nil);
    }
}

- (void)testEncodingAndDecodingOfParsers
{
    [self setUpMapCSS];
    
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:mapCssTokeniser];
    CPTokeniser *mapCssTokeniser2 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    [mapCssTokeniser2 setDelegate:[mapCssTokeniser delegate]];
    CPTokenStream *tokenStream = [mapCssTokeniser tokenise:mapCssInput];
    CPTokenStream *tokenStream2 = [mapCssTokeniser2 tokenise:mapCssInput];
    
    STAssertEqualObjects(tokenStream, tokenStream2, @"Failed to encode and decode MapCSSTokeniser", nil);
    
    d = [NSKeyedArchiver archivedDataWithRootObject:mapCssParser];
    CPParser *mapCssParser2 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    CPSyntaxTree *tree = [mapCssParser2 parse:tokenStream];
    
    STAssertNotNil(tree, @"Failed to encode and decode MapCSSParser", nil);
    
    [self tearDownMapCSS];
}

- (void)testParserErrors
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"a"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"b"]];
    NSString *starGrammarString = @"A ::= 'b''a'*;";
    CPGrammar *starGrammar = [CPGrammar grammarWithStart:@"A" backusNaurForm:starGrammarString];
    CPParser *starParser = [CPLALR1Parser parserWithGrammar:starGrammar];
    
    CPTokenStream *faultyTokenStream = [tokeniser tokenise:@"baab"];
    CPTokenStream *corretTokenStream = [tokeniser tokenise:@"baa"];
    CPTestErrorHandlingDelegate *errorDelegate = [[[CPTestErrorHandlingDelegate alloc] init] autorelease];
    [starParser setDelegate:errorDelegate];
    CPSyntaxTree *faultyTree = [starParser parse:faultyTokenStream];
    STAssertTrue([errorDelegate hasEncounteredError], @"Error did not get reported to delegate", nil);
    
    CPSyntaxTree *correctTree = [starParser parse:corretTokenStream];
    STAssertEqualObjects(faultyTree, correctTree, @"Error in input stream was not correctly dealt with", nil);
}

- (void)testErrorRecovery
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];
    [tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];
    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + + (2 * error + 3) * 8"];
    
    NSString *testGrammar =
      @"0 e ::= <t>;"
      @"1 e ::= <e> '+' <t>;"
      @"1 e ::= 'Error' '+' <t>;"
      @"1 e ::= <e> '+' 'Error';"
      @"2 t ::= <f>;"
      @"3 t ::= <t> '*' <f>;"
      @"3 t ::= 'Error' '*' <f>;"
      @"3 t ::= <t> '*' 'Error';"
      @"4 f ::= 'Number';"
      @"5 f ::= '(' <e> ')';";
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" backusNaurForm:testGrammar];
    
    CPParser *parser = [CPSLRParser parserWithGrammar:grammar];
    [parser setDelegate:[[[CPTestErrorEvaluatorDelegate alloc] init] autorelease]];
    NSNumber *result = [parser parse:tokenStream];
    
    STAssertEquals([result intValue], 45, @"Parsed expression had incorrect value", nil);
}

@end
