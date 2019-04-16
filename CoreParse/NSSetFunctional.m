//
//  NSSetFunctional.m
//  CoreParse
//
//  Created by Tom Davie on 06/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "NSSetFunctional.h"


@implementation NSSet(Functional)

- (NSSet *)cp_map:(id(^)(id obj))block
{
    NSUInteger c = [self count];
    NSMutableSet *s = [NSMutableSet setWithCapacity:c];
    
    for (id obj in self)
    {
        id r = block(obj);
        if (nil != r)
        {
            [s addObject:r];
        }
    }

    return [s copy];
}

@end
