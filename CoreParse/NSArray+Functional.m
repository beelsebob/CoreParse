//
//  NSArray+Functional.m
//  CoreParse
//
//  Created by Tom Davie on 20/08/2012.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)map:(id(^)(id obj))block
{
    NSMutableArray *resultingObjects = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id obj in self)
    {
        id r = block(obj);
        if (nil != r)
        {
            [resultingObjects addObject:r];
        }
    }
    
    return resultingObjects;
}

@end
