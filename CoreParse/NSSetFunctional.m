//
//  NSSetFunctional.m
//  CoreParse
//
//  Created by Tom Davie on 06/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "NSSetFunctional.h"


@implementation NSSet(Functional)

- (NSSet *)map:(id(^)(id obj))block
{
    NSMutableSet *resultingObjects = [NSMutableSet setWithCapacity:[self count]];
    
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
