//
//  CPRHSItem.m
//  CoreParse
//
//  Created by Thomas Davie on 26/06/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPRHSItem.h"

#import "CPRHSItem+Private.h"
#import "CPGrammar.h"

@implementation CPRHSItem

@synthesize alternatives = _alternatives;
@synthesize repeats = _repeats;
@synthesize mayNotExist = _mayNotExist;
@synthesize tag = _tag;
@synthesize shouldCollapse = _shouldCollapse;

- (NSUInteger)hash
{
    return [[self alternatives] hash] << 2 + ([self repeats] ? 0x2 : 0x0) + ([self mayNotExist] ? 0x1 : 0x0);
}

- (BOOL)isRHSItem
{
    return YES;
}

- (BOOL)isEqual:(id)object
{
    return ([object isRHSItem] &&
            [[self alternatives] isEqualToArray:[object alternatives]] &&
            [self repeats] == [object repeats] &&
            [self mayNotExist] == [object mayNotExist] &&
            [self shouldCollapse] == [object shouldCollapse] &&
            (([self tag] == nil && [(CPRHSItem *)object tag] == nil) ||
             [[self tag] isEqualToString:[(CPRHSItem *)object tag]]));
}

- (id)copyWithZone:(NSZone *)zone
{
    CPRHSItem *other = [[CPRHSItem allocWithZone:zone] init];
    [other setAlternatives:[self alternatives]];
    [other setRepeats:[self repeats]];
    [other setMayNotExist:[self mayNotExist]];
    [other setTag:[self tag]];
    [other setShouldCollapse:[self shouldCollapse]];
    return other;
}

- (void)dealloc
{
    [_alternatives release];
    [_tag release];
    
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    if ([[self alternatives] count] != 1 || [[[self alternatives] objectAtIndex:0] count] != 1)
    {
        [desc appendString:@"("];
    }
    NSUInteger i = 0;
    for (NSArray *components in [self alternatives])
    {
        i++;
        NSUInteger j = 0;
        for (id comp in components)
        {
            j++;
            if (j != [components count])
            {
                [desc appendFormat:@"%@ ", comp];
            }
            else
            {
                [desc appendFormat:@"%@", comp];
            }
        }
        
        if (i != [[self alternatives] count])
        {
            [desc appendString:@"| "];
        }
    }
    if ([[self alternatives] count] != 1 || [[[self alternatives] objectAtIndex:0] count] != 1)
    {
        [desc appendString:@")"];
    }
    [desc appendString:[self repeats] ? ([self mayNotExist] ? @"*" : @"+") : ([self mayNotExist] ? @"?" : @"")];
    return desc;
}

@end

@implementation CPRHSItem (Private)

- (NSSet *)tagNamesWithError:(NSError **)err
{
    NSMutableSet *tagNames = [NSMutableSet set];
    
    for (NSArray *components in [self alternatives])
    {
        NSMutableSet *tagNamesInAlternative = [NSMutableSet set];
        for (id comp in components)
        {
            if ([comp isRHSItem])
            {
                NSSet *newTagNames = [(CPRHSItem *)comp tagNamesWithError:err];
                if (nil != *err)
                {
                    return nil;
                }
                NSMutableSet *duplicateTags = [[tagNamesInAlternative mutableCopy] autorelease];
                [duplicateTags intersectSet:newTagNames];
                if ([duplicateTags count] > 0)
                {
                    if (NULL != err)
                    {
                        *err = [NSError errorWithDomain:CPEBNFParserErrorDomain
                                                   code:CPErrorCodeDuplicateTag
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSString stringWithFormat:@"Duplicate tag names %@ in same part of alternative is not allowed in \"%@\".", duplicateTags, self], NSLocalizedDescriptionKey,
                                                         nil]];
                    }
                    return nil;
                }
                [tagNamesInAlternative unionSet:newTagNames];
                NSString *tagName = [(CPRHSItem *)comp tag];
                if (nil != tagName)
                {
                    if ([tagNamesInAlternative containsObject:tagName])
                    {
                        if (NULL != err)
                        {
                            *err = [NSError errorWithDomain:CPEBNFParserErrorDomain
                                                       code:CPErrorCodeDuplicateTag
                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSString stringWithFormat:@"Duplicate tag names (%@) in same part of alternative is not allowed in \"%@\".", tagName, self], NSLocalizedDescriptionKey,
                                                             nil]];
                        }
                        return nil;
                    }
                    [tagNamesInAlternative addObject:tagName];
                }
            }
        }
        [tagNames unionSet:tagNamesInAlternative];
    }
    
    if ([tagNames count] > 0 && [self repeats])
    {
        if (NULL != err)
        {
            *err = [NSError errorWithDomain:CPEBNFParserErrorDomain
                                       code:CPErrorCodeDuplicateTag
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"Tag names are not allowed within repeating section of rule \"%@\".", self], NSLocalizedDescriptionKey,
                                             nil]];
        }
        return nil;
    }
    
    return tagNames;
}

@end

@implementation NSObject (CPIsRHSItem)

- (BOOL)isRHSItem
{
    return NO;
}

@end
