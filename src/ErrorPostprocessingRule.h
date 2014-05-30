//
//  ErrorPostprocessingRule.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 10/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ErrorPostprocessingRelation) {
    ErrorPostprocessingRelationIsEqual,
    ErrorPostprocessingRelationGreaterThan,
    ErrorPostprocessingRelationSmallerThan,
};

@class CapturedError;
@protocol ErrorPostprocessingRule <NSObject>

- (BOOL)isValidForCapturedError:(CapturedError *)capturedError;

- (void)execute;

@end

#pragma mark -

typedef void(^ErrorPostprocessingExecutionBlock)();

@interface ErrorPostprocessingRule : NSObject <ErrorPostprocessingRule>

/*! Constraints must be array of ErrorPostprocessingConstraint objects */
+ (ErrorPostprocessingRule *)ruleThatSatisfiesConstraints:(NSArray *)constraints execution:(ErrorPostprocessingExecutionBlock)executionBlock;

@end

#pragma mark -

@interface ErrorPostprocessingConstraint : NSObject

@property (nonatomic, strong) NSString *property;
@property (nonatomic, assign) ErrorPostprocessingRelation relation;
@property (nonatomic, strong) id value;

+ (ErrorPostprocessingConstraint *)constraintWithProperty:(NSString *)property relation:(ErrorPostprocessingRelation)relation value:(id)value;

@end
