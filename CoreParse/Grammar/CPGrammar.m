//
//  Grammar.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammar.h"


@implementation CPGrammar

@synthesize start;

+ (id)grammarWithStart:(CPNonTerminal *)start
{
    return [[[CPGrammar alloc] initWithStart:start] autorelease];
}

- (id)initWithStart:(CPNonTerminal *)initStart
{
    self = [super init];
    
    if (nil != self)
    {
        self.start = initStart;
    }
    
    return self;
}

- (id)init
{
    return [self initWithStart:nil];
}

- (void)dealloc
{
    [start release];
    
    [super dealloc];
}

@end
