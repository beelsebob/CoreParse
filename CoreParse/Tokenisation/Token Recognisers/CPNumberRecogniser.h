//
//  CPIntegerRecogniser.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"

@interface CPNumberRecogniser : NSObject <CPTokenRecogniser>
{}

@property (readwrite,assign) BOOL recognisesInts;
@property (readwrite,assign) BOOL recognisesFloats;

+ (id)integerRecogniser;
+ (id)floatRecogniser;
+ (id)numberRecogniser;

@end
