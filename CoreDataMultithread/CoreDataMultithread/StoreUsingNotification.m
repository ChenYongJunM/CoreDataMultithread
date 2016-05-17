//
//  StoreUsingNotification.m
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "StoreUsingNotification.h"


@interface StoreUsingNotification ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *privateQueueContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation StoreUsingNotification

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setupSaveNotification];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSaveNotification
{
    // 当其他线程的context执行改变时，能收到通知
    
    // 1. 注册通知，block方式实现
    //    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
    //                                                      object:nil
    //                                                       queue:nil
    //                                                  usingBlock:^(NSNotification *note) {
    //
    //        // 当前context
    //        NSManagedObjectContext *moc = self.mainManagedObjectContext;
    //
    //        // note.object: 执行改变的context
    //        // 执行改变的context不是当前context
    //        if (note.object != moc) {
    //
    //            // 在当前线程异步执行block
    //            [moc performBlock:^{
    //                // 合并改变
    //                [moc mergeChangesFromContextDidSaveNotification:note];
    //            }];
    //        }
    //    }];
    
    // 2 普通方式
    
    // 接收来自privateQueueContext的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeOperation:) name:NSManagedObjectContextDidSaveNotification object:self.privateQueueContext];
    
    // 接收来自所有context的变化
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeOperation:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

#pragma mark - Notifications

// 当private context执行save操作时main context执行合并
- (void)mergeOperation:(NSNotification *)notification
{
    // 1
    // main context
    NSManagedObjectContext *moc = self.mainQueueContext;
    
    // notification.object: 执行改变的context(这里是private context)
    // 执行改变的context(这里是private context)不是main context
    if (notification.object != moc) {
        // 在moc所在线程（主线程）异步执行block(相当于dispatch_async)，确保操作只在当前线程执行
        [moc performBlock:^{
            // main context合并改变，在主线程运行
            [moc mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
    
    // 2
    //    @synchronized(self) {
    //        [self.mainQueueContext performBlock:^{
    //            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
    //        }];
    //    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.mainQueueContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// main contxt合并后台处理的数据，用于展示信息
- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        // 使用主队列
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _mainQueueContext;
}

// private context用于后台处理数据
- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        // 使用私有队列
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        // 与main context共用一个coordinator
        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _privateQueueContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentDirectory] URLByAppendingPathComponent:@"CoreDataImport.sqlite"];
    
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
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataImport" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
