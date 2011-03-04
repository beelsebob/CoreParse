//
//  Terminal.h
//  CoreParse
//
//  Created by Tom Davie on 13/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Terminal : NSObject
{}

@property (readwrite, copy) NSString *tokenName;

+ (id)terminalWithTokenName:(NSString *)tokenName;
- (id)initWithTokeName:(NSString *)tokenName;

@end
