//
//  SignInCell.h
//  SignIn
//
//  Created by Henry on 15-4-3.
//  Copyright (c) 2015年 Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectBlock)(NSInteger tag, NSInteger buttonTag);

@interface SignInCell : UITableViewCell
@property(nonatomic, copy) NSString *on, *off;
@property(nonatomic, copy) SelectBlock selectBlock;
@property(nonatomic, copy) NSString *restReason;
- (void)setSelectBlock:(SelectBlock)selectBlock;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)height;

@end
