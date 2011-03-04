//
//  Grammar.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NonTerminal.h"

@interface Grammar : NSObject
{}

@property (readwrite,retain) NonTerminal *start;

+ (id)grammarWithStart:(NonTerminal *)start;
- (id)initWithStart:(NonTerminal *)start;

@end
