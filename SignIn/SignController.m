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

@interface SignController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) FMDatabase *db;
@property(nonatomic, assign) NSInteger day, editSection;
@property(nonatomic, copy) NSString *tableName;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *datas;
@property(nonatomic, assign) NSInteger firstDayWeekIndex;
@end

@implementation SignController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    self.datas = [NSMutableArray new];
    self.navigationItem.title = FORMAT(@"%@年%@月", self.year, self.month);
    
    self.firstDayWeekIndex = [self weekIndexAboutFirstDayInMonth];
    [self openDb];
    [self createTable];
    [self queryData];
    
    NSLog(@"self.datas : %@", self.datas);
    
    [self.view addSubview:self.tableView];
}

- (void)openDb
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fileName = [path stringByAppendingPathComponent:@"sign.db"];
    self.db = [FMDatabase databaseWithPath:fileName];
    [self.db open];
}

- (void)createTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (day integer PRIMARY KEY, workon text, workoff test, status text, reason text)", self.tableName];
    BOOL result = [self.db executeUpdate:sql];
    if (result) {
        NSLog(@"create db success");
    }else{
        NSLog(@"create failed");
    }
}

- (BOOL)insertSign:(Sign *)sign
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (day, workon, workoff, status, reason) VALUES (?,?,?,?,?)", self.tableName];
    BOOL status = [self.db executeUpdate:sql, @(sign.day), sign.workOn, sign.workOff, sign.status, sign.reason];
    NSLog(@"插入数据 %@", [self descriptionWithStatus:status]);
    return status;
}

- (BOOL)updateSign:(Sign *)sign
{
    //更改多个属性 需要注意在中间添加逗号 int等基本类型需要转化成对象类型后才能正确执行
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET workon = ? , workoff = ? , status = ? , reason = ? WHERE day = ?", self.tableName];
    BOOL status = [self.db executeUpdate:sql, sign.workOn, sign.workOff, sign.status, sign.reason, @(sign.day)];
    NSLog(@"修改数据 %@", [self descriptionWithStatus:status]);
    return status;
}

- (void)queryData
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
    FMResultSet *rs = [self.db executeQuery:sql];
    while ([rs next]) {
        Sign *sign = [[Sign alloc]init];
        sign.day = [rs intForColumn:@"day"];
        sign.workOn = [rs stringForColumn:@"workon"];
        sign.workOff = [rs stringForColumnIndex:2];
        sign.status = [rs stringForColumnIndex:3];
        sign.reason = [rs stringForColumnIndex:4];
        NSLog(@"sign %@", sign);
        
        [self.datas addObject:sign];
    }
}

- (NSString *)descriptionWithStatus:(BOOL)status
{
    return status ? @"成功" : @"失败";
}

/*
*   纯数字组成都字符串作为表名在执行sql语句都时候会出错
*/
- (NSString *)tableName
{
    return [NSString stringWithFormat:@"table%@%@", self.year, self.month];
}

- (NSString *)getCurrentTime
{
    NSDate *date = [NSDate new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:date];
}

#pragma mark - UITableView

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
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
        
        EditViewController *controller = [[EditViewController alloc]init];
        NSInteger temp = (self.firstDayWeekIndex + day - 1) % 7;
        controller.weekend = (temp == 1 || temp == 0);
        [self.navigationController pushViewController:controller animated:YES];
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
        if ([self updateSign:sign]) {
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
        if ([self insertSign:sign]) {
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
        if ([self insertSign:sign]) {
            [self.datas addObject:sign];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.editSection - 1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        //更新数据
        sign.status = status;
        sign.reason = reason;
        if ([self updateSign:sign]) {
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

#pragma mark - 增删改查

@end
