//
//  CPSyntaxTree.m
//  CoreParse
//
//  Created by Tom Davie on 04/03/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import "CPSyntaxTree.h"

@interface CPSyntaxTree ()

@property (readwrite,retain) CPRule *rule;
@property (readwrite,copy) NSArray *children;

@end

@implementation CPSyntaxTree

@synthesize rule;
@synthesize children;

+ (id)syntaxTreeWithRule:(CPRule *)rule children:(NSArray *)children
{
    return [[[self alloc] initWithRule:rule children:children] autorelease];
}

- (id)initWithRule:(CPRule *)initRule children:(NSArray *)initChildren;
{
    self = [super init];
    
    if (nil != self)
    {
        [self setRule:initRule];
        [self setChildren:initChildren];
    }
    
    return self;
}

- (id)init
{
    return [self initWithRule:nil children:[NSArray array]];
}

- (void)dealloc
{
    [rule release];
    [children release];
    
    [super dealloc];
}

- (NSUInteger)hash
{
    return [[self rule] hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPSyntaxTree class]])
    {
        CPSyntaxTree *other = (CPSyntaxTree *)object;
        return [other rule] == [self rule] && [[other children] isEqualToArray:[self children]];
    }
    return NO;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"("];
    for (id obj in children)
    {
        [desc appendFormat:@"%@ ", obj];
    }
    [desc replaceCharactersInRange:NSMakeRange([desc length] - 1, 1) withString:@")"];
    return desc;
}

@end
