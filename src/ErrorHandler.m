//
//  ErrorHandler.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "ErrorHandler.h"


static ErrorHandler *sharedHandler = nil;

#define ERROR_OCCURENCE_COUNT           @"occurenceCount"
#define ERROR_OCCURENCE_LAST_APPEARED   @"occurenceLastAppeared"

NSString *const kErrorHandlingPropertyDefaultTitle                      = @"kErrorHandlingPropertyDefaultTitle";
NSString *const kErrorHandlingPropertyDefaultMessage                    = @"kErrorHandlingPropertyDefaultMessage";
NSString *const kErrorHandlingPropertyDefaultCancelButtonTitle          = @"kErrorHandlingPropertyDefaultCancelButtonTitle";
NSString *const kErrorHandlingPropertyDefaultImportance                 = @"kErrorHandlingPropertyDefaultImportance";

NSString *const kErrorHandlingPropertyDisableLoging                     = @"kErrorHandlingPropertyDisableLoging";
NSString *const kErrorHandlingPropertyLogOnlyPresentedErrors            = @"kErrorHandlingPropertyLogOnlyPresentedErrors";

NSString *const kErrorHandlingPropertyPresentWhenPermissionIsUndefined  = @"kErrorHandlingPropertyPresentWhenPermissionIsUndefined";

NSString *const kErrorHandlingPropertyEnableDebugLogs                   = @"kErrorHandlingPropertyEnableDebugLogs";


@interface ErrorHandler ()

@property (nonatomic, strong) NSMutableDictionary *errorOccurencesTable; //for counting error occurences. Error uniquely identified as 'domain:code'

@end

#pragma mark -

@implementation ErrorHandler

#pragma mark Static

+ (ErrorHandler *)sharedHandler
{
    return sharedHandler;
}

+ (void)setSharedHandler:(ErrorHandler *)handler
{
    sharedHandler = handler;
}

+ (instancetype)sharedHandlerWithProperties:(NSDictionary *)properties
{
    ErrorHandler *handler = [[self alloc] initWithProperties:properties];
    return handler;
}

#pragma mark Init

- (instancetype)init
{
    self = [self initWithProperties:nil];
    if (self) {
    }
    return self;
}

- (instancetype)initWithProperties:(NSDictionary *)properties
{
    if (self = [super init]) {
        _processingRules = (NSMutableArray<ErrorProcessingRule> *)[NSMutableArray array];
        _presentingRules = (NSMutableArray<ErrorPresentingRule> *)[NSMutableArray array];
        _postprocessingRules = (NSMutableArray<ErrorPostprocessingRule> *)[NSMutableArray array];
        
        _handlingProperties = [NSMutableDictionary dictionary];
        _handlingProperties[kErrorHandlingPropertyPresentWhenPermissionIsUndefined] = @(YES);
        _handlingProperties[kErrorHandlingPropertyLogOnlyPresentedErrors] = @(NO);
        _handlingProperties[kErrorHandlingPropertyEnableDebugLogs] = @(NO);
        
        for (NSString *key in [properties allKeys]) {
            _handlingProperties[key] = properties[key];
        }
        
        _errorOccurencesTable = [NSMutableDictionary dictionary];
        
        if (sharedHandler == nil) {
            [ErrorHandler setSharedHandler:self];
        }
    }
    return self;
}

#pragma mark Public

