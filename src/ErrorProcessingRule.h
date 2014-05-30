//
//  ErrorProcessingRule.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedError.h"


extern NSString *const kErrorProcessingEvaluationRuleImportance;
extern NSString *const kErrorProcessingEvaluationRuleTitle;
extern NSString *const kErrorProcessingEvaluationRuleMessage;
extern NSString *const kErrorProcessingEvaluationRuleDomain;
extern NSString *const kErrorProcessingEvaluationRuleCode;


@protocol ErrorProcessingRule <NSObject>

- (BOOL)isValidForDomain:(NSString *)domain code:(NSInteger)code;

/*! Rules of type property->value that should be applied to CapturedError object. For scalar values use NSValue subclass (eg. NSNumber) */
- (void)setEvaluationRules:(NSDictionary *)rules;

- (NSDictionary *)evaluationRules;

@end

#pragma mark -

@interface ErrorProcessingRule : NSObject <ErrorProcessingRule>

/*!
 Creates processing rule for specific error domain and code wth rules that will be applied.
 Set code to NSNotFound to be valid any code.
 Set domain to nil to be valid for any domain and code.
 */
+ (ErrorProcessingRule *)ruleForDomain:(NSString *)domain code:(NSInteger)code evaluationRules:(NSDictionary *)rules;

+ (ErrorProcessingRule *)ruleForDomain:(NSString *)domain codes:(NSArray *)codes evaluationRules:(NSDictionary *)rules;

@end

#pragma mark -

@interface CapturedError (ErrorProcessingRule)

- (void)applyEvaluationRules:(NSDictionary *)rules;

@end