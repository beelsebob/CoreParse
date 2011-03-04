//
//  Parser.h
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPGrammar.h"

#import "CPTokenStream.h"

@interface CPParser : NSObject
{}

+ (id)parserWithGrammar:(CPGrammar *)grammar;
- (id)initWithGrammar:(CPGrammar *)grammar;

- (id)parse:(CPTokenStream *)tokenStream;

@end
