//
//  ErrorHandlerTests.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 28/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ErrorHandler.h"
#import "ErrorProcessingRule.h"


@interface ErrorHandlerTests : XCTestCase

@end

@implementation ErrorHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark Test cases

- (void)testConfigProperty_ErrorHandlingPropertyPresentWhenPermissionIsUndefined
{
    ErrorPresentingRule *rule = [[ErrorPresentingRule alloc] init];
    CapturedError *error = [[CapturedError alloc] init];
    ErrorHandler *handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyPresentWhenPermissionIsUndefined:@(YES)}];
    [handler.presentingRules addObject:rule];
    
    BOOL expectedResult = YES;
    BOOL actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyPresentWhenPermissionIsUndefined:@(NO)}];
    [handler.presentingRules addObject:rule];
    
    expectedResult = NO;
    actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
}

- (void)testMultiplePresentingPermissions_AllowAfterDeny
{
    NSString *domain = @"domain";
    ErrorPresentingRule *rule1 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                           relation:ErrorPresentingRelationIsEqual
                                                                              value:domain
                                                                     withPermission:ErrorPresentingPermissionDeny];
    ErrorPresentingRule *rule2 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionAllow];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    [handler.presentingRules addObject:rule1];
    [handler.presentingRules addObject:rule2];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    
    BOOL expectedResult = YES;
    BOOL actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
}

- (void)testMultiplePresentingPermissions_DenyAfterAllow
{
    NSString *domain = @"domain";
    ErrorPresentingRule *rule1 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionAllow];
    ErrorPresentingRule *rule2 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionDeny];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    [handler.presentingRules addObject:rule1];
    [handler.presentingRules addObject:rule2];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    
    BOOL expectedResult = NO;
    BOOL actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
}

- (void)testMultiplePresentingPermissions_UndefinedAfterAllow
{
    NSString *domain = @"domain";
    ErrorPresentingRule *rule1 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionAllow];
    ErrorPresentingRule *rule2 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionUndefined];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    [handler.presentingRules addObject:rule1];
    [handler.presentingRules addObject:rule2];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    
    BOOL expectedResult = YES;
    BOOL actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
}

- (void)testMultiplePresentingPermissions_UndefinedAfterDeny
{
    NSString *domain = @"domain";
    ErrorPresentingRule *rule1 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionDeny];
    ErrorPresentingRule *rule2 = [ErrorPresentingRule ruleForCapturedErrorProperty:@"domain"
                                                                          relation:ErrorPresentingRelationIsEqual
                                                                             value:domain
                                                                    withPermission:ErrorPresentingPermissionUndefined];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    [handler.presentingRules addObject:rule1];
    [handler.presentingRules addObject:rule2];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    
    BOOL expectedResult = NO;
    BOOL actualResult = [handler isErrorAllowedToPresent:error];
    
    XCTAssertEqual(actualResult, expectedResult, @"");
}

- (void)testProcessError_useDefaultTitleMessage_noTitleMessageSet
{
    NSString *expectedTitle = @"My title";
    NSString *expectedMessage = @"My message";
    NSString *domain = @"domain";
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyDefaultTitle:expectedTitle,
                                                                       kErrorHandlingPropertyDefaultMessage:expectedMessage}];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow)}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    
    NSString *actualTitle = capturedError.title;
    NSString *actualMessage = capturedError.message;
    
    XCTAssertEqualObjects(actualTitle, expectedTitle, @"");
    XCTAssertEqualObjects(actualMessage, expectedMessage, @"");
}

- (void)testProcessError_useDefaultTitleMessage_TitleSetMessageNot
{
    NSString *expectedTitle = @"My title";
    NSString *expectedMessage = @"My message";
    NSString *domain = @"domain";
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyDefaultTitle:@"Some other title",
                                                                       kErrorHandlingPropertyDefaultMessage:expectedMessage}];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow),
                                                                     kErrorProcessingEvaluationRuleTitle:expectedTitle}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    
    NSString *actualTitle = capturedError.title;
    NSString *actualMessage = capturedError.message;
    
    XCTAssertEqualObjects(actualTitle, expectedTitle, @"");
    XCTAssertEqualObjects(actualMessage, expectedMessage, @"");
}

- (void)testProcessError_useDefaultCancelButton
{
    NSString *expectedTitle = @"Cancel";
    NSString *domain = @"domain";
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyDefaultCancelButtonTitle:expectedTitle}];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow)}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    
    XCTAssertTrue([capturedError.buttonTitles count] == 1, @"");
    
    NSString *actualTitle = capturedError.buttonTitles[0];
    
    XCTAssertEqualObjects(actualTitle, expectedTitle, @"");
}

