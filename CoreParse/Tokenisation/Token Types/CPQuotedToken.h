//
//  CPQuotedToken.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPToken.h"


@interface CPQuotedToken : CPToken
{}

@property (readwrite,copy) NSString *content;
@property (readwrite,copy) NSString *quoteType;

+ (id)content:(NSString *)content quotedWith:(NSString *)startQuote name:(NSString *)name;
- (id)initWithContent:(NSString *)content quoteType:(NSString *)startQuote name:(NSString *)name;

@end
