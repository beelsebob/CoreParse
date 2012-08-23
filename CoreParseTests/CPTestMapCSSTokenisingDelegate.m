//
//  CPTestMapCSSTokenisingDelegate.m
//  CoreParse
//
//  Created by Tom Davie on 15/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTestMapCSSTokenisingDelegate.h"

@implementation CPTestMapCSSTokenisingDelegate
{
    NSCharacterSet *symbolsSet;
    int nestingDepth;
    BOOL justTokenisedObject;
    BOOL inRange;
}

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        symbolsSet = [[NSCharacterSet characterSetWithCharactersInString:@"*[]{}().,;@|-!=<>:!"] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [symbolsSet release];
    
    [super dealloc];
}

- (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token
{
    NSString *name = [token name];
    if ([name isEqualToString:@"{"] || [name isEqualToString:@"["])
    {
        nestingDepth++;
    }
    else if ([name isEqualToString:@"}"] || [name isEqualToString:@"]"])
    {
        nestingDepth--;
    }
    else if ([name isEqualToString:@"|z"])
    {
        inRange = YES;
    }
    else if (inRange && ![token isNumberToken] && ![name isEqualToString:@"-"])
    {
        inRange = NO;
    }
    else if (inRange && [token isNumberToken])
    {
        return [[(CPNumberToken *)token number] floatValue] >= 0;
    }
    else if ([token isKeywordToken])
    {
        return 0 == nestingDepth || [symbolsSet characterIsMember:[name characterAtIndex:0]] || [name isEqualToString:@"eval"] || [name isEqualToString:@"url"] || [name isEqualToString:@"set"] || [name isEqualToString:@"pt"] || [name isEqualToString:@"px"];
    }
    
    return YES;
}

- (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token
{
    NSString *name = [token name];
    if ([token isWhiteSpaceToken])
    {
        if (justTokenisedObject)
        {
            return [NSArray arrayWithObject:token];
        }
        else
        {
            return [NSArray array];
        }
    }
    
    justTokenisedObject = NO;
    if ([name isEqualToString:@"Comment"])
    {
        return [NSArray array];
    }

    if ([name isEqualToString:@"node"] || [name isEqualToString:@"way" ] || [name isEqualToString:@"relation"] ||
        [name isEqualToString:@"area"] || [name isEqualToString:@"line"] || [name isEqualToString:@"canvas"] || [name isEqualToString:@"*"])
    {
        justTokenisedObject = YES;
    }

    return [NSArray arrayWithObject:token];
}

@end
