//
//  CPWhiteSpaceToken.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPToken.h"

@interface CPWhiteSpaceToken : CPToken
{}

@property (readwrite,copy) NSString *whiteSpace;

+ (id)whiteSpace:(NSString *)whiteSpace;
- (id)initWithWhiteSpace:(NSString *)whiteSpace;

@end
