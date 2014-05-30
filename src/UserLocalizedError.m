//
//  UserLocalizedError.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 24/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "UserLocalizedError.h"


NSString *const UserErrorDomainRESTAPI          = @"REST API";
NSString *const UserErrorDomainSocketAPI        = @"Socket API";
NSString *const UserErrorDomainCallSession      = @"Call Session";
NSString *const UserErrorDomainGeneral          = @"General error";

static NSDictionary *errorMessages = nil;


@implementation UserLocalizedError

+ (void)initialize
{
    errorMessages = @{[@(UserErrorTypeAPIUndefined) stringValue]: NSLocalizedString(@"", @""),
                      [@(UserErrorTypeAPIUserNotAuthenticated) stringValue]: NSLocalizedString(@"User is not authenticated.", @""),
                      [@(UserErrorTypeAPIDataForAuthenticationNotProvided) stringValue]: NSLocalizedString(@"Not all data required for user authentication were provided.", @""),
                      [@(UserErrorTypeAPIUserNotIdentified) stringValue]: NSLocalizedString(@"User for this action was not identified.", @""),
                      [@(UserErrorTypeSocketsUndefined) stringValue]: NSLocalizedString(@"", @""),
                      [@(UserErrorTypeSocketsUserNotAuthenticated) stringValue]: NSLocalizedString(@"User did not provide all required authentication data.", @""),
                      [@(UserErrorTypeSocketsCallCommandNotValid) stringValue]: NSLocalizedString(@"Could not deliver request to other caller.", @""),
                      [@(UserErrorTypeSessionCommandUndefined) stringValue]: NSLocalizedString(@"", @""),
                      [@(UserErrorTypeSessionCommandCommandNotSuported) stringValue]: NSLocalizedString(@"Caller could not finish this action.", @""),
                      [@(UserErrorTypeSessionVideoDisabledByUser) stringValue]: NSLocalizedString(@"User hasn't enabled video stream.", @""),
                      [@(UserErrorTypeGeneralUndefined) stringValue]: NSLocalizedString(@"", @""),
                      [@(UserErrorTypeGeneralNotValidPhoneNumber) stringValue]: NSLocalizedString(@"Phone number is not valid", @""),
                      [@(UserErrorTypeGeneralNotValidVerificationNumber) stringValue]: NSLocalizedString(@"Verification code is not valid", @""),
                      };
}

+ (NSError *)errorForType:(UserErrorType)type
{
    NSInteger code = type;
    NSString *message = errorMessages[[@((NSInteger)type) stringValue]];
    
    if (message == nil)
        message = @"";
    
    return [NSError errorWithDomain:[self domainForType:type] code:code userInfo:@{NSLocalizedDescriptionKey : message}];
}


#pragma mark Private

+ (NSString *)domainForType:(UserErrorType)type
{
    if (type >= UserErrorTypeAPIUndefined && type < UserErrorTypeSocketsUndefined)
        return UserErrorDomainRESTAPI;
    else if (type >= UserErrorTypeSocketsUndefined && type < UserErrorTypeSessionUndefined)
        return UserErrorDomainSocketAPI;
    else if (type >= UserErrorTypeSessionUndefined && type < UserErrorTypeGeneralUndefined)
        return UserErrorDomainCallSession;
    else if (type >= UserErrorTypeGeneralUndefined)
        return UserErrorDomainGeneral;
    else
        return NSStringFromClass([self class]);
}

@end
