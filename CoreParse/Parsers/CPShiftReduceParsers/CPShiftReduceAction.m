//
//  CPShiftReduceAction.m
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPShiftReduceAction.h"

#import "CPGrammarInternal.h"

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

- (NSUInteger)hash
{
    return type;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPShiftReduceAction class]] && ((CPShiftReduceAction *)object)->type == type)
    {
        CPShiftReduceAction *other = (CPShiftReduceAction *)object;
        switch (type)
        {
            case kActionTypeShift:
                return [other newState] == details.shift;
            case kActionTypeReduce:
                return [other reductionRule] == details.reductionRule;
            case kActionTypeAccept:
                return YES;
        }
    }
    
    return NO;
}

- (NSString *)description
{
    switch (type)
    {
        case kActionTypeShift:
            return [NSString stringWithFormat:@"s%d", details.shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%@", [details.reductionRule name]];
        case kActionTypeAccept:
            return @"acc";
    }
}

- (NSString *)descriptionWithGrammar:(CPGrammar *)g
{
    switch (type)
    {
        case kActionTypeShift:
            return [NSString stringWithFormat:@"s%d", details.shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%d", [g indexOfRule:details.reductionRule]];
        case kActionTypeAccept:
            return @"acc";
    }
}


@end
