//
//  CPKeywordRecogniser.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 Hunted Cow Studios Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"
#import "CPKeywordToken.h"

@interface CPKeywordRecogniser : NSObject <CPTokenRecogniser>
{}

+ (id)recogniserForKeyword:(NSString *)keyword;
- (id)initWithKeyword:(NSString *)keyword;

@property (readwrite,retain) NSString *keyword;

@end
