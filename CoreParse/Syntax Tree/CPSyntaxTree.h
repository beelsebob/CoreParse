//
//  CPSyntaxTree.h
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPRule.h"

/**
 * The CPSyntaxTree class represents a node in a syntax tree.
 * 
 * Syntax trees carry the rule that was matched to create the tree and the child elements that in order match up with the right hand side of the rule.
 */
@interface CPSyntaxTree : NSObject

///---------------------------------------------------------------------------------------
/// @name Creating and Initialising a Syntax Tree
///---------------------------------------------------------------------------------------

/**
 * Creates a syntax tree based on a rule and some child trees.
 *
 * @param nonTerminal The rule that was matched to create this tree node.
 * @param children    The child trees that represent the components of the right hand side of the rule.
 * @return Returns a syntax tree with apropriate children, and matching a specified rule.
 *
 * @see initWithRule:children:
 */
+ (id)syntaxTreeWithRule:(CPRule *)nonTerminal children:(NSArray *)children;

/**
 * Initialises a syntax tree based on a rule and some child trees.
 *
 * @param nonTerminal The rule that was matched to create this tree node.
 * @param children    The child trees that represent the components of the right hand side of the rule.
 * @return Returns a syntax tree with apropriate children, and matching a specified rule.
 *
 * @see syntaxTreeWithRule:children:
 */
- (id)initWithRule:(CPRule *)nonTerminal children:(NSArray *)children;

///---------------------------------------------------------------------------------------
/// @name Configuring a Syntax Tree
///---------------------------------------------------------------------------------------

/**
 * The rule matched to create this syntax tree.
 */
@property (readonly,retain) CPRule *rule;

/**
 * The children that match the right hand side of the matched rule.
 */
@property (readonly,copy) NSArray *children;

@end
