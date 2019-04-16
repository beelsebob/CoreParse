//
//  NSArray+Functional.m
//  CoreParse
//
//  Created by Tom Davie on 20/08/2012.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)cp_map:(id(^)(id obj))block
{
    NSUInteger c = [self count];
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:c];
    
    for (id obj in self)
    {
        id r = block(obj);
        if (nil != r)
        {
            [a addObject:r];
        }
    }
    
    return [a copy];
}

@end
