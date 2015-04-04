//
//  Sign.m
//  SignIn
//
//  Created by 諶俭 on 15/4/4.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "Sign.h"

@implementation Sign

- (id)init
{
    self = [super init];
    if (self) {
        self.day = 0;
        self.workOn = @"";
        self.workOff = @"";
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Sign{day:%ld, on:%@, off:%@}", (long)self.day, self.workOn, self.workOff];
}

@end
