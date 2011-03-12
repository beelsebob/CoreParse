//
//  CPLR1Item.h
//  CoreParse
//
//  Created by Tom Davie on 12/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPItem.h"

@interface CPLR1Item : CPItem
{}

@property (readonly,copy) NSString *terminalName;

+ (id)lr1ItemWithRule:(CPRule *)rule position:(NSUInteger)position terminalName:(NSString *)terminalName;
- (id)initWithRule:(CPRule *)rule position:(NSUInteger)position terminalName:(NSString *)terminalName;

@end
