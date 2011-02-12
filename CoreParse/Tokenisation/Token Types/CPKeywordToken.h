//
//  CPKeywordToken.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPToken.h"

@interface CPKeywordToken : CPToken
{}

@property (readwrite,copy) NSString *keyword;

+ (id)tokenWithKeyword:(NSString *)keyword;
- (id)initWithKeyword:(NSString *)keyword;

@end
