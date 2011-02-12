//
//  CPToken.m
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
//

#import "CPToken.h"

@interface CPToken ()
{
@private
    NSString *content;
}

@end

@implementation CPToken

@synthesize content;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        self.content = @"";
    }
    
    return self;
}

- (void)dealloc
{
    [content release];
    [super dealloc];
}

@end
