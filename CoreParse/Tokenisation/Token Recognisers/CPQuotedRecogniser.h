//
//  CPQuotedRecogniser.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"

@interface CPQuotedRecogniser : NSObject <CPTokenRecogniser>
{}

@property (readwrite,copy) NSString *startQuote;
@property (readwrite,copy) NSString *endQuote;
@property (readwrite,copy) NSString *escapeSequence;
@property (readwrite,copy) NSString *(^escapeReplacer)(NSString *tokenStream, NSUInteger *quotePosition);
@property (readwrite,assign) NSUInteger maximumLength;
@property (readwrite,copy) NSString *name;

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote name:(NSString *)name;
+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapeSequence:(NSString *)escapeSequence name:(NSString *)name;
+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapeSequence:(NSString *)escapeSequence maximumLength:(NSUInteger)maximumLength name:(NSString *)name;

- (id)initWithStartQuote:(NSString *)initStartQuote endQuote:(NSString *)initEndQuote escapeSequence:(NSString *)initEscapeSequence maximumLength:(NSUInteger)initMaximumLength name:(NSString *)name;

@end
