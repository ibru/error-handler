//
//  CapturedError.m
//  RemoteAssistant
//
//  Created by Jiri Urbasek on 27/02/14.
//  Copyright (c) 2014 Remote Assistant. All rights reserved.
//

#import "CapturedError.h"

@implementation CapturedError

- (instancetype)initWithError:(NSError *)error
{
    if (self = [super init]) {
        _error = error;
        _domain = error.domain;
        _code = error.code;
        _message = [error localizedDescription];
    }
    return self;
}

@end
