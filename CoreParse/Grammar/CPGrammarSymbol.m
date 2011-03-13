//
//  CPGrammarSymbol.m
//  CoreParse
//
//  Created by Tom Davie on 13/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPGrammarSymbol.h"


@implementation CPGrammarSymbol

@synthesize name;
@synthesize terminal;

+ (id)nonTerminalWithName:(NSString *)name
{
    return [[[self alloc] initWithNonTerminalName:name] autorelease];
}

- (id)initWithNonTerminalName:(NSString *)initName
{
    self = [super init];
    
    if (nil != self)
    {
        [self setName:initName];
        [self setTerminal:NO];
    }
    
    return self;
}

+ (id)terminalWithName:(NSString *)name
{
    return [[[self alloc] initWithTerminalName:name] autorelease];
}

- (id)initWithTerminalName:(NSString *)initName
{
    self = [super init];
    
    if (nil != self)
    {
        [self setName:initName];
        [self setTerminal:YES];
    }
    
    return self;
}

- (id)init
{
    return [self initWithNonTerminalName:@""];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPGrammarSymbol class]])
    {
        CPGrammarSymbol *other = (CPGrammarSymbol *)object;
        BOOL namesEqual    = [[other name] isEqualToString:[self name]];
        BOOL terminalEqual = [other isTerminal] == [self isTerminal];
        return namesEqual && terminalEqual;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [[self name] hash];
}

- (NSString *)description
{
    if ([self isTerminal])
    {
        return [NSString stringWithFormat:@"\"%@\"", [self name]];
    }
    else
    {
        return [NSString stringWithFormat:@"<%@>", [self name]];
    }
}

- (void)dealloc
{
    [name release];
    
    [super dealloc];
}

@end
