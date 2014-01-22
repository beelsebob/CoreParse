//
//  CPRegexpRecogniser.h
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPTokenRecogniser.h"

/**
 * The CPRegexpKeywordRecogniser class attempts to recognise a specific keyword in a token stream using a NSRegularExpression.
 *
 * A regexp keyword recogniser attempts to recognise a regexp.
 *
 * This recogniser produces CPKeywordTokens.
 */
@interface CPRegexpKeywordRecogniser : NSObject <CPTokenRecogniser>

@property (nonatomic, retain) NSRegularExpression* regexp;

///---------------------------------------------------------------------------------------
/// @name Creating and Initialising a Regexp Keyword Recogniser
///---------------------------------------------------------------------------------------

/**
 * Initialises a Regexp Recogniser to recognise a specific regexp.
 *
 * @param regexp The NSRegularExpression to recognise.
 *
 * @return Returns the regexp recogniser initialised to recognise the passed regexp.
 *
 * @see recogniserForRegexp:
 */
- (id)initWithRegexp:(NSRegularExpression *)regexp;

/**
 * Initialises a Regexp Recogniser to recognise a specific regexp.
 *
 * @param regexp The NSRegularExpression to recognise.
 *
 * @return Returns the regexp recogniser initialised to recognise the passed regexp.
 *
 * @see initWithRegexp:
 */
+ (id)recogniserForRegexp:(NSRegularExpression *)regexp;

@end
