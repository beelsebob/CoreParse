//
//  CPRule.h
//  CoreParse
//
//  Created by Tom Davie on 05/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CPRule : NSObject
{}

@property (readwrite, retain) NSString *name;
@property (readwrite, copy  ) NSArray *rightHandSideElements;
@property (readwrite, assign) NSUInteger tag;

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)tag;
- (id)initWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements tag:(NSUInteger)tag;

+ (id)ruleWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements;
- (id)initWithName:(NSString *)name rightHandSideElements:(NSArray *)rightHandSideElements;

@end
