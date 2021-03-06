//
//  ViewController.m
//  SignIn
//
//  Created by 諶俭 on 15/4/4.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "ViewController.h"
#import "NSDate+Help.h"
#import "SignController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign) NSInteger year, month, day;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupContent];
}

- (void)setupContent
{
    self.navigationItem.title = @"考勤记录";
    [self getDayInfo];
    [self.view addSubview:self.tableView];
}

- (void)getDayInfo
{
    NSDictionary *dict = [[NSDate date] seperateComponent];
    self.year = [dict[COMPONENT_YEAR] integerValue];
    self.month = [dict[COMPONENT_MONTH] integerValue];
    self.day = [dict[COMPONENT_DAY] integerValue];
    
    // TODO:  xx
}

#pragma mark - UITableView

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:ContentFrame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 9;
    }
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSInteger month = 1;
    if (indexPath.section == 0) {
        month = 4;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld月",  (long)month + indexPath.row];
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SignController *controller = [[SignController alloc]init];
    controller.year = 2015 + indexPath.section;
    NSInteger month = indexPath.row + 1;
    if (indexPath.section == 0) {
        month +=3;
    }
    controller.month= month;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%ld", 2015 + (long)section];
}

@end

