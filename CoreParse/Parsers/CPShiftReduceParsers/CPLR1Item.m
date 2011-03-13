//
//  CPLR1Item.m
//  CoreParse
//
//  Created by Tom Davie on 12/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPLR1Item.h"

@interface CPLR1Item ()

@property (readwrite,retain) NSString *terminal;

@end

@implementation CPLR1Item

@synthesize terminal;

+ (id)lr1ItemWithRule:(CPRule *)rule position:(NSUInteger)position terminal:(CPGrammarSymbol *)terminal
{
    return [[[self alloc] initWithRule:rule position:position terminal:terminal] autorelease];
}

- (id)initWithRule:(CPRule *)rule position:(NSUInteger)position terminal:(CPGrammarSymbol *)initTerminal
{
    self = [super initWithRule:rule position:position];
    
    if (nil != self)
    {
        [self setTerminal:initTerminal];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CPLR1Item allocWithZone:zone] initWithRule:[self rule] position:[self position] terminal:[self terminal]];
}

- (void)dealloc
{
    [terminal release];
    
    [super dealloc];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPLR1Item class]])
    {
        CPLR1Item *other = (CPLR1Item *)object;
        return [super isEqual:object] && [[other terminal] isEqual:[self terminal]];
    }
    return NO;
}

- (NSUInteger)hash
{
    return [[self rule] hash] << 16 + [[self terminal] hash] + [self position];
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@", %@", [[self terminal] name]];
}

@end
