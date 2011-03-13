//
//  CPRule.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRule.h"

#import "CPGrammarSymbol.h"

@implementation CPRule
{
    NSMutableArray *rightHandSide;
}

@synthesize name;
@synthesize tag;

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

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)tag
{
    return [[[self alloc] initWithName:name rightHandSideElements:rightHandSideElements tag:tag] autorelease];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)initTag
{
    self = [super init];
    
    if (nil != self)
    {
        self.name = initName;
        self.rightHandSideElements = rightHandSideElements;
        self.tag = initTag;
    }
    
    return self;
}

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements
{
    return [[[CPRule alloc] initWithName:name rightHandSideElements:rightHandSideElements] autorelease];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements
{
    return [self initWithName:initName rightHandSideElements:rightHandSideElements tag:0];
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

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ ::= ", self.name];
    for (CPGrammarSymbol *s in rightHandSide)
    {
        [desc appendFormat:@"%@ ", s];
    }
    return desc;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPRule class]])
    {
        CPRule *other = (CPRule *)object;
        BOOL tagsEqual = other.tag == self.tag;
        BOOL namesEqual = [other.name isEqualToString:self.name];
        BOOL rightHandSideElementsEqual = [other.rightHandSideElements isEqualToArray:self.rightHandSideElements];
        return tagsEqual && namesEqual && rightHandSideElementsEqual;
    }
    
    return NO;
}

@end
