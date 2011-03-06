//
//  Parser.h
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammar.h"
#import "CPSyntaxTree.h"

#import "CPTokenStream.h"

@class CPParser;

@protocol CPParserDelegate <NSObject>

- (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree;

@end

@interface CPParser : NSObject
{}

@property (readwrite,assign) id<CPParserDelegate> delegate;
@property (readonly,retain) CPGrammar *grammar;

+ (id)parserWithGrammar:(CPGrammar *)grammar;
- (id)initWithGrammar:(CPGrammar *)grammar;

- (id)parse:(CPTokenStream *)tokenStream;

@end
