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

- (void)addToken:(CPToken *)tok toStream:(CPTokenStream *)stream;

@end

@implementation CPTokeniser

@synthesize tokenRecognisers;
@synthesize delegate;

- (id)init
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTokenRecognisers:[NSMutableArray array]];
    }
    
    return self;
}

#define CPTokeniserTokenRecognisersKey @"T.r"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (nil != self)
    {
        [self setTokenRecognisers:[aDecoder decodeObjectForKey:CPTokeniserTokenRecognisersKey]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self tokenRecognisers] forKey:CPTokeniserTokenRecognisersKey];
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

- (void)insertTokenRecogniser:(id<CPTokenRecogniser>)recogniser beforeRecogniser:(id<CPTokenRecogniser>)other
{
    NSUInteger idx = [[self tokenRecognisers] indexOfObject:other];
    if (NSNotFound == idx)
    {
        [NSException raise:NSInvalidArgumentException format:@"Token recogniser to insert before was not found"];
    }
    [self insertTokenRecogniser:recogniser atPriority:idx];
}

- (void)removeTokenRecogniser:(id<CPTokenRecogniser>)recogniser
{
    [[self tokenRecognisers] removeObject:recogniser];
}

- (CPTokenStream *)tokenise:(NSString *)input
{
    CPTokenStream *stream = [[[CPTokenStream alloc] init] autorelease];
    
    [self tokenise:input into:stream];
    
    return stream;
}

- (void)tokenise:(NSString *)input into:(CPTokenStream *)stream
{
    NSUInteger currentTokenOffset = 0;
    NSUInteger inputLength = [input length];
    NSArray *recs = [self tokenRecognisers];
    
    BOOL recognised = YES;
    while (currentTokenOffset < inputLength && recognised)
    {
        recognised = NO;
        for (id<CPTokenRecogniser> recogniser in recs)
        {
            NSUInteger lastTokenOffset = currentTokenOffset;
            CPToken *tok = [recogniser recogniseTokenInString:input currentTokenPosition:&currentTokenOffset];
            if (nil != tok)
            {
                if ([delegate respondsToSelector:@selector(tokeniser:shouldConsumeToken:)])
                {
                    if ([delegate tokeniser:self shouldConsumeToken:tok])
                    {
                        [self addToken:tok toStream:stream];
                        recognised = YES;
                        break;
                    }
                    else
                    {
                        currentTokenOffset = lastTokenOffset;
                    }
                }
                else
                {
                    [self addToken:tok toStream:stream];
                    recognised = YES;
                    break;
                }
            }
        }
    }
    if (inputLength <= currentTokenOffset)
    {
        [stream pushToken:[CPEOFToken eof]];
    }
    [stream closeTokenStream];
}

- (void)addToken:(CPToken *)tok toStream:(CPTokenStream *)stream
{
    NSArray *toks;
    if ([delegate respondsToSelector:@selector(tokeniser:willProduceToken:)])
    {
        toks = [delegate tokeniser:self willProduceToken:tok];
    }
    else
    {
        toks = [NSArray arrayWithObject:tok];
    }
    [stream pushTokens:toks];
}

@end
