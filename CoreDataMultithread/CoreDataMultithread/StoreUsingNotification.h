//
//  StoreUsingNotification.h
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

//通知方式CoreData并发
@interface StoreUsingNotification : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *privateQueueContext;

- (void)saveContext;

@end
