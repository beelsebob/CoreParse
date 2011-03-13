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
    NSMutableArray *tokenRecognisers;
}

@property (readwrite, retain) NSMutableArray *tokenRecognisers;

@end

@implementation CPTokeniser

@synthesize tokenRecognisers;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTokenRecognisers:[NSMutableArray array]];
    }
    
    return self;
}

- (void)dealloc
{
    [tokenRecognisers release];
    
    [super dealloc];
}

- (void)addTokenRecogniser:(id<CPTokenRecogniser>)recogniser
{
    [[self tokenRecognisers] addObject:recogniser];
}

- (void)insertTokenRecogniser:(id<CPTokenRecogniser>)recogniser atPriority:(NSInteger)pri
{
    [[self tokenRecognisers] insertObject:recogniser atIndex:pri];
}

- (void)insertTokenRecogniser:(id<CPTokenRecogniser>)recogniser before:(id<CPTokenRecogniser>)other
{
    [self insertTokenRecogniser:recogniser atPriority:[[self tokenRecognisers] indexOfObject:other]];
}

- (void)removeTokenRecogniser:(id<CPTokenRecogniser>)recogniser
{
    [[self tokenRecognisers] removeObject:recogniser];
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
        [[self tokenRecognisers] enumerateObjectsUsingBlock:^(id<CPTokenRecogniser> recogniser, NSUInteger idx, BOOL *stop)
         {
             CPToken *tok = [recogniser recogniseTokenInString:input currentTokenPosition:&currentTokenOffset];
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
