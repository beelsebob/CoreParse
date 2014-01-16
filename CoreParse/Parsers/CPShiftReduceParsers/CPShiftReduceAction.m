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

@implementation CPShiftReduceAction
{
    ActionType type;
    NSUInteger shift;
    CPRule *reductionRule;
}

+ (id)shiftAction:(NSUInteger)shiftLocation
{
    return [[self alloc] initWithShift:shiftLocation];
}

+ (id)reduceAction:(CPRule *)reduction
{
    return [[self alloc] initWithReductionRule:reduction];
}

+ (id)acceptAction
{
    return [[self alloc] init];
}

- (id)initWithShift:(NSUInteger)shiftLocation
{
    self = [super init];
    
    if (nil != self)
    {
        type = kActionTypeShift;
        shift = shiftLocation;
    }
    
    return self;
}

- (id)initWithReductionRule:(CPRule *)reduction
{
    self = [super init];
    
    if (nil != self)
    {
        type = kActionTypeReduce;
        reductionRule = reduction;
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

#define CPShiftReduceActionTypeKey  @"t"
#define CPShiftReduceActionShiftKey @"s"
#define CPShiftReduceActionRuleKey  @"r"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        type = [aDecoder decodeIntForKey:CPShiftReduceActionTypeKey];
        switch (type)
        {
            case kActionTypeShift:
                shift = [aDecoder decodeIntegerForKey:CPShiftReduceActionShiftKey];
                break;
            case kActionTypeReduce:
                reductionRule = [aDecoder decodeObjectForKey:CPShiftReduceActionRuleKey];
            case kActionTypeAccept:
            default:
                break;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:type forKey:CPShiftReduceActionTypeKey];
    switch (type)
    {
        case kActionTypeShift:
            [aCoder encodeInteger:shift forKey:CPShiftReduceActionShiftKey];
            break;
        case kActionTypeReduce:
            [aCoder encodeObject:reductionRule forKey:CPShiftReduceActionRuleKey];
        case kActionTypeAccept:
        default:
            break;
    }
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
    return shift;
}

- (CPRule *)reductionRule
{
    return reductionRule;
}

- (NSUInteger)hash
{
    return type;
}

- (BOOL)isShiftReduceAction
{
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if ([object isShiftReduceAction] && ((CPShiftReduceAction *)object)->type == type)
    {
        CPShiftReduceAction *other = (CPShiftReduceAction *)object;
        switch (type)
        {
            case kActionTypeShift:
                return [other newState] == shift;
            case kActionTypeReduce:
                return [other reductionRule] == reductionRule;
            case kActionTypeAccept:
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)isEqualToShiftReduceAction:(CPShiftReduceAction *)object
{
    if (object != nil && object->type == type)
    {
        switch (type)
        {
            case kActionTypeShift:
                return [object newState] == shift;
            case kActionTypeReduce:
                return [object reductionRule] == reductionRule;
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
            return [NSString stringWithFormat:@"s%ld", (long)shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%@", [reductionRule name]];
        case kActionTypeAccept:
            return @"acc";
    }
}

- (NSString *)descriptionWithGrammar:(CPGrammar *)g
{
    switch (type)
    {
        case kActionTypeShift:
            return [NSString stringWithFormat:@"s%ld", (long)shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%ld", (long)[g indexOfRule:reductionRule]];
        case kActionTypeAccept:
            return @"acc";
    }
}

@end

@implementation NSObject(CPIsShiftReduceAction)

- (BOOL)isShiftReduceAction
{
    return NO;
}

@end
