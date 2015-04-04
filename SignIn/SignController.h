//
//  SignController.h
//  SignIn
//
//  Created by Henry on 15-4-3.
//  Copyright (c) 2015年 Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define     FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

/**
 *  打卡
 */
@interface SignController : UIViewController
@property(nonatomic, copy) NSString *year, *month;
@end
