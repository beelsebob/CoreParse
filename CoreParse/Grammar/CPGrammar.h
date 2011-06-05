//
//  Grammar.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammarSymbol.h"
#import "CPRule.h"

/**
 * The CPGrammar class represents a context free grammar.  Grammars can be used later to construct parsers.
 */
@interface CPGrammar : NSObject

///---------------------------------------------------------------------------------------
/// @name Creating and Initialising a Grammar
///---------------------------------------------------------------------------------------

/**
 * Creates a grammar based on a starting non-terminal and a list of rules.
 *
 * @param start The non-terminal that all parses must reduce to.
 * @param rules An array of CPRules to describe the grammar.
 * @return Returns a CPGrammar based on the rules and starting non-terminal.
 *
 * @see initWithStart:rules:
 * @see grammarWithStart:backusNaurForm:
 */
+ (id)grammarWithStart:(NSString *)start rules:(NSArray *)rules;

/**
 * Creates a grammar based on a starting non-terminal and some backus naur form.
 *
 * see initWithStart:backusNaurForm: for a description of the syntax used for BNF.
 * 
 * @param start The non-terminal that all parses must reduce to.
 * @param bnf   BNF for the grammar.
 * @return Returns a CPGrammar based on the BNF and starting non-terminal.
 *
 * @see grammarWithStart:backusNaurForm:
 * @see initWithStart:backusNaurForm:
 */
+ (id)grammarWithStart:(NSString *)start backusNaurForm:(NSString *)bnf;

/**
 * Initialises a grammar based on a starting non-terminal and a list of rules.
 *
 * @param start The non-terminal that all parses must reduce to.
 * @param rules An array of CPRules to describe the grammar.
 * @return Returns a CPGrammar based on the rules and starting non-terminal.
 *
 * @see grammarWithStart:rules:
 * @see initWithStart:backusNaurForm:
 */
- (id)initWithStart:(NSString *)start rules:(NSArray *)rules;

/**
 * Initialises a grammar based on a starting non-terminal and some backus naur form.
 *
 * The BNF is expressed using rules in the form `nonTerminal ::= <subNonTerminal> "subTerminal" <subNonTerminal>;`.  Rules may optionally be prefixed with a number indicating their tag.
 * This allows you to quickly construct grammars in a readable form.
 *
 * The grammar used for parsing the BNF can be expressed as follows:
 * 
 * <code>
 * 0  ruleset       ::= &lt;ruleset&gt; &lt;rule&gt;;<br />
 * 1  ruleset       ::= &lt;rule&gt;;
 * 
 * 2  rule          ::= "Number" &lt;unNumbered&gt;;<br />
 * 3  rule          ::= &lt;unNumbered&gt;;
 * 
 * 4  unNumbered    ::= "Identifier" "::=" &lt;rightHandSide&gt; ";";
 * 
 * 5  rightHandSide ::= &lt;rightHandSide> "|" &lt;sumset&gt;;<br />
 * 6  rightHandSide ::= &lt;rightHandSide> "|";<br />
 * 7  rightHandSide ::= &lt;sumset>;
 * 
 * 8  sumset        ::= &lt;sumset&gt; &lt;grammarSymbol&gt;;<br />
 * 9  sumset        ::= &lt;grammarSymbol&gt;;
 * 
 * 10 grammarSymbol ::= &lt;nonTerminal&gt;;<br />
 * 11 grammarSymbol ::= &lt;terminal&gt;;
 * 
 * 12 nonTerminal   ::= "&lt;" "Identifier" "&gt;";<br />
 * 13 terminal      ::= String;
 * </code>
 * 
 * @param start The non-terminal that all parses must reduce to.
 * @param bnf   BNF for the grammar.
 * @return Returns a CPGrammar based on the BNF and starting non-terminal.
 *
 * @see initWithStart:rules:
 * @see grammarWithStart:backusNaurForm:
 */
- (id)initWithStart:(NSString *)start backusNaurForm:(NSString *)bnf;

///---------------------------------------------------------------------------------------
/// @name Configuring a Grammar
///---------------------------------------------------------------------------------------

/**
 * The set of rules in the grammar.
 * 
 * @return Returns the set of rules used to describe the grammar.
 */
- (NSSet *)allRules;

/**
 * Adds a rule to the grammar.
 * 
 * @param rule The rule to add.
 */
- (void)addRule:(CPRule *)rule;

///---------------------------------------------------------------------------------------
/// @name Retreiving Grammar Rules
///---------------------------------------------------------------------------------------

/**
 * All the non-terminals that the grammar can expand.
 *
 * @return An array of non-terminal names that are explained by the grammar.
 */
- (NSArray *)allNonTerminalNames;

/**
 * The rules relevant when attempting to match a non-terminal.
 *
 * @param nonTerminalName The name of the non-terminal to find rules to match.
 * @return Returns all rules that match a particular non-terminal.
 */
- (NSArray *)rulesForNonTerminalWithName:(NSString *)nonTerminalName;

/**
 * The starting symbol for the grammar.
 */
@property (readwrite,retain) NSString *start;

@end
