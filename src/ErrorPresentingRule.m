//
//  ErrorPresentingRule.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "ErrorPresentingRule.h"


@interface ErrorPresentingRule ()

@property (nonatomic, strong) NSString *property;
@property (nonatomic, assign) ErrorPresentingRelation relation;
@property (nonatomic, strong) id value;
@property (nonatomic, assign) ErrorPresentingPermission permission;

@property (nonatomic, strong) NSString *restrictedErrorDomain;
@property (nonatomic, assign) NSInteger restrictedErrorCode;

@end


@implementation ErrorPresentingRule


#pragma mark Static

+ (ErrorPresentingRule *)ruleForCapturedErrorProperty:(NSString *)property relation:(ErrorPresentingRelation)relation value:(id)value withPermission:(ErrorPresentingPermission)permission
{
    ErrorPresentingRule *rule = [[self alloc] init];
    [rule setPermission:permission forCapturedErrorProperty:property relation:relation value:value];
    
    return rule;
}

#pragma mark Init

- (id)init
{
    self = [super init];
    if (self) {
        _restrictedErrorCode = NSNotFound;
    }
    return self;
}


#pragma mark ErrorPresentingRule

- (void)setPermission:(ErrorPresentingPermission)permission forCapturedErrorProperty:(NSString *)property relation:(ErrorPresentingRelation)relation value:(id)value
{
    if (property == nil) {
        [NSException raise:NSUndefinedKeyException format:@"Key 'property' cannot be nil."];
    }
    self.permission = permission;
    self.property = property;
    self.relation = relation;
    self.value = value;
}

- (void)restrictRuleForErrorWithDomain:(NSString *)domain code:(NSInteger)code
{
    self.restrictedErrorDomain = domain;
    self.restrictedErrorCode = code;
}

- (ErrorPresentingPermission)presentingPermissionForError:(CapturedError *)capturedError
{
    ErrorPresentingPermission permission = ErrorPresentingPermissionUndefined;
    ErrorPresentingPermission counterPermission = ErrorPresentingPermissionUndefined;
    
    if ((self.restrictedErrorDomain == nil || (self.restrictedErrorDomain != nil && [self.restrictedErrorDomain isEqualToString:capturedError.domain])) &&
        (self.restrictedErrorCode == NSNotFound || (self.restrictedErrorCode != NSNotFound && self.restrictedErrorCode == capturedError.code))) {
    
        if (self.property != nil && [capturedError respondsToSelector:NSSelectorFromString(self.property)]) {
            id value = [capturedError valueForKey:self.property];
            
            NSComparisonResult comparisonResult = [value compare:self.value];
            
            switch (self.relation) {
                case ErrorPresentingRelationIsEqual:
                    permission = (comparisonResult == NSOrderedSame) ? self.permission : counterPermission;
                    break;
                    
                case ErrorPresentingRelationGreaterThan:
                    permission = (comparisonResult == NSOrderedDescending) ? self.permission : counterPermission;
                    break;
                    
                case ErrorPresentingRelationSmallerThan:
                    permission = (comparisonResult == NSOrderedAscending) ? self.permission : counterPermission;
                    break;
                    
                default:
                    permission = ErrorPresentingPermissionUndefined;
                    break;
            }
        }
    }
    return permission;
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    
    ErrorPresentingRule *rule = (ErrorPresentingRule *)object;
    
    if (![rule.property isEqualToString:self.property])
        return NO;
    if (rule.relation != self.relation)
        return NO;
    if (![rule.value isEqual:self.value])
        return NO;
    if (rule.permission != self.permission)
        return NO;
    
    return YES;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"%@: property: %@, relation: %d, value: %@, permission: %d", [super description], self.property, (int)self.relation, [self.value description], (int)self.permission];
    return desc;
}

@end
