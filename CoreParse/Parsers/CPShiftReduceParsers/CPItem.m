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
        [self setRule:initRule];
        [self setPosition:initPosition];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CPItem allocWithZone:zone] initWithRule:[self rule] position:[self position]];
}

- (void)dealloc
{
    [rule release];
    
    [super dealloc];
}

- (CPGrammarSymbol *)nextSymbol
{
    NSArray *rse = [rule rightHandSideElements];
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
    NSArray *rse = [rule rightHandSideElements];
    return [rse subarrayWithRange:NSMakeRange(position, [rse count] - position)];
}

- (id)itemByMovingDotRight
{
    CPItem *c = [self copy];
    [c setPosition:[self position] + 1];
    return [c autorelease];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPItem class]])
    {
        CPItem *other = (CPItem *)object;
        return [other rule] == [self rule] && [other position] == [self position];
    }
    return NO;
}

- (NSUInteger)hash
{
    return [[self rule] hash] + position;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ ::= ", [[self rule] name]];
    NSUInteger pos = 0;
    NSArray *rse = [[self rule] rightHandSideElements];
    for (NSObject *obj in rse)
    {
        if (pos == [self position])
        {
            [desc appendString:@"• "];
        }
        [desc appendFormat:@"%@ ", obj];
        pos++;
    }
    if (pos == [self position])
    {
        [desc appendString:@"•"];
    }
    return desc;
}

@end
