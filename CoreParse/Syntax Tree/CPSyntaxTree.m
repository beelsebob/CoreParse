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
        self.rule = initRule;
        self.children = initChildren;
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

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CPSyntaxTree class]])
    {
        CPSyntaxTree *other = (CPSyntaxTree *)object;
        return other.rule == self.rule && [other.children isEqual:self.children];
    }
    return NO;
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"("];
    [children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [desc appendFormat:@"%@ ", obj];
     }];
    [desc replaceCharactersInRange:NSMakeRange([desc length] - 1, 1) withString:@")"];
    return desc;
}

@end
