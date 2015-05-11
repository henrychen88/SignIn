//
//  TodayViewController.m
//  Extension
//
//  Created by Henry on 15-4-20.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "FMDBHelper.h"
#import "NSDate+Help.h"

@interface TodayViewController () <NCWidgetProviding>
@property(nonatomic, strong) FMDBHelper *dbHelper;
@property(nonatomic, strong) NSMutableArray *datas;
@property(nonatomic, strong) UIButton *clickButton;
@end

/**
 *  Today Extension的生命周期
 Widget即将显示在屏幕上会调用viewDidLoad和viewWillAppear方法
 需要注意的是Widget在屏幕上不可见的时候会结束它的生命周期
 不可见包含一下几种情况
 1  切换到“通知”栏目
 2  在“今天”栏目中Widget过多，上下滑动造成的不可见
 3  离开这个通知栏
 */

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake(0, 50);
    
    self.clickButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.clickButton setTitleColor:[UIColor colorWithRed:245 / 255.0 green:184 / 255.0f blue:0 / 255.0f alpha:1] forState:UIControlStateNormal];
    [self.clickButton setTitle:@"打卡" forState:UIControlStateNormal];
    [self.clickButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clickButton];
    
    NSLog(@"ViewDidLoad");
                          
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    NSDictionary *dict = [[NSDate date] seperateComponent];
    
    FMDBHelper *helper = [[FMDBHelper alloc]initWithYear:[dict[COMPONENT_YEAR] integerValue] month:[dict[COMPONENT_MONTH] integerValue]];
    
    NSMutableArray *datas = [helper queryData];
    
    NSInteger dayIndex = [dict[COMPONENT_DAY] integerValue];
    Sign *sign = [[Sign alloc]init];
    for (Sign *s in datas) {
        if (s.day == dayIndex) {
            sign = s;
            break;
        }
    }
    
    NSInteger firstDayWeekIndex = [self weekIndexAboutFirstDayInMonth];
    NSString *title;
    NSInteger temp = (firstDayWeekIndex + dayIndex - 1) % 7;
    if (!sign.status ||sign.status.length == 0 ) {
        //正常都工作日或者休息日
        if (temp == 1) {
            title = @"星期天";
        }else if (temp == 0){
            title = @"星期六";
        }else{
            title = [self descriptionWithSign:sign];
        }
        
    }else{
        //工作日变成休息日 或者 休息日变成工作日
        if ([sign.status isEqualToString:@"on"]) {
            //工作
            title = [self descriptionWithSign:sign];
        }else{
            //休息
            title = sign.reason;
        }
    }
    
    [self.clickButton setTitle:title forState:UIControlStateNormal];
    
}

- (NSString *)descriptionWithSign:(Sign *)sign
{
    NSString *on = sign.workOn;
    NSString *off = sign.workOff;
    if (on.length != 0) {
        if (off.length == 0) {
            return [NSString stringWithFormat:@"上班时间:%@", on];
        }else{
            return [NSString stringWithFormat:@"%@ ~ %@", on, off];
        }
    }
    return @"打卡";
}
                          

/**
 *  获取当月的第一天是星期几
 */
- (NSInteger)weekIndexAboutFirstDayInMonth
{
    NSDate *date = [NSDate date];
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:date];
    NSInteger weekday = [components weekday];
    NSInteger dayIndex = [components day];
    weekday = weekday - dayIndex + 1;
    while (weekday < 1) {
        weekday += 7;
    }
    return weekday;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

- (void)buttonAction
{
    [self.extensionContext openURL:[NSURL URLWithString:@"signtodayextension://action=sign"] completionHandler:^(BOOL success) {
        NSLog(@"Open URL status %d", success);
    }];
}

- (IBAction)sign:(UIButton *)sender {
    [self.extensionContext openURL:[NSURL URLWithString:@"signtodayextension://action=sign"] completionHandler:^(BOOL success) {
        NSLog(@"Open URL status %d", success);
    }];
}
@end
