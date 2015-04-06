//
//  EditViewController.m
//  SignIn
//
//  Created by 諶俭 on 15/4/6.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "EditViewController.h"

#import "SignController.h"

#define EDGE    30

@interface EditViewController ()
@property(nonatomic, strong) UIBarButtonItem *saveButton;
@property(nonatomic, strong) UISwitch *statusSwitch;
@property(nonatomic, strong) UITextField *textField;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"编辑";
    
    self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupContent];
}

- (void)setupContent
{
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(EDGE, 20, 200, 31)];
    statusLabel.text = @"当天是否需要上班";
    [self.view addSubview:statusLabel];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self.statusSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(width - EDGE - 51, 20, 51, 31)];
    [self.view addSubview:self.statusSwitch];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(EDGE, 80, width - 2 * EDGE, 40)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = @"原因";
    [self.textField addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:self.textField];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    [self closeKeyboard];
}

- (void)closeKeyboard
{
    [self.textField resignFirstResponder];
}

- (void)save {
    NSString *text = self.textField.text;
    NSString *status;
    if (!self.statusSwitch.on) {
        if (!self.weekend) {
            if (text.length == 0) {
                AlertMessage(@"请输入原因");
                return;
            }else{
                //工作日不上班
                status = @"off";
            }
        }else{
            //周末不上班
            status = @"";
        }
    }else{
        if (self.weekend) {
            //周日上班
            status = @"on";
        }else{
            //工作日上班
            status = @"";
        }
    }
    if (!text) {
        text = @"";
    }
    NSArray *controllers = [self.navigationController viewControllers];
    SignController *controller = [controllers objectAtIndex:1];
    [controller editModeWithStatus:status reason:text];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
