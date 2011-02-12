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
    NSString *tokenContent;
}

@end

@implementation CPToken

@synthesize tokenContent;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [tokenContent release];
    [super dealloc];
}

@end
