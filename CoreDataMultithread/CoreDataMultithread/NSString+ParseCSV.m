//
//  NSString+ParseCSV.m
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "NSString+ParseCSV.h"

@implementation NSString (ParseCSV)

- (NSArray *)csvComponents
{
    NSMutableArray *componets = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    NSString *quote = @"\"";
    NSString *seperator = @",";
    NSString *result;
    
    while (![scanner isAtEnd]) {
        if ([scanner scanString:quote intoString:NULL]) {  // 如果扫描到了quote
            [scanner scanUpToString:quote intoString:&result];
            [scanner scanString:quote intoString:NULL];
        } else {                               
            [scanner scanUpToString:seperator intoString:&result];
        }
        [scanner scanString:seperator intoString:NULL];
        [componets addObject:result];
    }
    
    return componets;
}

@end