- (void)testProcessError_oneTimeProcessingRule_NoRule
{
    NSString *domain = @"domain";
    CapturedErrorImportance expectedImportance = CapturedErrorImportanceLow;
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(expectedImportance)}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    CapturedErrorImportance actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
    
    handler.oneTimeProcessingRules = ^NSArray *(){
        return nil;
    };
    
    capturedError = [handler processError:error];
    actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
}

- (void)testProcessError_oneTimeProcessingRule_OneRule
{
    NSString *domain = @"domain";
    CapturedErrorImportance expectedImportance = CapturedErrorImportanceLow;
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(expectedImportance)}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    CapturedErrorImportance actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
    
    expectedImportance = CapturedErrorImportanceHigh;
    
    handler.oneTimeProcessingRules = ^NSArray *(){
        ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                                  code:code
                                                       evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(expectedImportance)}];
        return @[rule];
    };
    
    capturedError = [handler processError:error];
    actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
}

- (void)testProcessError_oneTimeProcessingRule_ManyRules
{
    NSString *domain = @"domain";
    CapturedErrorImportance expectedImportance = CapturedErrorImportanceLow;
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(expectedImportance)}];
    [handler.processingRules addObject:rule];
    
    CapturedError *capturedError = [handler processError:error];
    CapturedErrorImportance actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
    
    expectedImportance = CapturedErrorImportanceHigh;
    
    handler.oneTimeProcessingRules = ^NSArray *(){
        ErrorProcessingRule *rule1 = [ErrorProcessingRule ruleForDomain:domain
                                                                   code:code
                                                        evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceMedium)}];
        
        ErrorProcessingRule *rule2 = [ErrorProcessingRule ruleForDomain:domain
                                                                   code:code
                                                        evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow)}];
        
        ErrorProcessingRule *rule3 = [ErrorProcessingRule ruleForDomain:domain
                                                                   code:code
                                                        evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(expectedImportance)}];
        return @[rule1, rule2, rule3];
    };
    
    capturedError = [handler processError:error];
    actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, expectedImportance, @"");
}

- (void)testProcessError_oneTimeProcessingRule_ApplyOnlyOneTime
{
    NSString *domain = @"domain";
    CapturedErrorImportance previousImportance = CapturedErrorImportanceLow;
    CapturedErrorImportance oneTimeImportance = CapturedErrorImportanceMedium;
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                              code:code
                                                   evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(previousImportance)}];
    [handler.processingRules addObject:rule];
    
    handler.oneTimeProcessingRules = ^NSArray *(){
        ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain
                                                                  code:code
                                                       evaluationRules:@{kErrorProcessingEvaluationRuleImportance:@(oneTimeImportance)}];
        return @[rule];
    };
    
    CapturedError *capturedError = [handler processError:error];
    CapturedErrorImportance actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, oneTimeImportance, @"");
    
    capturedError = [handler processError:error];
    actualImportance = capturedError.importance;
    XCTAssertEqual(actualImportance, previousImportance, @"");
}

- (void)testApplyDefaultEvaluationRulesWhenNoEvaluationRulesAreSet
{
    NSString *expectedTitle = @"My title";
    NSString *expectedMessage = @"My message";
    NSString *domain = @"domain";
    NSInteger code = 345;
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    ErrorHandler *handler = [[ErrorHandler alloc] initWithProperties:@{kErrorHandlingPropertyDefaultTitle:expectedTitle,
                                                                       kErrorHandlingPropertyDefaultMessage:expectedMessage}];
    
    CapturedError *capturedError = [handler processError:error];
    
    NSString *actualTitle = capturedError.title;
    NSString *actualMessage = capturedError.message;
    
    XCTAssertEqualObjects(actualTitle, expectedTitle, @"");
    XCTAssertEqualObjects(actualMessage, expectedMessage, @"");
}

- (void)testIncreaseNumberOfOccurencesOfCapturedError
{
    NSError *error = [[NSError alloc] initWithDomain:@"asdf" code:345 userInfo:nil];
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    
    CapturedError *capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 1, @"");
    
    capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 2, @"");
    
    capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 3, @"");
    
}

- (void)testResetErrorOccurenceCounting
{
    NSError *error = [[NSError alloc] initWithDomain:@"asdf" code:345 userInfo:nil];
    ErrorHandler *handler = [[ErrorHandler alloc] init];
    
    CapturedError *capturedError = nil;
    [handler processError:error];
    capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 2, @"");
    
    [handler resetErrorOccurenceCounting];
    
    capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 1, @"");
    
    [handler resetErrorOccurenceCounting];
    
    [handler processError:error];
    [handler processError:error];
    capturedError = [handler processError:error];
    XCTAssertTrue(capturedError.numberOfOccurences == 3, @"");
}

@end
