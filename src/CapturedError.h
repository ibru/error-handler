//
//  CapturedError.h
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CapturedErrorImportance) {
    CapturedErrorImportanceLow,
    CapturedErrorImportanceMedium,
    CapturedErrorImportanceHigh,
};

@interface CapturedError : NSObject

@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) CapturedErrorImportance importance;

@property (nonatomic, assign) NSInteger numberOfOccurences;

@property (nonatomic, strong) NSDate *lastAppeared;

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger code;

@property (nonatomic, strong) NSArray *buttonTitles;

// property: touchHandlerBlock:^(int buttonIdx) <-- for handling button touch on alert view


- (instancetype)initWithError:(NSError *)error;

@end
