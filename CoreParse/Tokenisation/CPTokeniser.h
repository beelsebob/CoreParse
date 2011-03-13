//
//  CPTokeniser.h
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"
#import "CPTokenStream.h"

@interface CPTokeniser : NSObject
{}

- (void)addTokenRecogniser:(id<CPTokenRecogniser>)recogniser;
- (void)insertTokenRecogniser:(id<CPTokenRecogniser>)recogniser atPriority:(NSInteger)pri;
- (void)insertTokenRecogniser:(id<CPTokenRecogniser>)recogniser before:(id<CPTokenRecogniser>)other;

- (void)removeTokenRecogniser:(id<CPTokenRecogniser>)recogniser;

- (CPTokenStream *)tokenise:(NSString *)input;

@end
