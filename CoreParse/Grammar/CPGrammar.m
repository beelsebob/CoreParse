//
//  Grammar.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammar.h"
#import "CPTerminal.h"

#import "CPTokeniser.h"
#import "CPTokenStream.h"
#import "CPKeywordRecogniser.h"
#import "CPNumberRecogniser.h"
#import "CPWhiteSpaceRecogniser.h"
#import "CPQuotedRecogniser.h"
#import "CPIdentifierRecogniser.h"
#import "CPSLRParser.h"
#import "CPIdentifierToken.h"
#import "CPQuotedToken.h"
#import "CPNumberToken.h"

@interface CPBNFParserDelegate : NSObject <CPParserDelegate>
{}
@end

@implementation CPBNFParserDelegate

- (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
{
    NSArray *children = syntaxTree.children;
    switch (syntaxTree.rule.tag)
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
                r.tag = [[(CPNumberToken *)[children objectAtIndex:0] number] intValue];
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
            return [CPNonTerminal nonTerminalWithName:[(CPIdentifierToken *)[children objectAtIndex:1] identifier]];
        case 13:
            return [CPTerminal terminalWithTokenName:[(CPQuotedToken *)[children objectAtIndex:0] content]];
        default:
            return syntaxTree;
    }
}

@end

@interface CPGrammar ()

@property (readwrite,copy) NSArray *rules;

- (NSSet *)firstSymbol:(NSObject *)obj;

@end

@implementation CPGrammar
{
    NSMutableDictionary *rules;
}

@synthesize start;

- (NSArray *)rules
{
    __block NSMutableArray *rs = [NSMutableArray arrayWithCapacity:[rules count]];
    
    [[rules allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [rs addObjectsFromArray:obj];
     }];
    
    return rs;
}

- (void)setRules:(NSArray *)newRules
{
    @synchronized(self)
    {
        [rules release];
        rules = [[NSMutableDictionary dictionaryWithCapacity:[newRules count]] retain];
        
        [newRules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             [self addRule:obj];
         }];
    }
}

+ (id)grammarWithStart:(NSString *)start rules:(NSArray *)rules
{
    return [[[self alloc] initWithStart:start rules:rules] autorelease];
}

- (id)initWithStart:(NSString *)initStart rules:(NSArray *)initRules;
{
    self = [super init];
    
    if (nil != self)
    {
        self.start = [CPNonTerminal nonTerminalWithName:initStart];
        self.rules = initRules;
    }
    
    return self;
}

+ (id)grammarWithStart:(NSString *)start bnf:(NSString *)bnf
{
    return [[[self alloc] initWithStart:start bnf:bnf] autorelease];
}

