//
//  ErrorHandler.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedError.h"
#import "ErrorProcessingRule.h"
#import "ErrorPresentingRule.h"
#import "ErrorPostprocessingRule.h"


extern NSString *const kErrorHandlingPropertyDefaultTitle;
extern NSString *const kErrorHandlingPropertyDefaultMessage;
extern NSString *const kErrorHandlingPropertyDefaultCancelButtonTitle;
extern NSString *const kErrorHandlingPropertyDefaultImportance;

extern NSString *const kErrorHandlingPropertyDisableLoging;
extern NSString *const kErrorHandlingPropertyLogOnlyPresentedErrors; //BOOL default NO

/*!
 Decides what behavior receiver should take when error has undefined presentation permission.
 If YES, such error will be allowed, if NO errors will be denied from presenting.
 Default is YES.
 */
extern NSString *const kErrorHandlingPropertyPresentWhenPermissionIsUndefined; //BOOL default YES

extern NSString *const kErrorHandlingPropertyEnableDebugLogs; //BOOL defaut NO

typedef NSArray<ErrorProcessingRule> *(^OneTimeProcessingRulesBlock)(void);

@class ErrorHandler;
@protocol ErrorHandlerDelegate <NSObject>

@optional
/*! After error is processed, delegate asks if processed error code should be used. Return different code if you don't want the processed one. */
- (NSInteger)errorHandler:(ErrorHandler *)handler codeForError:(CapturedError *)capturedError currentCode:(NSInteger)code;

/*! After error is processed, delegate asks if processed error title should be used. Return different title if you don't want the processed one. */
- (NSString *)errorHandler:(ErrorHandler *)handler titleForError:(CapturedError *)capturedError currentTitle:(NSString *)title;

/*! After error is processed, delegate asks if processed error message should be used. Return different message if you don't want the processed one. */
- (NSString *)errorHandler:(ErrorHandler *)handler messageForError:(CapturedError *)capturedError currentMessage:(NSString *)message;

@end


@protocol ErrorLogger <NSObject>

- (void)logError:(CapturedError *)capturedError withCustomMessage:(NSString *)message;

@end

#pragma mark -

@interface ErrorHandler : NSObject

@property (nonatomic, strong) NSMutableDictionary *handlingProperties;

/*! Rules for processing NSError to CapturedError */
@property (nonatomic, strong) NSMutableArray<ErrorProcessingRule> *processingRules;

/*! Rules for deciding whether error should be presented or not */
@property (nonatomic, strong) NSMutableArray<ErrorPresentingRule> *presentingRules;

@property (nonatomic, strong) NSMutableArray<ErrorPostprocessingRule> *postprocessingRules;

@property (nonatomic, strong) id<ErrorLogger> errorLogger;

@property (nonatomic, weak) id<ErrorHandlerDelegate> delegate;

/*!
 You can use this propety to add one time use processing rules in real time.
 When a block that specifies processing rules is set to this property, these rules will be aplied only once on very first time
 when processError: message is sent to receiver.
 After error is processed, this propety will be automaticaly set to nil and rules will be never aplied again.
 */
@property (nonatomic, copy) OneTimeProcessingRulesBlock oneTimeProcessingRules;

+ (ErrorHandler *)sharedHandler;
+ (void)setSharedHandler:(ErrorHandler *)handler;

+ (instancetype)sharedHandlerWithProperties:(NSDictionary *)properties;

/*! Creates new instance and supplies handler properties. Property keys are starting with kErrorHandlingProperty */
- (instancetype)initWithProperties:(NSDictionary *)properties;

- (CapturedError *)processError:(NSError *)error;

- (BOOL)isErrorAllowedToPresent:(CapturedError *)capturedError;

- (void)presentError:(CapturedError *)capturedError;

- (void)logError:(CapturedError *)capturedError;

- (void)postprocessError:(CapturedError *)capturedError;

/*!
 Handles error. That means, it processes error, present if allowed, logs error and postprocess error.
 For more custom behavior use these methods separately.
 */
- (void)handleError:(NSError *)error;

- (void)handleError:(NSError *)error withCustomTitle:(NSString *)title message:(NSString *)message;

/*! Resets counting of occurences of errors. Counting will start from zero. This method can be issued everytime app resumes from bacground for example. */
- (void)resetErrorOccurenceCounting;

@end
