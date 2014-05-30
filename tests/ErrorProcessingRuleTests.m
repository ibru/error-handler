//
//  ErrorProcessingRuleTests.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ErrorProcessingRule.h"


@interface ErrorProcessingRuleTests : XCTestCase

@property (nonatomic, strong) ErrorProcessingRule *rule;

@end

@implementation ErrorProcessingRuleTests

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

- (void)testIsValidForDomainCode_ValidDomainCode
{
    NSString *testDomain = @"abcd";
    NSInteger testCode = 123;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:testDomain code:testCode evaluationRules:nil];
    
    XCTAssertTrue([rule isValidForDomain:testDomain code:testCode], @"Rule is not valid for domain: %@, code %ld. But it should.", testDomain, (long)testCode);
}

- (void)testIsValidForDomainCode_NotValidCode
{
    NSString *expectedDomain = @"abcd";
    NSString *actualDomain = @"abcd";
    NSInteger expectedCode = 123;
    NSInteger actualCode = 3456;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:expectedDomain code:expectedCode evaluationRules:nil];
    
    XCTAssertFalse([rule isValidForDomain:actualDomain code:actualCode], @"Rule is valid for domain: %@, code %ld. But it should not.", actualDomain, (long)actualCode);
}

- (void)testIsValidForDomainCode_NotValidDomain
{
    NSString *expectedDomain = @"abcd";
    NSString *actualDomain = @"3456";
    NSInteger expectedCode = 123;
    NSInteger actualCode = 123;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:expectedDomain code:expectedCode evaluationRules:nil];
    
    XCTAssertFalse([rule isValidForDomain:actualDomain code:actualCode], @"Rule is valid for domain: %@, code %ld. But it should not.", actualDomain, (long)actualCode);
}

- (void)testIsValidForDomainCode_NotValidDomainCode
{
    NSString *expectedDomain = @"abcd";
    NSString *actualDomain = @"3456";
    NSInteger expectedCode = 123;
    NSInteger actualCode = 3456;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:expectedDomain code:expectedCode evaluationRules:nil];
    
    XCTAssertFalse([rule isValidForDomain:actualDomain code:actualCode], @"Rule is valid for domain: %@, code %ld. But it should not.", actualDomain, (long)actualCode);
}

- (void)testIsValidForDomainCode_NoCodeSet
{
    NSString *expectedDomain = @"abcd";
    NSString *actualDomain = @"abcd";
    NSInteger expectedCode = NSNotFound;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:expectedDomain code:expectedCode evaluationRules:nil];
    
    XCTAssertTrue([rule isValidForDomain:actualDomain code:345], @"");
    XCTAssertTrue([rule isValidForDomain:actualDomain code:-22], @"");
}

- (void)testIsValidForDomainCode_NoDomainSet
{
    NSString *expectedDomain = nil;
    NSString *actualDomain = @"abcd";
    NSInteger expectedCode = NSNotFound;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:expectedDomain code:expectedCode evaluationRules:nil];
    
    XCTAssertTrue([rule isValidForDomain:actualDomain code:345], @"");
    XCTAssertTrue([rule isValidForDomain:actualDomain code:-22], @"");
    XCTAssertTrue([rule isValidForDomain:@"3ffka;sdkf" code:-22], @"");
}

- (void)testIsValidForDomainCode_multipleCodes
{
    NSString *domain = @"abcd";
    NSArray *codes = @[@(1), @(2), @(4)];
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain codes:codes evaluationRules:nil];
    
    XCTAssertTrue([rule isValidForDomain:domain code:[codes[0] integerValue]], @"");
    XCTAssertTrue([rule isValidForDomain:domain code:[codes[1] integerValue]], @"");
    XCTAssertTrue([rule isValidForDomain:domain code:[codes[2] integerValue]], @"");
    XCTAssertFalse([rule isValidForDomain:domain code:456], @"");
}

- (void)testIsValidForDomainCode_negativeCode
{
    NSString *domain = @"abcd";
    NSInteger code = -10;
    
    ErrorProcessingRule *rule = [ErrorProcessingRule ruleForDomain:domain code:code evaluationRules:nil];
    
    XCTAssertTrue([rule isValidForDomain:domain code:code], @"");
}

- (void)testCapturedError_applyEvaluationRules_importanceRule
{
    CapturedError *error = [[CapturedError alloc] init];
    
    NSDictionary *rules = @{kErrorProcessingEvaluationRuleImportance : @(CapturedErrorImportanceHigh)};
    [error applyEvaluationRules:rules];
    
    CapturedErrorImportance expectedValue = CapturedErrorImportanceHigh;
    CapturedErrorImportance actaulValue = error.importance;
    
    XCTAssertEqual(actaulValue, expectedValue, @"");
    
    
    rules = @{kErrorProcessingEvaluationRuleImportance:@(CapturedErrorImportanceLow)};
    [error applyEvaluationRules:rules];
    
    expectedValue = CapturedErrorImportanceLow;
    actaulValue = error.importance;
    
    XCTAssertEqual(actaulValue, expectedValue, @"");
}

@end
