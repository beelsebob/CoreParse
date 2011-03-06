//
//  CPSyntaxTree.h
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPRule.h"

@interface CPSyntaxTree : NSObject
{}

@property (readonly,retain) CPRule *rule;
@property (readonly,copy) NSArray *children;

+ (id)syntaxTreeWithRule:(CPRule *)nonTerminal children:(NSArray *)children;
- (id)initWithRule:(CPRule *)nonTerminal children:(NSArray *)children;

@end
