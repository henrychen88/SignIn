//
//  SignController.m
//  SignIn
//
//  Created by Henry on 15-4-3.
//  Copyright (c) 2015年 Henry. All rights reserved.
//

#import "SignController.h"
#import "Sign.h"
#import <FMDB.h>
#import "SignInCell.h"
#import "EditViewController.h"

#import "FMDBHelper.h"

@interface SignController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, assign) NSInteger day, editSection;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *datas;
@property(nonatomic, assign) NSInteger firstDayWeekIndex;
@property(nonatomic, strong) FMDBHelper *dbHelper;
@property(nonatomic, assign) BOOL shouldCloseDB;

@property(nonatomic, assign) NSInteger realYear, realMonth, realDay;
@end

@implementation SignController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    self.datas = [NSMutableArray new];
    [self getDayInfo];
    self.navigationItem.title = FORMAT(@"%@年%@月", self.year, self.month);
    
    self.firstDayWeekIndex = [self weekIndexAboutFirstDayInMonth];
    
    self.datas = [self.dbHelper queryData];
    
/*
    Sign *s = [[Sign alloc]init];
    s.day = 7;
    s.workOn = @"08:44:48";
    s.workOff = @"18:33:28";
    [self.dbHelper updateSign:s];
    
    
    s = [[Sign alloc]init];
    s.day = 8;
    s.workOn = @"08:33:07";
    [self.dbHelper insertSign:s];
    */
    
    NSLog(@"self.datas : %@", self.datas);
    
    [self.view addSubview:self.tableView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.shouldCloseDB = YES;

    if (self.month.integerValue != self.realMonth || self.year.integerValue != self.realYear) {
        return;
    }
    
    if (self.realDay >= 5) {
        NSInteger section = self.realDay + 3;
        NSInteger daysInMonth = [self daysInMonth:self.realMonth] - 1;
        if (section > daysInMonth) {
            section = daysInMonth;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.shouldCloseDB) {
        [self.dbHelper closeDB];
    }
}

- (FMDBHelper *)dbHelper
{
    if (!_dbHelper) {
        _dbHelper = [[FMDBHelper alloc]initWithYear:self.year month:self.month];
    }
    return _dbHelper;
}

- (NSString *)getCurrentTime
{
    NSDate *date = [NSDate new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:date];
}

/**
 *  只能编辑当天都数据
 */
- (BOOL)canEdit:(NSInteger)rowIndex
{
    return (self.year.integerValue == self.realYear && self.month.integerValue == self.realMonth && self.realDay == rowIndex);
    
    // TODO:  xx
}

- (void)getDayInfo
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    self.realYear = [components year];
    self.realMonth = [components month];
    self.realDay = [components day];
}

#pragma mark - UITableView

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:ContentFrame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self daysInMonth:[self.month integerValue]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%ld号", (long)section + 1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    SignInCell *cell = (SignInCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SignInCell alloc]initWithReuseIdentifier:cellIdentifier height:tableView.rowHeight];
    }
    cell.tag = indexPath.section + 1;
    __block SignController *blockSelf = self;
    [cell setSelectBlock:^(NSInteger tag, NSInteger buttonTag) {
        [blockSelf signWithDay:tag action:buttonTag];
    }];
    
    Sign *sign = [[Sign alloc]init];
    for (Sign *s in self.datas) {
        if (s.day == indexPath.section + 1) {
            sign = s;
            break;
        }
    }
    [cell setOn:sign.workOn];
    [cell setOff:sign.workOff];
    
    NSInteger temp = (self.firstDayWeekIndex + indexPath.section) % 7;
    if (!sign.status ||sign.status.length == 0 ) {
        //正常都工作日或者休息日
        if (temp == 1) {
            cell.restReason = @"星期天";
        }else if (temp == 0){
            cell.restReason = @"星期六";
        }else{
            cell.restReason = @"";
        }
        
    }else{
        //工作日变成休息日 或者 休息日变成工作日
        if ([sign.status isEqualToString:@"on"]) {
            //工作
            cell.restReason = @"";
        }else{
            //休息
            cell.restReason = sign.reason;
        }
    }
    
    
    
    return cell;
}

