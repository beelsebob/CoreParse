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
@synthesize representitiveClass;

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

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements representitiveClass:(Class)representitiveClass
{
    return [[[self alloc] initWithName:name rightHandSideElements:rightHandSideElements representitiveClass:representitiveClass] autorelease];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements representitiveClass:(Class)initRepresentitiveClass
{
    self = [super init];
    
    if (nil != self)
    {
        [self setName:initName];
        [self setRightHandSideElements:rightHandSideElements];
        [self setTag:0];
        [self setRepresentitiveClass:initRepresentitiveClass];
    }
    
    return self;
}

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)tag
{
    return [[[self alloc] initWithName:name rightHandSideElements:rightHandSideElements tag:tag] autorelease];
}

- (id)initWithName:(NSString *)initName rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)initTag
{
    self = [self initWithName:initName rightHandSideElements:rightHandSideElements representitiveClass:nil];
    
    if (nil != self)
    {
        [self setTag:initTag];
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

#define CPRuleTagKey                 @"t"
#define CPRuleNameKey                @"n"
#define CPRuleRHSElementsKey         @"r"
#define CPRuleRepresentitiveClassKey @"c"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTag:[aDecoder decodeIntegerForKey:CPRuleTagKey]];
        [self setName:[aDecoder decodeObjectForKey:CPRuleNameKey]];
        [self setRightHandSideElements:[aDecoder decodeObjectForKey:CPRuleRHSElementsKey]];
        [self setRepresentitiveClass:NSClassFromString([aDecoder decodeObjectForKey:CPRuleRepresentitiveClassKey])];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:[self tag] forKey:CPRuleTagKey];
    [aCoder encodeObject:[self name] forKey:CPRuleNameKey];
    [aCoder encodeObject:[self rightHandSideElements] forKey:CPRuleRHSElementsKey];
    [aCoder encodeObject:NSStringFromClass([self representitiveClass]) forKey:CPRuleRepresentitiveClassKey];
}

- (void)dealloc
{
    [name release];
    [rightHandSide release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ ::= %@", [self name], [[rightHandSide valueForKey:@"description"] componentsJoinedByString:@" "]];
}

- (NSUInteger)hash
{
    return [name hash] << 16 + [self tag] ;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPRule class]])
    {
        CPRule *other = (CPRule *)object;
        return [other tag] == tag && [[other name] isEqualToString:name] && [[other rightHandSideElements] isEqualToArray:rightHandSide];
    }
    
    return NO;
}

@end
