//
//  UserLocalizedError.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 24/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserErrorDomainRESTAPI;
extern NSString *const UserErrorDomainSocketAPI;
extern NSString *const UserErrorDomainCallSession;
extern NSString *const UserErrorDomainGeneral;

typedef NS_ENUM(NSInteger, UserErrorType) {
    UserErrorTypeAPIUndefined                               = 410,
    UserErrorTypeAPIUserNotAuthenticated                    = 411,
    UserErrorTypeAPIDataForAuthenticationNotProvided,
    UserErrorTypeAPIUserNotIdentified,
    
    UserErrorTypeSocketsUndefined                           = 420,
    UserErrorTypeSocketsUserNotAuthenticated                = 421,
    UserErrorTypeSocketsCallCommandNotValid,
    
    UserErrorTypeSessionUndefined                           = 450,
    UserErrorTypeSessionCallerUnknown,
    UserErrorTypeSessionCommandUndefined                    = 460,
    UserErrorTypeSessionCommandCommandNotSuported,
    
    UserErrorTypeSessionVideoDisabledByUser,
    
    UserErrorTypeGeneralUndefined                           = 480,
    UserErrorTypeGeneralNotValidPhoneNumber                 = 481,
    UserErrorTypeGeneralNotValidVerificationNumber,
};

@interface UserLocalizedError : NSObject

+ (NSError *)errorForType:(UserErrorType)type;

@end
