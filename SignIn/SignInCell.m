//
//  SignInCell.m
//  SignIn
//
//  Created by Henry on 15-4-3.
//  Copyright (c) 2015年 Henry. All rights reserved.
//

#import "SignInCell.h"

#define MENU_WIDTH    80

@interface SignInCell ()
@property(nonatomic, strong) UIButton *workOn, *workOff, *menuButton;
@end

@implementation SignInCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)height
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = self.frame;
        frame.size.height = height;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        self.frame = frame;
        
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    [self.contentView addSubview:self.workOn];
    [self.contentView addSubview:self.workOff];
    [self.contentView addSubview:self.menuButton];
}


- (UIButton *)workOn
{
    if (!_workOn) {
        CGRect frame = self.bounds;
        frame.size.width = (frame.size.width - MENU_WIDTH) / 2;
        _workOn = [[UIButton alloc]initWithFrame:frame];
        [_workOn setTitle:@"上班" forState:UIControlStateNormal];
        [_workOn setBackgroundColor:[UIColor colorWithRed:61 / 255.0f green:177 / 255.0f blue:255 / 255.0f alpha:1]];
        [_workOn setTag:1];
        [_workOn addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _workOn;
}

- (UIButton *)workOff
{
    if (!_workOff) {
        CGRect frame = self.workOn.frame;
        frame.origin.x = frame.size.width;
        _workOff = [[UIButton alloc]initWithFrame:frame];
        [_workOff setTitle:@"下班" forState:UIControlStateNormal];
        [_workOff setBackgroundColor:[UIColor colorWithRed:89 / 255.0f green:64 / 255.0f blue:47 / 255.0f alpha:1]];
        [_workOff setTag:2];
        [_workOff addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _workOff;
}

- (UIButton *)menuButton
{
    if (!_menuButton) {
        _menuButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.workOff.frame), 0, MENU_WIDTH, CGRectGetHeight(self.frame))];
        [_menuButton setBackgroundColor:[UIColor grayColor]];
        [_menuButton setTag:3];
        [_menuButton addTarget:self action:@selector(sign:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (void)sign:(UIButton *)button
{
    if (self.selectBlock) {
        self.selectBlock(self.tag, button.tag);
    }
}

- (void)setOn:(NSString *)on
{
    if (on && on.length > 0) {
        [self.workOn setTitle:on forState:UIControlStateNormal];
    }else{
        [self.workOn setTitle:@"上班" forState:UIControlStateNormal];
    }
}

- (void)setOff:(NSString *)off
{
    if (off && off.length > 0) {
        [self.workOff setTitle:off forState:UIControlStateNormal];
    }else{
        [self.workOff setTitle:@"下班" forState:UIControlStateNormal];
    }
}

- (void)setRestReason:(NSString *)restReason
{
    if (restReason && restReason.length > 0) {
        //当天休息
        self.menuButton.frame = self.bounds;
        self.workOff.frame = CGRectZero;
        self.workOn.frame = CGRectZero;
        [self.menuButton setTitle:restReason forState:UIControlStateNormal];
    }else{
        
        CGRect frame = self.bounds;
        frame.size.width = (frame.size.width - MENU_WIDTH) / 2;
        self.workOn.frame = frame;
        frame.origin.x = frame.size.width;
        self.workOff.frame = frame;
        self.menuButton.frame = CGRectMake(CGRectGetMaxX(self.workOff.frame), 0, MENU_WIDTH, CGRectGetHeight(self.frame));
        [self.menuButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