- (CapturedError *)processError:(NSError *)error
{
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Begining processing error: %@:%d", error.domain, (int)error.code);
    
    CapturedError *capturedError = [[CapturedError alloc] initWithError:error];
    
    [self applyDefaultEvaluationRulesForError:capturedError];
    
    for (id<ErrorProcessingRule> rule in self.processingRules) {
        if ([rule isValidForDomain:error.domain code:error.code]) {
            
            if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
                NSLog(@"ErrorHandler: Found valid processing rule: %@", rule);
            
            NSDictionary *evaluationRules = [rule evaluationRules];
            
            [capturedError applyEvaluationRules:evaluationRules];
        }
    }
    
    if (self.oneTimeProcessingRules != nil) {
        for (id<ErrorProcessingRule> rule in self.oneTimeProcessingRules()) {
            if ([rule isValidForDomain:error.domain code:error.code]) {
                
                if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
                    NSLog(@"ErrorHandler: Found valid one time processing rule: %@", rule);
                
                NSDictionary *evaluationRules = [rule evaluationRules];
                
                [capturedError applyEvaluationRules:evaluationRules];
            }
        }
        self.oneTimeProcessingRules = nil;
    }
    
    // update and store numberOfOccurences and lastAppeared
    NSString *errorId = [NSString stringWithFormat:@"%@:%d", capturedError.domain, (int)capturedError.code];
    NSMutableDictionary *errorData = self.errorOccurencesTable[errorId];
    
    if (errorData == nil)
        errorData = [NSMutableDictionary dictionary];
    
    NSInteger occurences = [errorData[ERROR_OCCURENCE_COUNT] integerValue];
    capturedError.numberOfOccurences = occurences + 1;
    errorData[ERROR_OCCURENCE_COUNT] = @(capturedError.numberOfOccurences);
    
    capturedError.lastAppeared = errorData[ERROR_OCCURENCE_LAST_APPEARED];
    errorData[ERROR_OCCURENCE_LAST_APPEARED] = [NSDate date];
    
    self.errorOccurencesTable[errorId] = errorData;
    
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Saving new occurence data: %@", errorData);
    
    
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Processed Captured error object: %@", capturedError);
    
    return capturedError;
}

- (BOOL)isErrorAllowedToPresent:(CapturedError *)capturedError
{
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Detecting permission for presenting captured error.");
    
    ErrorPresentingPermission permission = ErrorPresentingPermissionUndefined;
    ErrorPresentingPermission tmpPermission = ErrorPresentingPermissionUndefined;
    
    for (id<ErrorPresentingRule> rule in self.presentingRules) {
        tmpPermission = [rule presentingPermissionForError:capturedError];
        
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Presenting rule %@ resulted in permission: %@", rule, tmpPermission == ErrorPresentingPermissionAllow ? @"Allow" : (tmpPermission == ErrorPresentingPermissionDeny ? @"Deny" : @"Undefined"));
        
        if (tmpPermission != ErrorPresentingPermissionUndefined) // if it is 'undefined' after 'allow', it result in 'allow'
            permission = tmpPermission;
    }
    
    NSNumber *presentUndefined = self.handlingProperties[kErrorHandlingPropertyPresentWhenPermissionIsUndefined];
    BOOL canPresentUndefined = presentUndefined == nil ? NO : [presentUndefined boolValue];
    
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Final presenting permission is: %@", permission == ErrorPresentingPermissionAllow ? @"Allow" : (permission == ErrorPresentingPermissionDeny ? @"Deny" : @"Undefined"));
    
    return permission == ErrorPresentingPermissionAllow || (permission == ErrorPresentingPermissionUndefined && canPresentUndefined);
}

- (void)presentError:(CapturedError *)capturedError
{
    NSString *message = capturedError.message;
    if (message == nil)
        message = @"";
    
    NSString *title = capturedError.title;
    if (title == nil)
        title = @"Error";
    
    NSString *cancelButtonTitle = @"OK";
    if ([capturedError.buttonTitles count] > 0)
        cancelButtonTitle = capturedError.buttonTitles[0];
    
    NSArray *otherButtonTitles = nil;
    if ([capturedError.buttonTitles count] > 1)
        otherButtonTitles = [capturedError.buttonTitles subarrayWithRange:NSMakeRange(1, [capturedError.buttonTitles count] - 1)];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[NSString stringWithFormat:@"%@ (Error code: %d)", message, (int)capturedError.code]
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for (NSString* buttonTitle in otherButtonTitles) {
        [alert addButtonWithTitle:buttonTitle];
    }
    
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue]) {
        NSMutableString *buttonTitles = [NSMutableString string];
        for (NSInteger i = 0; i < alert.numberOfButtons; i++)
            [buttonTitles appendFormat:@"%@, ", [alert buttonTitleAtIndex:i]];
        [buttonTitles deleteCharactersInRange:NSMakeRange([buttonTitles length] - 2, 2)];
        
        NSLog(@"ErrorHandler: Presenting error with title: %@, message: %@, buttons: %@", title, message, buttonTitles);
    }
    [alert show];
}

- (void)logError:(CapturedError *)capturedError
{
    if ([self.handlingProperties[kErrorHandlingPropertyDisableLoging] boolValue] == NO)
        return;
    
    if (self.errorLogger != nil) {
        [self.errorLogger logError:capturedError withCustomMessage:nil];
    }
    else {
        NSLog(@"Error: %@ [%@]", capturedError, capturedError.error);
    }
}

