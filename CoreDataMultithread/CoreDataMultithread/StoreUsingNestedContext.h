//
//  StoreUsingNestedContext.h
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreUsingNestedContext : NSObject

+ (instancetype)shareStore;

- (void)saveContext;

//对外readonly
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *privateQueueContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *defaultPrivateQueueContext;

@end
