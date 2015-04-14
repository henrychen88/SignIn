//
//  SignController.h
//  SignIn
//
//  Created by Henry on 15-4-3.
//  Copyright (c) 2015年 Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define     FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define     AlertMessage(msg)   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];\
    [alert show];
#define     ContentFrame  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)

/**
 *  打卡 Commit for origin/Test
 */
@interface SignController : UIViewController
@property(nonatomic, copy) NSString *year, *month;
- (void)editModeWithStatus:(NSString *)status reason:(NSString *)reason;
@end
