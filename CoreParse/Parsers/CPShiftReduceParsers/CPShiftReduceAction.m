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

@interface ActionDetails: NSObject

@property (nonatomic, strong) CPRule *reductionRule;
@property (nonatomic, assign) NSUInteger shift;

@end

@implementation ActionDetails

@end

@interface CPShiftReduceAction ()

@property (nonatomic, strong) ActionDetails *details;
@property (nonatomic, assign) ActionType type;

@end

@implementation CPShiftReduceAction

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
    self = [self init];
    
    if (nil != self)
    {
        _type = kActionTypeShift;
        _details.shift = shiftLocation;
    }
    
    return self;
}

- (id)initWithReductionRule:(CPRule *)reduction
{
    self = [self init];
    
    if (nil != self)
    {
        _type = kActionTypeReduce;
        _details.reductionRule = reduction;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        _details = [[ActionDetails alloc] init];
        _type = kActionTypeAccept;
    }
    
    return self;
}

#define CPShiftReduceActionTypeKey  @"t"
#define CPShiftReduceActionShiftKey @"s"
#define CPShiftReduceActionRuleKey  @"r"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (nil != self)
    {
        _type = [aDecoder decodeIntForKey:CPShiftReduceActionTypeKey];
        switch (_type)
        {
            case kActionTypeShift:
                _details.shift = [aDecoder decodeIntegerForKey:CPShiftReduceActionShiftKey];
                break;
            case kActionTypeReduce:
                _details.reductionRule = [aDecoder decodeObjectForKey:CPShiftReduceActionRuleKey];
            case kActionTypeAccept:
            default:
                break;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_type forKey:CPShiftReduceActionTypeKey];
    switch (_type)
    {
        case kActionTypeShift:
            [aCoder encodeInteger:_details.shift forKey:CPShiftReduceActionShiftKey];
            break;
        case kActionTypeReduce:
            [aCoder encodeObject:_details.reductionRule forKey:CPShiftReduceActionRuleKey];
        case kActionTypeAccept:
        default:
            break;
    }
}

- (BOOL)isShiftAction
{
    return kActionTypeShift == _type;
}

- (BOOL)isReduceAction
{
    return kActionTypeReduce == _type;
}

- (BOOL)isAccept
{
    return kActionTypeAccept == _type;
}

- (NSUInteger)newState
{
    return _details.shift;
}

- (CPRule *)reductionRule
{
    return _details.reductionRule;
}

- (NSUInteger)hash
{
    return _type;
}

- (BOOL)isShiftReduceAction
{
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if ([object isShiftReduceAction] && ((CPShiftReduceAction *)object).type == _type)
    {
        CPShiftReduceAction *other = (CPShiftReduceAction *)object;
        switch (_type)
        {
            case kActionTypeShift:
                return [other newState] == _details.shift;
            case kActionTypeReduce:
                return [other reductionRule] == _details.reductionRule;
            case kActionTypeAccept:
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)isEqualToShiftReduceAction:(CPShiftReduceAction *)object
{
    if (object != nil && object.type == _type)
    {
        switch (_type)
        {
            case kActionTypeShift:
                return [object newState] == _details.shift;
            case kActionTypeReduce:
                return [object reductionRule] == _details.reductionRule;
            case kActionTypeAccept:
                return YES;
        }
    }
    
    return NO;
}

- (NSString *)description
{
    switch (_type)
    {
        case kActionTypeShift:
            return [NSString stringWithFormat:@"s%ld", (long)_details.shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%@", [_details.reductionRule name]];
        case kActionTypeAccept:
            return @"acc";
    }
}

- (NSString *)descriptionWithGrammar:(CPGrammar *)g
{
    switch (_type)
    {
        case kActionTypeShift:
            return [NSString stringWithFormat:@"s%ld", (long)_details.shift];
        case kActionTypeReduce:
            return [NSString stringWithFormat:@"r%ld", (long)[g indexOfRule:_details.reductionRule]];
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
