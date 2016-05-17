//
//  Stop+Import.h
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"

@interface Stop (Import)

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)context;

@end
