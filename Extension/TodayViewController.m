//
//  TodayViewController.m
//  Extension
//
//  Created by Henry on 15-4-20.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake(0, 50);
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [button setTitleColor:[UIColor colorWithRed:245 / 255.0 green:184 / 255.0f blue:0 / 255.0f alpha:1] forState:UIControlStateNormal];
    [button setTitle:@"打卡" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
