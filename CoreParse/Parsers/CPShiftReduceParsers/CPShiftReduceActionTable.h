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

@interface CPShiftReduceActionTable : NSObject
{}

- (CPShiftReduceAction *)actionForState:(NSUInteger)state token:(CPToken *)token;

@end