- (id)initWithStart:(NSString *)initStart bnf:(NSString *)bnf
{
    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"::="]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"<"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@">"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"|"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@";"]];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" escapedEndQuote:@"\\\"" escapedEscape:@"\\\\" tokenName:@"String"]];
    [tokeniser addTokenRecogniser:[CPIdentifierRecogniser identifierRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    CPTokenStream *tokenStream = [tokeniser tokenise:bnf];
    [tokenStream setTokenRewriter:^ NSArray * (CPToken *token)
     {
         if ([token.name isEqualToString:@"Whitespace"])
         {
             return [NSArray array];
         }
         else
         {
             return [NSArray arrayWithObject:token];
         }
     }];
    
    CPRule *ruleset1 = [CPRule ruleWithName:@"ruleset" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"ruleset"], [CPNonTerminal nonTerminalWithName:@"rule"], nil] tag:0];
    CPRule *ruleset2 = [CPRule ruleWithName:@"ruleset" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"rule"], nil] tag:1];
    
    CPRule *rule1 = [CPRule ruleWithName:@"rule" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"Number"], [CPNonTerminal nonTerminalWithName:@"unNumbered"], nil] tag:2];
    CPRule *rule2 = [CPRule ruleWithName:@"rule" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"unNumbered"], nil] tag:3];
    
    CPRule *unNumbered = [CPRule ruleWithName:@"unNumbered" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"Identifier"], [CPTerminal terminalWithTokenName:@"::="], [CPNonTerminal nonTerminalWithName:@"rightHandSide"], [CPTerminal terminalWithTokenName:@";"], nil] tag:4];
    
    CPRule *rightHandSide1 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"rightHandSide"], [CPTerminal terminalWithTokenName:@"|"], [CPNonTerminal nonTerminalWithName:@"sumset"], nil] tag:5];
    CPRule *rightHandSide2 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"rightHandSide"], [CPTerminal terminalWithTokenName:@"|"], nil] tag:6];
    CPRule *rightHandSide3 = [CPRule ruleWithName:@"rightHandSide" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"sumset"], nil] tag:7];
    
    CPRule *sumset1 = [CPRule ruleWithName:@"sumset" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"sumset"], [CPNonTerminal nonTerminalWithName:@"grammarSymbol"], nil] tag:8];
    CPRule *sumset2 = [CPRule ruleWithName:@"sumset" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"grammarSymbol"], nil] tag:9];
    
    CPRule *grammarSymbol1 = [CPRule ruleWithName:@"grammarSymbol" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"nonterminal"], nil] tag:10];
    CPRule *grammarSymbol2 = [CPRule ruleWithName:@"grammarSymbol" rightHandSideElements:[NSArray arrayWithObjects:[CPNonTerminal nonTerminalWithName:@"terminal"], nil] tag:11];
    
    CPRule *nonterminal = [CPRule ruleWithName:@"nonterminal" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"<"], [CPTerminal terminalWithTokenName:@"Identifier"], [CPTerminal terminalWithTokenName:@">"], nil] tag:12];
    
    CPRule *terminal = [CPRule ruleWithName:@"terminal" rightHandSideElements:[NSArray arrayWithObjects:[CPTerminal terminalWithTokenName:@"String"], nil] tag:13];
    
    CPGrammar *bnfGrammar = [CPGrammar grammarWithStart:@"ruleset" rules:[NSArray arrayWithObjects:ruleset1, ruleset2, rule1, rule2, unNumbered, rightHandSide1, rightHandSide2, rightHandSide3, sumset1, sumset2, grammarSymbol1, grammarSymbol2, nonterminal, terminal, nil]];
    CPParser *parser = [CPSLRParser parserWithGrammar:bnfGrammar];
    parser.delegate = [[[CPBNFParserDelegate alloc] init] autorelease];
    
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
    [rules release];
    
    [super dealloc];
}

- (NSSet *)allRules
{
    NSMutableSet *rs = [NSMutableSet setWithCapacity:[rules count]];
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [rs addObjectsFromArray:obj];
     }];
    return rs;
}

- (NSArray *)orderedRules
{
    return [[[self allRules] allObjects] sortedArrayUsingComparator:^ NSComparisonResult (id obj1, id obj2)
            {
                CPRule *r1 = (CPRule *)obj1;
                CPRule *r2 = (CPRule *)obj2;
                NSComparisonResult t = r1.tag < r2.tag ? NSOrderedDescending : r1.tag > r2.tag ? NSOrderedAscending: NSOrderedSame;
                NSComparisonResult r = NSOrderedSame != t ? t : [[r1 name] compare:[r2 name]];
                return NSOrderedSame != r ? r : ([[r1 rightHandSideElements] count] < [[r2 rightHandSideElements] count] ? NSOrderedAscending : ([[r1 rightHandSideElements] count] > [[r2 rightHandSideElements] count] ? NSOrderedDescending : NSOrderedSame));
            }];
    
}

- (NSArray *)allNonTerminalNames
{
    NSMutableArray *nonTerminals = [NSMutableArray arrayWithCapacity:[rules count]];
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [nonTerminals addObject:key];
     }];
    return nonTerminals;
}

- (void)addRule:(CPRule *)rule
{
    NSMutableArray *arr = [rules objectForKey:rule.name];
    if (nil == arr)
    {
        arr = [NSMutableArray array];
        [rules setObject:arr forKey:rule.name];
    }
    [arr addObject:rule];
}

