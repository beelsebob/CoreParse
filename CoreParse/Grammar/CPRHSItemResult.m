//
//  CPRHSItemResult.m
//  CoreParse
//
//  Created by Thomas Davie on 23/10/2011.
//  Copyright (c) 2011 In The Beginning... All rights reserved.
//

#import "CPRHSItemResult.h"

@implementation CPRHSItemResult

@synthesize contents;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree
{
    self = [super init];
    
    if (nil != self)
    {
        NSArray *children = [syntaxTree children];
        
        switch ([[syntaxTree rule] tag])
        {
            case 0:
                [self setContents:[NSMutableArray array]];
                break;
            case 1:
                [self setContents:[[children mutableCopy] autorelease]];
                break;
            case 2:
            {
                NSMutableArray *nextContents = (NSMutableArray *)[children lastObject];
                NSUInteger i = 0;
                for (id newContent in [children subarrayWithRange:NSMakeRange(0, [children count] - 1)])
                {
                    [nextContents insertObject:newContent atIndex:i];
                    i++;
                }
                [self setContents:nextContents];
                break;
            }
            default:
                [self setContents:[[children mutableCopy] autorelease]];
                break;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [contents release];
    [super dealloc];
}

@end
