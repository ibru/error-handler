//
//  PhoneCompareHelperTests.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 22/03/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PhoneCompareHelper.h"

@interface PhoneCompareHelperTests : XCTestCase

@end

@implementation PhoneCompareHelperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Test cases

- (void)testSanitizedPhoneFromPhone
{
    NSString *phone = @"+1 12-345 (1234) 12";
    NSString *expectedValue = @"+112345123412";
    NSString *actualValue = [PhoneCompareHelper sanitizedPhoneFromPhone:phone];
    
    XCTAssertEqualObjects(actualValue, expectedValue, @"");
}


- (void)testPhoneIsEqualToSanitizedPhone
{
    NSString *sanitizedPhone = @"+420999999999";
    
    NSString *phone = @"999 999 999";
    BOOL expectedResult = YES;
    BOOL actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"+421 999 999 999";
    expectedResult = NO;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"+1 999 999 999";
    expectedResult = NO;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"420 999 999 999";
    expectedResult = YES;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    sanitizedPhone = @"+421999999999";
    
    phone = @"999 999 999";
    expectedResult = YES;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"+421 999 999 999";
    expectedResult = YES;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"421 999 999 999";
    expectedResult = YES;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"+1 999 999 999";
    expectedResult = NO;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"00 421 999 999 999";
    expectedResult = YES;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"011 1 999 999 999";
    expectedResult = NO;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
    
    phone = @"001999999999";
    expectedResult = NO;
    actualResult = [PhoneCompareHelper phone:phone isEqualToSanitizedPhone:sanitizedPhone];
    XCTAssertEqual(actualResult, expectedResult, @"");
}

@end
