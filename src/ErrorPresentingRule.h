//
//  ErrorPresentingRule.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedError.h"


typedef NS_ENUM(NSInteger, ErrorPresentingPermission) {
    ErrorPresentingPermissionDeny,
    ErrorPresentingPermissionAllow,
    ErrorPresentingPermissionUndefined,
};

typedef NS_ENUM(NSInteger, ErrorPresentingRelation) {
    ErrorPresentingRelationIsEqual,
    ErrorPresentingRelationGreaterThan,
    ErrorPresentingRelationSmallerThan,
};


@protocol ErrorPresentingRule <NSObject>

- (void)setPermission:(ErrorPresentingPermission)permission forCapturedErrorProperty:(NSString *)property relation:(ErrorPresentingRelation)relation value:(id)value;

- (void)restrictRuleForErrorWithDomain:(NSString *)domain code:(NSInteger)code;

- (ErrorPresentingPermission)presentingPermissionForError:(CapturedError *)capturedError;

@end

#pragma mark -

@interface ErrorPresentingRule : NSObject <ErrorPresentingRule>

+ (ErrorPresentingRule *)ruleForCapturedErrorProperty:(NSString *)property relation:(ErrorPresentingRelation)relation value:(id)value withPermission:(ErrorPresentingPermission)permission;

@end
