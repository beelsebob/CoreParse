//
//  CPTokeniser.m
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTokeniser.h"

#import "CPEOFToken.h"

@interface CPTokeniser ()
{
    NSMutableArray *tokenRegexes;
}

@property (readwrite, retain) NSMutableArray *tokenRegexes;

@end

@implementation CPTokeniser

@synthesize tokenRegexes;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        self.tokenRegexes = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    [tokenRegexes release];
    [super dealloc];
}

- (void)addTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser
{
    [self.tokenRegexes addObject:recogniser];
}

- (void)insertTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser atPriority:(NSInteger)pri
{
    [self.tokenRegexes insertObject:recogniser atIndex:pri];
}

- (void)insertTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser before:(NSObject<CPTokenRecogniser> *)other
{
    [self insertTokenRecogniser:recogniser atPriority:[self.tokenRegexes indexOfObject:other]];
}

- (void)removeTokenRecogniser:(NSObject<CPTokenRecogniser> *)recogniser
{
    [self.tokenRegexes removeObject:recogniser];
}

- (CPTokenStream *)tokenise:(NSString *)input
{
    CPTokenStream *stream = [[[CPTokenStream alloc] init] autorelease];
    __block NSUInteger currentTokenOffset = 0;
    NSUInteger inputLength = [input length];
    
    __block BOOL recognised = YES;
    while (currentTokenOffset < inputLength && recognised)
    {
        recognised = NO;
        [self.tokenRegexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             CPToken *tok = [(NSObject<CPTokenRecogniser> *)obj recogniseTokenInString:input currentTokenPosition:&currentTokenOffset];
             if (nil != tok)
             {
                 [stream pushToken:tok];
                 recognised = YES;
                 *stop = YES;
             }
         }];
    }
    if (inputLength <= currentTokenOffset)
    {
        [stream pushToken:[CPEOFToken eof]];
    }
    
    return stream;
}

@end
