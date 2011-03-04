//
//  Production.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NonTerminal : NSObject
{}

@property (readwrite, copy) NSString *name;
@property (readwrite, copy) NSArray *rightHandSideElements;

+ (id)nonTerminalWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements;
- (id)initWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements;

@end
