//
//  CPKeywordRecogniser.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"
#import "CPKeywordToken.h"

@interface CPKeywordRecogniser : NSObject <CPTokenRecogniser>
{}

+ (id)recogniserForKeyword:(NSString *)keyword;
- (id)initWithKeyword:(NSString *)keyword;

+ (id)recogniserForKeyword:(NSString *)keyword invalidFollowingCharacters:(NSCharacterSet *)invalidFollowingCharacters;
- (id)initWithKeyword:(NSString *)keyword invalidFollowingCharacters:(NSCharacterSet *)invalidFollowingCharacters;

@property (readwrite,retain) NSString *keyword;
@property (readwrite,retain) NSCharacterSet *invalidFollowingCharacters;

@end
