//
//  CPNumberToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPNumberToken.h"

@interface CPNumberToken ()
{
@private
    NSNumber *number;
}
@end

@implementation CPNumberToken

@synthesize number;

+ (id)tokenWithNumber:(NSNumber *)number
{
    return [[[CPNumberToken alloc] initWithNumber:number] autorelease];
}

- (id)initWithNumber:(NSNumber *)initNumber
{
    self = [super init];
    
    if (nil != self)
    {
        self.number = initNumber;
    }
    
    return self;    
}

- (id)init
{
    return [self initWithNumber:[NSNumber numberWithInteger:0]];
}

- (void)dealloc
{
    [number release];
    [super dealloc];
}

@end
