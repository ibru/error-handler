//
//  ErrorProcessingRule.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "ErrorProcessingRule.h"

NSString *const kErrorProcessingEvaluationRuleImportance    = @"importance";
NSString *const kErrorProcessingEvaluationRuleTitle         = @"title";
NSString *const kErrorProcessingEvaluationRuleMessage       = @"message";
NSString *const kErrorProcessingEvaluationRuleDomain        = @"domain";
NSString *const kErrorProcessingEvaluationRuleCode          = @"code";


@interface ErrorProcessingRule ()


@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSArray *codes;
@property (nonatomic, strong) NSDictionary *evaluationRules;

@end

@implementation ErrorProcessingRule

#pragma mark ErrorProcessingRule

- (BOOL)isValidForDomain:(NSString *)domain code:(NSInteger)code
{
    if ([self.domain length] > 0) {
        if ([self.domain isEqualToString:domain]) {
            if (self.codes == nil)
                return YES;
            else
                return [self.codes containsObject:@(code)];
        }
        else
            return NO;
    }
    else
        return YES;
}

#pragma mark Public

+ (ErrorProcessingRule *)ruleForDomain:(NSString *)domain code:(NSInteger)code evaluationRules:(NSDictionary *)rules
{
    ErrorProcessingRule *rule = [[self alloc] init];
    rule.evaluationRules = rules;
    rule.domain = domain;
    
    if (code != NSNotFound)
        rule.codes = [NSArray arrayWithObject:@(code)];
    
    return rule;
}

+ (ErrorProcessingRule *)ruleForDomain:(NSString *)domain codes:(NSArray *)codes evaluationRules:(NSDictionary *)rules
{
    ErrorProcessingRule *rule = [[self alloc] init];
    rule.domain = domain;
    rule.codes = codes;
    rule.evaluationRules = rules;
    
    return rule;
}

#pragma mark NSObject

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"%@: Domain: %@, codes: %@, rules: %@", [super description], self.domain, self.codes, self.evaluationRules];
    return desc;
}

@end

#pragma mark -

@implementation CapturedError (ErrorProcessingRule)

- (void)applyEvaluationRules:(NSDictionary *)rules
{
    for (NSString *property in [rules allKeys]) {
        if ([self respondsToSelector:NSSelectorFromString(property)]) {
            [self setValue:rules[property] forKey:property];
        }
    }
}

@end