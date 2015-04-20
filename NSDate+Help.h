//
//  NSDate+Help.h
//  SignIn
//
//  Created by Henry on 15-4-20.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COMPONENT_YEAR          @"component_year"
#define COMPONENT_MONTH     @"component_month"
#define COMPONENT_DAY           @"component_day"

@interface NSDate (Help)

- (NSDictionary *)seperateComponent;

@end
