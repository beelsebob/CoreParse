//
//  CPLR1Item.m
//  CoreParse
//
//  Created by Tom Davie on 12/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPLR1Item.h"

@interface CPLR1Item ()

@property (readwrite,copy) NSString *terminalName;

@end

@implementation CPLR1Item

@synthesize terminalName;

+ (id)lr1ItemWithRule:(CPRule *)rule position:(NSUInteger)position terminalName:(NSString *)terminalName
{
    return [[[self alloc] initWithRule:rule position:position terminalName:terminalName] autorelease];
}

- (id)initWithRule:(CPRule *)rule position:(NSUInteger)position terminalName:(NSString *)initTerminalName
{
    self = [super initWithRule:rule position:position];
    
    if (nil != self)
    {
        self.terminalName = initTerminalName;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CPLR1Item allocWithZone:zone] initWithRule:self.rule position:self.position terminalName:self.terminalName];
}

- (void)dealloc
{
    [terminalName release];
    
    [super dealloc];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CPLR1Item class]] && [super isEqual:object] && [((CPLR1Item *)object).terminalName isEqualToString:self.terminalName];
}

- (NSUInteger)hash
{
    return [self.rule hash] << 16 + [self.terminalName hash] + self.position;
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
    
    [desc appendFormat:@", %@", self.terminalName];
    
    return desc;
}

@end
