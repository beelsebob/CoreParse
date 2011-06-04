//
//  Grammar.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammar.h"
#import "CPGrammarPrivate.h"

#import "CPTokeniser.h"
#import "CPTokenStream.h"
#import "CPKeywordRecogniser.h"
#import "CPNumberRecogniser.h"
#import "CPWhitespaceRecogniser.h"
#import "CPWhiteSpaceToken.h"
#import "CPQuotedRecogniser.h"
#import "CPIdentifierRecogniser.h"
#import "CPSLRParser.h"
#import "CPIdentifierToken.h"
#import "CPQuotedToken.h"
#import "CPNumberToken.h"

#import "CPItem.h"
#import "CPLR1Item.h"

#import "NSSetFunctional.h"

@interface CPBNFParserDelegate : NSObject <CPTokeniserDelegate,CPParserDelegate>
@end

@implementation CPBNFParserDelegate

- (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
{
    NSArray *children = [syntaxTree children];
    switch ([[syntaxTree rule] tag])
    {
        case 0:
        {
            NSMutableArray *rules = (NSMutableArray *)[children objectAtIndex:0];
            [rules addObjectsFromArray:[children objectAtIndex:1]];
            return rules;
        }
        case 1:
            return [NSMutableArray arrayWithArray:[children objectAtIndex:0]];
        case 2:
        {
            NSArray *rules = [children objectAtIndex:1];
            for (CPRule *r in rules)
            {
                [r setTag:[[(CPNumberToken *)[children objectAtIndex:0] number] intValue]];
            }
            return rules;
        }
        case 3:
            return [children objectAtIndex:0];
        case 4:
        {
            NSArray *arrs = [children objectAtIndex:2];
            NSMutableArray *rules = [NSMutableArray arrayWithCapacity:[arrs count]];
            for (NSArray *rhs in arrs)
            {
                [rules addObject:[CPRule ruleWithName:[(CPIdentifierToken *)[children objectAtIndex:0] identifier] rightHandSideElements:rhs]];
            }
            return rules;
        }
        case 5:
        {
            NSMutableArray *rhs = [children objectAtIndex:0];
            [rhs addObject:[children objectAtIndex:2]];
            return rhs;
        }
        case 6:
        {
            NSMutableArray *rhs = [children objectAtIndex:0];
            [rhs addObject:[NSArray array]];
            return rhs;
        }
        case 7:
            return [NSMutableArray arrayWithObject:[children objectAtIndex:0]];
        case 8:
        {
            NSMutableArray *elements = (NSMutableArray *)[children objectAtIndex:0];
            [elements addObject:[children objectAtIndex:1]];
            return elements;
        }
        case 9:
            return [NSMutableArray arrayWithObject:[children objectAtIndex:0]];
        case 10:
        case 11:
            return [children objectAtIndex:0];
        case 12:
            return [CPGrammarSymbol nonTerminalWithName:[(CPIdentifierToken *)[children objectAtIndex:1] identifier]];
        case 13:
            return [CPGrammarSymbol terminalWithName:[(CPQuotedToken *)[children objectAtIndex:0] content]];
        default:
            return syntaxTree;
    }
}

- (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token
{
    return YES;
}

- (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token
{
    if ([token isKindOfClass:[CPWhiteSpaceToken class]])
    {
        return [NSArray array];
    }
    return [NSArray arrayWithObject:token];
}

@end

@implementation CPGrammar

@synthesize start;

+ (id)grammarWithStart:(NSString *)start rules:(NSArray *)rules
{
    return [[[self alloc] initWithStart:start rules:rules] autorelease];
}

- (id)initWithStart:(NSString *)initStart rules:(NSArray *)initRules;
{
    self = [super init];
    
    if (nil != self)
    {
        [self setStart:initStart];
        [self setRules:initRules];
        [self setFollowCache:[NSMutableDictionary dictionary]];
    }
    
    return self;
}

+ (id)grammarWithStart:(NSString *)start backusNaurForm:(NSString *)bnf
{
    return [[[self alloc] initWithStart:start backusNaurForm:bnf] autorelease];
}

- (id)initWithStart:(NSString *)initStart backusNaurForm:(NSString *)bnf
{
    CPBNFParserDelegate *del = [[[CPBNFParserDelegate alloc] init] autorelease];
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"::="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"|"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@";"]];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapeSequence:@"\\" name:@"String"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser setDelegate:del];
    CPTokenStream *tokenStream = [tokeniser tokenise:bnf];
    
    CPRule *ruleset1 = [CPRule ruleWithName:@"ruleset" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"ruleset"], [CPGrammarSymbol nonTerminalWithName:@"rule"], nil] tag:0];
    CPRule *ruleset2 = [CPRule ruleWithName:@"ruleset" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"rule"], nil] tag:1];
    
    CPRule *rule1 = [CPRule ruleWithName:@"rule" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"Number"], [CPGrammarSymbol nonTerminalWithName:@"unNumbered"], nil] tag:2];
    CPRule *rule2 = [CPRule ruleWithName:@"rule" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"unNumbered"], nil] tag:3];
    
    CPRule *unNumbered = [CPRule ruleWithName:@"unNumbered" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"Identifier"], [CPGrammarSymbol terminalWithName:@"::="], [CPGrammarSymbol nonTerminalWithName:@"rightHandSide"], [CPGrammarSymbol terminalWithName:@";"], nil] tag:4];
    
    CPRule *rightHandSide1 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"rightHandSide"], [CPGrammarSymbol terminalWithName:@"|"], [CPGrammarSymbol nonTerminalWithName:@"sumset"], nil] tag:5];
    CPRule *rightHandSide2 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"rightHandSide"], [CPGrammarSymbol terminalWithName:@"|"], nil] tag:6];
    CPRule *rightHandSide3 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"sumset"], nil] tag:7];
    
    CPRule *sumset1 = [CPRule ruleWithName:@"sumset" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"sumset"], [CPGrammarSymbol nonTerminalWithName:@"grammarSymbol"], nil] tag:8];
    CPRule *sumset2 = [CPRule ruleWithName:@"sumset" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"grammarSymbol"], nil] tag:9];
    
    CPRule *grammarSymbol1 = [CPRule ruleWithName:@"grammarSymbol" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"nonterminal"], nil] tag:10];
    CPRule *grammarSymbol2 = [CPRule ruleWithName:@"grammarSymbol" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol nonTerminalWithName:@"terminal"], nil] tag:11];
    
    CPRule *nonterminal = [CPRule ruleWithName:@"nonterminal" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"<"], [CPGrammarSymbol terminalWithName:@"Identifier"], [CPGrammarSymbol terminalWithName:@">"], nil] tag:12];
    
    CPRule *terminal = [CPRule ruleWithName:@"terminal" rightHandSideElements:[NSArray arrayWithObjects:[CPGrammarSymbol terminalWithName:@"String"], nil] tag:13];
    
    CPGrammar *bnfGrammar = [CPGrammar grammarWithStart:@"ruleset" rules:[NSArray arrayWithObjects:ruleset1, ruleset2, rule1, rule2, unNumbered, rightHandSide1, rightHandSide2, rightHandSide3, sumset1, sumset2, grammarSymbol1, grammarSymbol2, nonterminal, terminal, nil]];
    CPParser *parser = [CPSLRParser parserWithGrammar:bnfGrammar];
    [parser setDelegate:del];
    
    NSArray *initRules = [parser parse:tokenStream];
    return [self initWithStart:initStart rules:initRules];
}

- (id)init
{
    return [self initWithStart:nil rules:[NSArray array]];
}

- (void)dealloc
{
    [start release];
    
    [super dealloc];
}

- (NSSet *)allRules
{
        return [NSSet setWithArray:[self rules]];
}

- (NSArray *)allNonTerminalNames
{
    return [[self rulesByNonTerminal] allKeys];
}

- (void)addRule:(CPRule *)rule
{
    NSMutableDictionary *rs = [self rulesByNonTerminal];
    NSMutableArray *arr = [rs objectForKey:[rule name]];
    if (nil == arr)
    {
        arr = [NSMutableArray array];
        [rs setObject:arr forKey:[rule name]];
    }
    [arr addObject:rule];
}

- (NSArray *)rulesForNonTerminalWithName:(NSString *)nonTerminal
{
    return [[self rulesByNonTerminal] objectForKey:nonTerminal];
}

- (NSUInteger)hash
{
    return [[self start] hash] << 16 + [[self rules] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPGrammar class]])
    {
        CPGrammar *other = (CPGrammar *)object;
        return [[other start] isEqualToString:[self start]] && [[other rules] isEqualToArray:[self rules]];
    }
    
    return NO;
}

@end
