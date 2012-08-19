//
//  CPTokeniser.m
//  CoreParse
//
//  Created by Tom Davie on 10/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPTokeniser.h"

#import "CPEOFToken.h"
#import "CPErrorToken.h"

@interface CPTokeniser ()
{
    NSMutableArray *tokenRecognisers;
}

@property (readwrite, retain) NSMutableArray *tokenRecognisers;

- (void)addToken:(CPToken *)tok toStream:(CPTokenStream *)stream;
- (void)advanceLineNumber:(NSUInteger *)ln columnNumber:(NSUInteger *)cn withInput:(NSString *)input range:(NSRange)range;

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
    NSUInteger currentLineNumber = 0;
    NSUInteger currentColumnNumber = 0;
    NSUInteger inputLength = [input length];
    NSArray *recs = [self tokenRecognisers];
    
    while (currentTokenOffset < inputLength)
    {
        BOOL recognised = NO;
        for (id<CPTokenRecogniser> recogniser in recs)
        {
            NSUInteger lastTokenOffset = currentTokenOffset;
            CPToken *tok = [recogniser recogniseTokenInString:input currentTokenPosition:&currentTokenOffset];
            if (nil != tok)
            {
                [tok setLineNumber:currentLineNumber];
                [tok setColumnNumber:currentColumnNumber];
                [tok setCharacterNumber:lastTokenOffset];
                [tok setLength:currentTokenOffset - lastTokenOffset];
                
                if ([delegate respondsToSelector:@selector(tokeniser:shouldConsumeToken:)])
                {
                    if ([delegate tokeniser:self shouldConsumeToken:tok])
                    {
                        [self addToken:tok toStream:stream];
                        [self advanceLineNumber:&currentLineNumber columnNumber:&currentColumnNumber withInput:input range:NSMakeRange(lastTokenOffset, currentTokenOffset - lastTokenOffset)];
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
                    [self advanceLineNumber:&currentLineNumber columnNumber:&currentColumnNumber withInput:input range:NSMakeRange(lastTokenOffset, currentTokenOffset - lastTokenOffset)];
                    recognised = YES;
                    break;
                }
            }
        }
        
        if (!recognised)
        {
            if ([delegate respondsToSelector:@selector(tokeniser:didNotFindTokenOnInput:position:error:)])
            {
                NSString *err = nil;
                currentTokenOffset = [delegate tokeniser:self didNotFindTokenOnInput:input position:currentTokenOffset error:&err];
                [self addToken:[CPErrorToken errorWithMessage:err] toStream:stream];
                if (NSNotFound == currentTokenOffset)
                {
                    break;
                }
            }
            else
            {
                CPErrorToken *t = [CPErrorToken errorWithMessage:[NSString stringWithFormat:@"The tokeniser encountered an invalid input \"%@\", and could not handle it.  Implement -tokeniser:didNotFindTokenAtInputPosition:error: to make this do something more useful", [input substringWithRange:NSMakeRange(currentTokenOffset, MIN((NSUInteger)10, [input length] - currentTokenOffset))]]];
                [t setLineNumber:currentLineNumber];
                [t setColumnNumber:currentColumnNumber];
                [t setCharacterNumber:currentTokenOffset];
                [self addToken:t toStream:stream];
                break;
            }
        }
    }
    if (inputLength <= currentTokenOffset)
    {
        CPEOFToken *token = [CPEOFToken eof];
        [token setLineNumber:currentLineNumber];
        [token setColumnNumber:currentColumnNumber];
        [token setCharacterNumber:inputLength];
        [stream pushToken:token];
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

- (void)advanceLineNumber:(NSUInteger *)ln columnNumber:(NSUInteger *)cn withInput:(NSString *)input range:(NSRange)range
{
    NSRange searchRange = range;
    NSUInteger rangeEnd = range.location + range.length;
    NSRange foundRange = [input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"] options:NSLiteralSearch range:searchRange];
    NSUInteger lastNewLineLocation = NSNotFound;
    while (foundRange.location != NSNotFound)
    {
        *ln += foundRange.length;
        lastNewLineLocation = foundRange.location + foundRange.length;
        searchRange = NSMakeRange(lastNewLineLocation, rangeEnd - lastNewLineLocation);
        foundRange = [input rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"] options:NSLiteralSearch range:searchRange];
    }
    if (lastNewLineLocation != NSNotFound)
    {
        *cn = rangeEnd - lastNewLineLocation;
    }
    else
    {
        *cn += range.length;
    }
}

@end
