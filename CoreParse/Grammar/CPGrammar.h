//
//  Grammar.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPNonTerminal.h"

@interface CPGrammar : NSObject
{}

@property (readwrite,retain) CPNonTerminal *start;

+ (id)grammarWithStart:(CPNonTerminal *)start;
- (id)initWithStart:(CPNonTerminal *)start;

@end
