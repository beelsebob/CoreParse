//
//  CPIdentifierTokeniser.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPTokenRecogniser.h"

@interface CPIdentifierRecogniser : NSObject <CPTokenRecogniser>
{}

@property (readwrite,retain) NSCharacterSet *initialCharacters;
@property (readwrite,retain) NSCharacterSet *identifierCharacters;

+ (id)identifierRecogniser;
+ (id)identifierRecogniserWithInitialCharacters:(NSCharacterSet *)initialCharacters identifierCharacters:(NSCharacterSet *)identifierCharacters;
- (id)initWithInitialCharacters:(NSCharacterSet *)initInitialCharacters identifierCharacters:(NSCharacterSet *)initIdentifierCharacters;

@end
