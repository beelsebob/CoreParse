//
//  Production.m
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPNonTerminal.h"

@implementation CPNonTerminal
{
    NSMutableArray *rightHandSide;
}

@synthesize name;

- (NSArray *)rightHandSideElements
{
    return [[rightHandSide retain] autorelease];
}

- (void)setRightHandSideElements:(NSArray *)rightHandSideElements
{
    @synchronized(self)
    {
        if (rightHandSide != rightHandSideElements)
        {
            [rightHandSide release];
            rightHandSide = [rightHandSideElements mutableCopy];
        }
    }
}

+ (id)nonTerminalWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements
{
    return [[[CPNonTerminal alloc] initWithName:name rightHandSideElements:rightHandSideElements] autorelease];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements
{
    self = [super init];
    
    if (nil != self)
    {
        self.name = initName;
        self.rightHandSideElements = rightHandSideElements;
    }
    
    return self;
}

- (id)init
{
    return [self initWithName:@"" rightHandSideElements:[NSArray array]];
}

- (void)dealloc
{
    [name release];
    [rightHandSide release];
    
    [super dealloc];
}

@end
