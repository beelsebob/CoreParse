//
//  CPShiftReduceAction.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceAction.h"

typedef enum
{
    kActionTypeShift = 0,
    kActionTypeReduce   ,
    kActionTypeAccept
} ActionType;

typedef union
{
    NSUInteger shift;
    CPRule *reductionRule;
}
ActionDetails;

@implementation CPShiftReduceAction
{
    ActionType type;
    ActionDetails details;
}

+ (id)shiftAction:(NSUInteger)shiftLocation
{
    return [[[self alloc] initWithShift:shiftLocation] autorelease];
}

+ (id)reduceAction:(CPRule *)reduction
{
    return [[[self alloc] initWithReductionRule:reduction] autorelease];
}

+ (id)acceptAction
{
    return [[[self alloc] init] autorelease];
}

- (id)initWithShift:(NSUInteger)shiftLocation
{
    self = [super init];
    
    if (nil != self)
    {
        type = kActionTypeShift;
        details.shift = shiftLocation;
    }
    
    return self;
}

- (id)initWithReductionRule:(CPRule *)reduction
{
    self = [super init];
    
    if (nil != self)
    {
        type = kActionTypeReduce;
        details.reductionRule = [reduction retain];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        type = kActionTypeAccept;
    }
    
    return self;
}

- (void)dealloc
{
    if (kActionTypeReduce == type)
    {
        [details.reductionRule release];
    }
    
    [super dealloc];
}

- (BOOL)isShiftAction
{
    return kActionTypeShift == type;
}

- (BOOL)isReduceAction
{
    return kActionTypeReduce == type;
}

- (BOOL)isAccept
{
    return kActionTypeAccept == type;
}

- (NSUInteger)newState
{
    return details.shift;
}

- (CPRule *)reductionRule
{
    return details.reductionRule;
}

@end
