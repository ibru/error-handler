//
//  ErrorPostprocessingRuleTests.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 10/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ErrorPostprocessingRule.h"

@interface ErrorPostprocessingRuleTests : XCTestCase

@end

@implementation ErrorPostprocessingRuleTests

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

- (void)testIsValidForCapturedError_oneConstraint
{
    ErrorPostprocessingConstraint *constraint = [ErrorPostprocessingConstraint constraintWithProperty:@"title"
                                                                                             relation:ErrorPostprocessingRelationIsEqual
                                                                                                value:@"abcd"];
    CapturedError *error = [[CapturedError alloc] init];
    error.title = @"abcd";
    
    ErrorPostprocessingRule *rule = [ErrorPostprocessingRule ruleThatSatisfiesConstraints:@[constraint] execution:nil];
    
    XCTAssertTrue([rule isValidForCapturedError:error], @"");
    error.title = @"asdfasdfaf";
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
    
    constraint = [ErrorPostprocessingConstraint constraintWithProperty:@"importance"
                                                              relation:ErrorPostprocessingRelationIsEqual
                                                                 value:@(CapturedErrorImportanceHigh)];
    rule = [ErrorPostprocessingRule ruleThatSatisfiesConstraints:@[constraint] execution:nil];
    error = [[CapturedError alloc] init];
    error.importance = CapturedErrorImportanceHigh;
    
    XCTAssertTrue([rule isValidForCapturedError:error], @"");
    error.importance = CapturedErrorImportanceLow;
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
    
    constraint = [ErrorPostprocessingConstraint constraintWithProperty:@"numberOfOccurences"
                                                              relation:ErrorPostprocessingRelationGreaterThan
                                                                 value:@(2)];
    rule = [ErrorPostprocessingRule ruleThatSatisfiesConstraints:@[constraint] execution:nil];
    error = [[CapturedError alloc] init];
    error.numberOfOccurences = 4;
    
    XCTAssertTrue([rule isValidForCapturedError:error], @"");
    error.numberOfOccurences = 2;
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
}

- (void)testIsValidForCapturedError_ConstraintsDomainCodeOccurences
{
    NSString *domain = @"domain";
    NSInteger code = 123;
    NSInteger numberOfOccurences = 2;
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"domain" relation:ErrorPostprocessingRelationIsEqual value:domain]];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"code" relation:ErrorPostprocessingRelationIsEqual value:@(code)]];
    [constraints addObject:[ErrorPostprocessingConstraint constraintWithProperty:@"numberOfOccurences" relation:ErrorPostprocessingRelationGreaterThan value:@(numberOfOccurences)]];
    ErrorPostprocessingRule *rule = [ErrorPostprocessingRule ruleThatSatisfiesConstraints:constraints execution:nil];
    
    CapturedError *error = [[CapturedError alloc] init];
    error.domain = domain;
    error.code = code;
    error.numberOfOccurences = numberOfOccurences + 1;
    
    XCTAssertTrue([rule isValidForCapturedError:error], @"");
    
    // check that different title does not change result
    error.title = @"asdfaf";
    XCTAssertTrue([rule isValidForCapturedError:error], @"");
    
    // change properties so that rule should be not valid for error
    error.numberOfOccurences--;
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
    
    error.numberOfOccurences++;
    error.domain = @"asdf";
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
    
    error.domain = domain;
    error.code += 10;
    XCTAssertFalse([rule isValidForCapturedError:error], @"");
}

@end
