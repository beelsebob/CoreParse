//
//  CPNumberToken.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPToken.h"

@interface CPNumberToken : CPToken
{}

@property (readwrite,retain) NSNumber *number;

+ (id)tokenWithNumber:(NSNumber *)number;
- (id)initWithNumber:(NSNumber *)number;

@end
