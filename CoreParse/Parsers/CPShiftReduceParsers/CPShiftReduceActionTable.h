//
//  CPShiftReduceActionTable.h
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPShiftReduceAction.h"
#import "CPToken.h"
#import "CPGrammar.h"

@interface CPShiftReduceActionTable : NSObject
{}

- (id)initWithCapacity:(NSUInteger)capacity;

- (void)setAction:(CPShiftReduceAction *)action forState:(NSUInteger)state tokenName:(NSString *)token;

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token;

- (NSString *)descriptionWithGrammar:(CPGrammar *)g;

@end
