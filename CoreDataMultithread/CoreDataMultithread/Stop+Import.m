//
//  Stop+Import.m
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "Stop+Import.h"

@implementation Stop (Import)

+ (void)importCSVComponents:(NSArray *)components intoContext:(NSManagedObjectContext *)context
{
    NSString *identifier = components[0];
    NSString *name = components[2];
    double latitude = [components[4] doubleValue];
    double longitude = [components[5] doubleValue];
    
    Stop *stop = [self findOrCreateWithIdentifier:identifier inContext:context];
    
    stop.name = name;
    stop.identifier = identifier;
    stop.latitude = @(latitude);
    stop.longitude = @(longitude);
}


+ (instancetype)findOrCreateWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context
{
    NSString *entityName = NSStringFromClass(self);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    // 查找identifier为指定identifier的
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    fetchRequest.fetchLimit = 1;
    
    id object = [[context executeFetchRequest:fetchRequest error:NULL] lastObject];
    if (object == nil) {
        // 插入新的entity
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    
    return object;
}


@end