- (void)signWithDay:(NSInteger)day action:(NSInteger)action
{
    Sign *sign = nil;
    for (Sign *s in self.datas) {
        if (s.day == day) {
            sign = s;
            break;
        }
    }
    
    if (action == 3) {
        
        self.editSection = day;
        self.shouldCloseDB = NO;
        
        EditViewController *controller = [[EditViewController alloc]init];
        NSInteger temp = (self.firstDayWeekIndex + day - 1) % 7;
        controller.weekend = (temp == 1 || temp == 0);
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    if (![self canEdit:day]) {
        AlertMessage(@"只能编辑当天都数据");
        return;
    }
    
    if (sign) {
        //有记录 更新数据
        if (action == 1) {
            sign.workOn = [self getCurrentTime];
        }else{
            if (sign.workOn.length == 0) {
                AlertMessage(@"请先记录上班时间");
                return;
            }
            
            NSString *time = [self getCurrentTime];
            if (![self calculateTimeWithOn:sign.workOn off:time]) {
                AlertMessage(@"时间不够 不能下班");
                return;
            }
            
            sign.workOff = [self getCurrentTime];
        }
        if ([self.dbHelper updateSign:sign]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:day - 1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        //没有数据 插入数据
        sign = [[Sign alloc]init];
        sign.day = day;
        if (action == 1) {
            sign.workOn = [self getCurrentTime];
        }else{
            if (sign.workOn.length == 0) {
                AlertMessage(@"请先记录上班时间");
                return;
            }
            
            NSString *time = [self getCurrentTime];
            if (![self calculateTimeWithOn:sign.workOn off:time]) {
                AlertMessage(@"时间不够 不能下班");
                return;
            }
            sign.workOff = [self getCurrentTime];
        }
        if ([self.dbHelper insertSign:sign]) {
            [self.datas addObject:sign];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:day - 1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (BOOL)calculateTimeWithOn:(NSString *)on off:(NSString *)off
{
    NSArray *onArray = [on componentsSeparatedByString:@":"];
    NSArray *offArray = [off componentsSeparatedByString:@":"];
    
    NSInteger interval = ([offArray[0] integerValue] * 3600 + [offArray[1] integerValue] * 60 + [offArray[2] integerValue]) - ([onArray[0] integerValue] * 3600 + [onArray[1] integerValue] * 60 + [onArray[2] integerValue]);
    return interval > 9 * 3600;
}

- (void)editModeWithStatus:(NSString *)status reason:(NSString *)reason
{
    Sign *sign = nil;
    for (Sign *s in self.datas) {
        if (s.day == self.editSection) {
            sign = s;
            break;
        }
    }
    if (!sign) {
        //插入数据
        sign = [[Sign alloc]init];
        sign.day = self.editSection;
        sign.status = status;
        sign.reason = reason;
        if ([self.dbHelper insertSign:sign]) {
            [self.datas addObject:sign];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.editSection - 1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        //更新数据
        sign.status = status;
        sign.reason = reason;
        if ([self.dbHelper updateSign:sign]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.editSection - 1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
}

- (NSInteger)daysInMonth:(NSInteger)month
{
    NSInteger days = 31;
    NSInteger year = [self.year integerValue];
    switch (month) {
        case 4:
        case 6:
        case 9:
        case 11: days = 30; break;
        case 2:
        {
            days = 28;
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                days = 29;
            }
        }
            break;
        default:
            break;
    }
    return days;
}

//获取某个月都第一天是星期几
- (NSInteger)weekIndexAboutFirstDayInMonth
{
    NSString *dateString = FORMAT(@"%@-%@-1", self.year, self.month);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-M-d";
    NSDate *date = [formatter dateFromString:dateString];
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    return [components weekday];
}

@end
