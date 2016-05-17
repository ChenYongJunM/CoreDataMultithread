//
//  NSString+ParseCSV.h
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>

// 解析逗号分隔符
@interface NSString (ParseCSV)

- (NSArray *)csvComponents;

@end