- (NSArray *)rulesForNonTerminal:(CPNonTerminal *)nonTerminal
{
    return [rules objectForKey:nonTerminal.name];
}

- (CPGrammar *)augmentedGrammar
{
    return [[[CPGrammar alloc] initWithStart:@"s'"
                                       rules:[self.rules arrayByAddingObject:[CPRule ruleWithName:@"s'" rightHandSideElements:[NSArray arrayWithObject:self.start]]]]
            autorelease];
}

- (NSUInteger)indexOfRule:(CPRule *)rule
{
    return [[self orderedRules] indexOfObject:rule];
}

- (NSString *)description
{
    NSArray *ordered = [self orderedRules];
    NSMutableString *s = [NSMutableString string];
    NSUInteger idx = 0;
    for (CPRule *r in ordered)
    {
        [s appendFormat:@"%3d %@\n", idx, r];
        idx++;
    }
    
    return s;
}

- (NSSet *)follow:(NSString *)name
{
    NSMutableSet *f = [NSMutableSet setWithObject:@"EOF"];
    [[self allRules] enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
     {
         CPRule *rule = (CPRule *)obj;
         NSArray *rightHandSide = [rule rightHandSideElements];
         NSUInteger numElements = [rightHandSide count];
         [rightHandSide enumerateObjectsUsingBlock:^(id rhsE, NSUInteger idx, BOOL *s)
          {
              if ([rhsE isKindOfClass:[CPNonTerminal class]] && [[(CPNonTerminal *)rhsE name] isEqualToString:name])
              {
                  if (idx + 1 < numElements)
                  {
                      NSSet *first = [self first:[rightHandSide subarrayWithRange:NSMakeRange(idx+1, [rightHandSide count] - idx - 1)]];
                      NSSet *firstMinusEmpty = [first objectsPassingTest:^ BOOL (id fobj, BOOL *fstop)
                                                {
                                                    return ![obj isEqual:@""];
                                                }];
                      [f unionSet:firstMinusEmpty];
                  }
                  else if (![[rule name] isEqualToString:name])
                  {
                      [f unionSet:[self follow:[rule name]]];
                  }
              }
          }];
     }];
    
    return f;
}

- (NSSet *)first:(NSArray *)symbols
{
    NSMutableSet *f = [NSMutableSet set];
    
    for (NSObject *symbol in symbols)
    {
        NSSet *f1 = [self firstSymbol:symbol];
        [f unionSet:f1];
        if (nil == [f1 member:@""])
        {
            break;
        }
    }
    
    return f;
}

- (NSSet *)firstSymbol:(NSObject *)obj
{
    if ([obj isKindOfClass:[CPTerminal class]])
    {
        return [NSSet setWithObject:[(CPTerminal *)obj tokenName]];
    }
    else
    {
        NSMutableSet *f = [NSMutableSet set];
        CPNonTerminal *nt = (CPNonTerminal *)obj;
        NSArray *rs = [self rulesForNonTerminal:nt];
        BOOL containsEmptyRightHandSide = NO;
        for (CPRule *rule in rs)
        {
            NSArray *rhs = [rule rightHandSideElements];
            NSUInteger numElements = [rhs count];
            if (numElements == 0)
            {
                containsEmptyRightHandSide = YES;
            }
            else
            {
                BOOL allCanBeEmpty = YES;
                for (NSUInteger element = 0; element < numElements && allCanBeEmpty; element++)
                {
                    NSObject *symbol = [rhs objectAtIndex:element];
                    if (![symbol isEqual:obj])
                    {
                        NSSet *f1 = [self firstSymbol:symbol];
                        [f unionSet:f1];
                        if (nil == [f1 member:@""])
                        {
                            allCanBeEmpty = NO;
                        }
                    }
                }
            }
        }
        if (containsEmptyRightHandSide)
        {
            [f addObject:@""];
        }
        return f;
    }
}

@end
