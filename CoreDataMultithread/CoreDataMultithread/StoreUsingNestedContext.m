//
//  StoreUsingNestedContext.m
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "StoreUsingNestedContext.h"

@interface StoreUsingNestedContext()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateQueueContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *defaultPrivateQueueContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end

@implementation StoreUsingNestedContext

+ (instancetype)shareStore
{
    static StoreUsingNestedContext *shareStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareStore = [[StoreUsingNestedContext alloc] init];
    });
    return shareStore;
}

- (void)saveContext
{
    NSManagedObjectContext *privateQueueContext = self.privateQueueContext;
    NSManagedObjectContext *mainQueueContext = self.mainQueueContext;
    NSManagedObjectContext *defaultPrivateQueueContext = self.defaultPrivateQueueContext;
    
    __block NSError *error = nil;
    [privateQueueContext performBlockAndWait:^{
        if (![privateQueueContext save:&error]) {
            NSLog(@"error %@ %@",error,[error userInfo]);
            abort();    //异常退出
        }
        
        [mainQueueContext performBlock:^{
            if (![mainQueueContext save:&error]) {
                NSLog(@"error %@ %@",error,[error userInfo]);
                abort();    //异常退出
            }
            
            [defaultPrivateQueueContext performBlock:^{
                
                if (![defaultPrivateQueueContext save:&error]) {
                    NSLog(@"error %@ %@",error,[error userInfo]);
                    abort();    //异常退出
                }
            }];
            
        }];
        
    }];
}

//用于增删改查
- (NSManagedObjectContext *)privateQueueContext
{
    if (!_defaultPrivateQueueContext) {
        _defaultPrivateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _defaultPrivateQueueContext.parentContext = [self mainQueueContext];
    }
    return _defaultPrivateQueueContext;
}

//用于储存
- (NSManagedObjectContext *)defaultPrivateQueueContext
{
    if (!_privateQueueContext) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }
    return _privateQueueContext;
}

//用于UI显示
- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.parentContext = [self defaultPrivateQueueContext];
        
    }
    return _mainQueueContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
 
    //disk sql file name  如果不存在用这个名字创建一个
    NSURL *storeURL = [[self applicationDocumentDirectory] URLByAppendingPathComponent:@"CoreDataMultithread.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"CoreDataMultithread" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    }
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
