//
//  CPJSONParser.h
//  CoreParse
//
//  Created by Tom Davie on 29/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CPJSONParser : NSObject
{}

- (id<NSObject>)parse:(NSString *)json;

@end
