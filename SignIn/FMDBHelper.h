//
//  FMDBHelper.h
//  SignIn
//
//  Created by Henry on 15-4-7.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "Sign.h"


/**
 *  对数据库的操作
 */
@interface FMDBHelper : NSObject
@property(nonatomic, copy) NSString *year;
@property(nonatomic, copy) NSString *month;

- (id)initWithYear:(NSString *)year month:(NSString *)month;

- (BOOL)insertSign:(Sign *)sign;

- (BOOL)updateSign:(Sign *)sign;

- (NSMutableArray *)queryData;

- (void)closeDB;

@end
