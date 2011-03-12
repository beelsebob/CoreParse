//
//  CPItem.m
//  CoreParse
//
//  Created by Tom Davie on 06/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPItem.h"

@interface CPItem ()

@property (readwrite,retain) CPRule *rule;
@property (readwrite,assign) NSUInteger position;

@end

@implementation CPItem

@synthesize rule;
@synthesize position;

+ (id)itemWithRule:(CPRule *)rule position:(NSUInteger)position
{
    return [[[self alloc] initWithRule:rule position:position] autorelease];
}

- (id)initWithRule:(CPRule *)initRule position:(NSUInteger)initPosition
{
    self = [super init];
    
    if (nil != self)
    {
        self.rule = initRule;
        self.position = initPosition;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CPItem allocWithZone:zone] initWithRule:self.rule position:self.position];
}

- (void)dealloc
{
    [rule release];
    
    [super dealloc];
}

- (id)nextSymbol
{
    NSArray *rse = rule.rightHandSideElements;
    if (position >= [rse count])
    {
        return nil;
    }
    else
    {
        return [rse objectAtIndex:position];
    }
}

- (NSArray *)followingSymbols
{
    NSArray *rse = rule.rightHandSideElements;
    return [rse subarrayWithRange:NSMakeRange(position, [rse count] - position)];
}

- (id)itemByMovingDotRight
{
    CPItem *c = [self copy];
    c.position = self.position + 1;
    return [c autorelease];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CPItem class]] && ((CPItem *)object).rule == self.rule && ((CPItem *)object).position == self.position;
}

- (NSUInteger)hash
{
    return [self.rule hash] + position;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ ::= ", self.rule.name];
    NSUInteger pos = 0;
    for (NSObject *obj in self.rule.rightHandSideElements)
    {
        if (pos == self.position)
        {
            [desc appendFormat:@"• "];
        }
        [desc appendFormat:@"%@ ", obj];
        pos++;
    }
    if (pos == self.position)
    {
        [desc appendFormat:@"•"];
    }
    return desc;
}

@end
