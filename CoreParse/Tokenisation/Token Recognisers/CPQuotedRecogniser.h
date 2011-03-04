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
@property (readwrite,copy) NSString *escapedEndQuote;
@property (readwrite,copy) NSString *escapedEscape;
@property (readwrite,assign) NSUInteger maximumLength;
@property (readwrite,copy) NSString *name;

+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote tokenName:(NSString *)name;
+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapedEndQuote:(NSString *)escapedEndQuote escapedEscape:(NSString *)escapedEscape tokenName:(NSString *)name;
+ (id)quotedRecogniserWithStartQuote:(NSString *)startQuote endQuote:(NSString *)endQuote escapedEndQuote:(NSString *)escapedEndQuote escapedEscape:(NSString *)escapedEscape maximumLength:(NSUInteger)maximumLength tokenName:(NSString *)name;

- (id)initWithStartQuote:(NSString *)initStartQuote endQuote:(NSString *)initEndQuote escapedEndQuote:(NSString *)initEscapedEndQuote escapedEscape:(NSString *)initEscapedEscape maximumLength:(NSUInteger)initMaximumLength tokenName:(NSString *)name;

@end
