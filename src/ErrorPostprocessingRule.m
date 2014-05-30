//
//  ErrorPostprocessingRule.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 10/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "ErrorPostprocessingRule.h"


@interface ErrorPostprocessingRule ()

@property (nonatomic, strong) NSArray *constraints;

@property (nonatomic, copy) ErrorPostprocessingExecutionBlock executionBlock;

@end

#pragma mark -

@implementation ErrorPostprocessingRule

+ (ErrorPostprocessingRule *)ruleThatSatisfiesConstraints:(NSArray *)constraints execution:(ErrorPostprocessingExecutionBlock)executionBlock
{
    ErrorPostprocessingRule *rule = [[self alloc] init];
    
    rule.constraints = constraints;
    rule.executionBlock = executionBlock;
    
    return rule;
}

#pragma mark ErrorPostprocessingRule

- (BOOL)isValidForCapturedError:(CapturedError *)capturedError
{
    for (ErrorPostprocessingConstraint *constaint in self.constraints) {
        if (![self error:capturedError satisfiesConstraint:constaint]) {
            return NO;
        }
    }
    return YES;
}

- (void)execute
{
    if (self.executionBlock)
        self.executionBlock();
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"%@: constraints: %@, block: %@", [super description], self.constraints, self.executionBlock == nil ? @"nil" : @"not nil"];
    return desc;
}


#pragma mark Private

- (BOOL)error:(CapturedError *)capturedError satisfiesConstraint:(ErrorPostprocessingConstraint *)constraint
{
    id value = [capturedError valueForKey:constraint.property];
    NSComparisonResult comparisonResult = [value compare:constraint.value];
    
    BOOL satisfies = NO;
    switch (constraint.relation) {
        case ErrorPostprocessingRelationIsEqual:
            satisfies = (comparisonResult == NSOrderedSame);
            break;
            
        case ErrorPostprocessingRelationGreaterThan:
            satisfies = (comparisonResult == NSOrderedDescending);
            break;
            
        case ErrorPostprocessingRelationSmallerThan:
            satisfies = (comparisonResult == NSOrderedAscending);
            break;
            
        default:
            satisfies = NO;
            break;
    }
    return satisfies;
}

@end

#pragma mark -

@implementation ErrorPostprocessingConstraint

+ (ErrorPostprocessingConstraint *)constraintWithProperty:(NSString *)property relation:(ErrorPostprocessingRelation)relation value:(id)value
{
    ErrorPostprocessingConstraint *constraint = [[self alloc] init];
    constraint.property = property;
    constraint.relation = relation;
    constraint.value = value;
    return constraint;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"%@: property: %@, relation: %d, value: %@", [super description], self.property, (int)self.relation, [self.value description]];
    return desc;
}

@end