- (void)postprocessError:(CapturedError *)capturedError
{
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Walking throught postprocession rules.");
    
    for (id<ErrorPostprocessingRule> rule in self.postprocessingRules) {
        
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Found postprocession rule: %@", rule);
        
        if ([rule isValidForCapturedError:capturedError]) {
            if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
                NSLog(@"ErrorHandler: Executing this postprocession rule.");
            [rule execute];
        }
    }
    // Nothing to do yet
}

- (void)handleError:(NSError *)error
{
    [self handleError:error withCustomTitle:nil message:nil];
}

- (void)handleError:(NSError *)error withCustomTitle:(NSString *)title message:(NSString *)message
{
    if (error == nil) {
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Hadling nil error - nothing to do.");
        
        return;
    }
    else {
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Handling error: %@ With custom title: %@, message: %@", error, title, message);
    }
    
    CapturedError *capturedError = [self processError:error];
    
    //TODO: should we use delegate or is it better to provide only custom title, message, code in method arguments?
    
    // allow delegate to alter code title and message
    if ([self.delegate respondsToSelector:@selector(errorHandler:codeForError:currentCode:)])
        capturedError.code = [self.delegate errorHandler:self codeForError:capturedError currentCode:capturedError.code];
    if ([self.delegate respondsToSelector:@selector(errorHandler:titleForError:currentTitle:)])
        capturedError.title = [self.delegate errorHandler:self titleForError:capturedError currentTitle:capturedError.title];
    if ([self.delegate respondsToSelector:@selector(errorHandler:messageForError:currentMessage:)])
        capturedError.message = [self.delegate errorHandler:self messageForError:capturedError currentMessage:capturedError.message];
    
    // title and message received in method params have highest priority
    if (title != nil)
        capturedError.title = title;
    if (message != nil)
        capturedError.message = message;
    
    BOOL canPresent = [self isErrorAllowedToPresent:capturedError];
    if (canPresent)
        [self presentError:capturedError];
    else {
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Error not presented.");
    }
    
    if (canPresent || (!canPresent && ![self.handlingProperties[kErrorHandlingPropertyLogOnlyPresentedErrors] boolValue]))
        [self logError:capturedError];
    else {
        if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
            NSLog(@"ErrorHandler: Error not logged.");
    }
    
    [self postprocessError:capturedError];
}

- (void)resetErrorOccurenceCounting
{
    [self.errorOccurencesTable removeAllObjects];
}

#pragma mark Private

- (void)applyDefaultEvaluationRulesForError:(CapturedError *)capturedError
{
    if ([self.handlingProperties[kErrorHandlingPropertyEnableDebugLogs] boolValue])
        NSLog(@"ErrorHandler: Applying default evaluation rules: %@", self.handlingProperties);
    
    if ([self.handlingProperties[kErrorHandlingPropertyDefaultTitle] isKindOfClass:[NSString class]])
        capturedError.title = self.handlingProperties[kErrorHandlingPropertyDefaultTitle];
    
    if ([self.handlingProperties[kErrorHandlingPropertyDefaultMessage] isKindOfClass:[NSString class]])
        capturedError.message = self.handlingProperties[kErrorHandlingPropertyDefaultMessage];
    
    if ([self.handlingProperties[kErrorHandlingPropertyDefaultCancelButtonTitle] isKindOfClass:[NSString class]]) {
        
        NSArray *buttonTitles = nil;
        if ([capturedError.buttonTitles count] > 0) {
            buttonTitles = [NSMutableArray arrayWithArray:capturedError.buttonTitles];
            ((NSMutableArray *)buttonTitles)[0] = self.handlingProperties[kErrorHandlingPropertyDefaultCancelButtonTitle];
        }
        else
            buttonTitles = @[self.handlingProperties[kErrorHandlingPropertyDefaultCancelButtonTitle]];
            
        capturedError.buttonTitles = buttonTitles;
    }
    
    if ([self.handlingProperties[kErrorHandlingPropertyDefaultImportance] isKindOfClass:[NSNumber class]])
        capturedError.importance = (CapturedErrorImportance)[self.handlingProperties[kErrorHandlingPropertyDefaultImportance] integerValue];
}

@end

