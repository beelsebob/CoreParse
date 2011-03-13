//
//  CPTokenStream.h
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPToken.h"

typedef NSArray *(^TokenRewriter)(CPToken *token);

@interface CPTokenStream : NSObject
{}

@property (readwrite,copy) TokenRewriter tokenRewriter;

+ (id)tokenStreamWithTokens:(NSArray *)tokens;
- (id)initWithTokens:(NSArray *)tokens;

- (BOOL)hasToken;

- (CPToken *)peekToken;
- (CPToken *)popToken;

- (void)pushToken:(CPToken *)token;

- (NSArray *)peekAllRemainingTokens;

@end
