//
//  NSDate+Help.m
//  SignIn
//
//  Created by Henry on 15-4-20.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "NSDate+Help.h"

@implementation NSDate (Help)

- (NSDictionary *)seperateComponent
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*components = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    
    return @{COMPONENT_YEAR : [NSNumber numberWithInteger:[components year]],
             COMPONENT_MONTH : [NSNumber numberWithInteger:[components month]],
             COMPONENT_MONTH : [NSNumber numberWithInteger:[components day]]};
}

@end
