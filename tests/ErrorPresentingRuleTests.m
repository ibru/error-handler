//
//  ErrorPresentingRuleTests.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 28/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ErrorPresentingRule.h"


@interface ErrorPresentingRuleTests : XCTestCase

@end

@implementation ErrorPresentingRuleTests

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

- (void)testDefaultPermissionIsUndefined
{
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    CapturedError *error = [[CapturedError alloc] init];
    
    XCTAssertEqual([rule presentingPermissionForError:error], ErrorPresentingPermissionUndefined, @"Default presenting rule is not Undefined");
}

- (void)testPresentingPermissionForError_importanceDenyEqual
{
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionDeny forCapturedErrorProperty:@"importance"
               relation:ErrorPresentingRelationIsEqual
                  value:@(CapturedErrorImportanceLow)];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.importance = CapturedErrorImportanceLow;
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionDeny;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.importance = CapturedErrorImportanceMedium;
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.importance = CapturedErrorImportanceHigh;
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
}

- (void)testPresentingPermissionForError_importanceAllowGreaterThan
{
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionAllow forCapturedErrorProperty:@"importance"
               relation:ErrorPresentingRelationGreaterThan
                  value:@(CapturedErrorImportanceLow)];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.importance = CapturedErrorImportanceLow;
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionUndefined;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.importance = CapturedErrorImportanceMedium;
    expectedPermisssion = ErrorPresentingPermissionAllow;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.importance = CapturedErrorImportanceHigh;
    expectedPermisssion = ErrorPresentingPermissionAllow;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
}

- (void)testPresentingPermissionForError_lastAppearedAllowGreater
{
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionAllow forCapturedErrorProperty:@"lastAppeared"
               relation:ErrorPresentingRelationGreaterThan
                  value:[NSDate dateWithTimeIntervalSinceNow:-100]];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.lastAppeared = [NSDate dateWithTimeIntervalSinceNow:-200];
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionUndefined;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.lastAppeared = [NSDate dateWithTimeIntervalSinceNow:-50];
    expectedPermisssion = ErrorPresentingPermissionAllow;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
}

- (void)testPresentingPermissionForError_lastAppearedDenySmaller
{
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionDeny forCapturedErrorProperty:@"lastAppeared"
               relation:ErrorPresentingRelationSmallerThan
                  value:[NSDate dateWithTimeIntervalSinceNow:-100]];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.lastAppeared = [NSDate dateWithTimeIntervalSinceNow:-200];
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionDeny;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.lastAppeared = [NSDate dateWithTimeIntervalSinceNow:-50];
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
}

- (void)testPresentingPermissionForError_domainEqual
{
    NSString *domain = @"domain";
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionDeny forCapturedErrorProperty:@"domain"
               relation:ErrorPresentingRelationIsEqual
                  value:domain];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionDeny;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    error.domain = @"asdf";
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
}

- (void)testStaticCreationMethod
{
    NSString *domain = @"domain";
    ErrorPresentingPermission permission = ErrorPresentingPermissionDeny;
    ErrorPresentingRelation relation = ErrorPresentingRelationIsEqual;
    
    id<ErrorPresentingRule> rule1 = [[ErrorPresentingRule alloc] init];
    [rule1 setPermission:permission forCapturedErrorProperty:domain relation:relation value:domain];
    
    id<ErrorPresentingRule> rule2 = [ErrorPresentingRule ruleForCapturedErrorProperty:domain relation:relation value:domain withPermission:permission];
    
    XCTAssertEqualObjects(rule1, rule2, @"");
}

- (void)testRestrictRuleForErrorWithDomainCode
{
    NSString *domain = @"domain";
    NSInteger code = 1234;
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    error.code = code;
    
    id<ErrorPresentingRule> rule = [[ErrorPresentingRule alloc] init];
    [rule setPermission:ErrorPresentingPermissionAllow forCapturedErrorProperty:@"domain" relation:ErrorPresentingRelationIsEqual value:domain];
    
    ErrorPresentingPermission expectedPermisssion = ErrorPresentingPermissionAllow;
    ErrorPresentingPermission actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    [rule restrictRuleForErrorWithDomain:domain code:code - 1]; // restrict for different code
    
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    
    [rule restrictRuleForErrorWithDomain:@"asdf" code:code]; // restrict for different domain
    
    expectedPermisssion = ErrorPresentingPermissionUndefined;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    
    [rule restrictRuleForErrorWithDomain:domain code:NSNotFound]; // restrict only for this domain
    
    expectedPermisssion = ErrorPresentingPermissionAllow;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
    
    [rule restrictRuleForErrorWithDomain:nil code:code]; // restrict only for this code
    
    expectedPermisssion = ErrorPresentingPermissionAllow;
    actualPermission = [rule presentingPermissionForError:error];
    
    XCTAssertEqual(actualPermission, expectedPermisssion, @"");
    
}

@end
