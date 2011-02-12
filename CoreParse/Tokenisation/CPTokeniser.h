//
//  CPTokeniser.h
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"
#import "CPTokenStream.h"

@interface CPTokeniser : NSObject
{}

- (void)addTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser;
- (void)insertTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser atPriority:(NSInteger)pri;
- (void)insertTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser before:(NSObject<CPTokenRecogniser> *)other;

- (void)removeTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser;

- (CPTokenStream *)tokenise:(NSString *)input;

@end
