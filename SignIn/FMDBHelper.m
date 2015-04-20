//
//  FMDBHelper.m
//  SignIn
//
//  Created by Henry on 15-4-7.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "FMDBHelper.h"

@interface FMDBHelper ()
@property(nonatomic, strong) FMDatabase *db;
@property(nonatomic, copy) NSString *tableName;
@end

@implementation FMDBHelper

- (id)initWithYear:(NSInteger)year month:(NSInteger)month
{
    self = [super init];
    if (self) {
        self.year = [NSString stringWithFormat:@"%ld", (long)year];
        self.month = [NSString stringWithFormat:@"%ld", (long)month];
        [self openDb];
        [self createTable];
    }
    return self;
}

/*
 *   纯数字组成都字符串作为表名在执行sql语句都时候会出错
 */
- (NSString *)tableName
{
    return [NSString stringWithFormat:@"table%@%@", self.year, self.month];
}

/**
 *  打开数据库
 */
- (void)openDb
{
    /*
     NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
     NSString *fileName = [path stringByAppendingPathComponent:@"sign.db"];
     */
    //使用 App Groups 来保存数据
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.ichint.signin"];
    NSString *path = [[containerURL URLByAppendingPathComponent:@"signin.db"] absoluteString];
    self.db = [FMDatabase databaseWithPath:path];
    [self.db open];
}

- (void)closeDB
{
    [self.db close];
}

/**
 *  创建表(如果表不存在)
 */
- (void)createTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (day integer PRIMARY KEY, workon text, workoff test, status text, reason text)", self.tableName];
    BOOL result = [self.db executeUpdate:sql];
    NSLog(@"创建表 %@", [self descriptionWithStatus:result]);
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

- (NSMutableArray *)queryData
{
    NSMutableArray *datas = [[NSMutableArray alloc]init];
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
        
        [datas addObject:sign];
    }
    return datas;
}

- (NSString *)descriptionWithStatus:(BOOL)status
{
    return status ? @"成功" : @"失败";
}

@end
