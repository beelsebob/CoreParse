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

+ (id)lr1ItemWithRule:(CPRule *)rule position:(NSUInteger)position terminal:(CPTerminal *)terminal
{
    return [[[self alloc] initWithRule:rule position:position terminal:terminal] autorelease];
}

- (id)initWithRule:(CPRule *)rule position:(NSUInteger)position terminal:(CPTerminal *)initTerminal
{
    self = [super initWithRule:rule position:position];
    
    if (nil != self)
    {
        self.terminal = initTerminal;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CPLR1Item allocWithZone:zone] initWithRule:self.rule position:self.position terminal:self.terminal];
}

- (void)dealloc
{
    [terminal release];
    
    [super dealloc];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CPLR1Item class]] && [super isEqual:object] && [((CPLR1Item *)object).terminal isEqual:self.terminal];
}

- (NSUInteger)hash
{
    return [self.rule hash] << 16 + [self.terminal hash] + self.position;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ ::= ", self.rule.name];
    NSUInteger pos = 0;
    for (NSObject *obj in self.rule.rightHandSideElements)
    {
        if (pos == self.position)
        {
            [desc appendFormat:@"• "];
        }
        [desc appendFormat:@"%@ ", obj];
        pos++;
    }
    if (pos == self.position)
    {
        [desc appendFormat:@"• "];
    }
    
    [desc appendFormat:@", %@", [self.terminal tokenName]];
    
    return desc;
}

@end
