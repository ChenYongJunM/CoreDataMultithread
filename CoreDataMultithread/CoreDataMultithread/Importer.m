//
//  importer.m
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "Importer.h"
#import "StoreUsingNestedContext.h"
#import "NSString+ParseCSV.h"
#import "Stop.h"
#import "Stop+Import.h"

static const int ImportBatchSize = 250;

@interface Importer ()

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) StoreUsingNestedContext *storeUsingNestedContext;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation Importer

- (id)initWithStore:(StoreUsingNestedContext *)store fileName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        self.storeUsingNestedContext = store;
        self.fileName = name;
    }
    
    return self;
}

- (void)startOperation
{
    // 使用私有的context
    self.context = [[StoreUsingNestedContext shareStore] privateQueueContext];
    
    // 在self.context所在线程异步执行block(相当于dispatch_async)
    [self.context performBlock:^{
        // 导入数据，在context所在线程运行
        [self import];
    }];
}

- (void)cancelOperation
{
    self.isCancelled = YES;
}

- (void)import
{
    NSString *fileContents = [NSString stringWithContentsOfFile:self.fileName encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger count = lines.count;
    
    // Granularity:间隔
    NSInteger progressGranularity = count/100;
    
    __block NSInteger idx = -1;
    
    [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *shouldStop) {
        
        idx++;
        
        if (idx == 0) {
            return;
        }
        
        if (self.isCancelled) {
            *shouldStop = YES;
            return;
        }
        
        NSArray *components = [line csvComponents];
        
        if (components.count < 5) {
            NSLog(@"couldn't parse: %@", components);
            return;
        }
        
        // 导入CSV
        [Stop importCSVComponents:components intoContext:self.context];
        
        // 降低更新的频度，每导入100行时更新一次
        if (idx % progressGranularity == 0) {
            self.progressCallback(idx / (float)count);
        }
        
        // 每250次导入就保存一次
        //        if (idx % ImportBatchSize == 0) {
        [self.storeUsingNestedContext saveContext];
        //        }
        
    }];
    
    // 执行完上面的遍历再执行下面
    self.progressCallback(1);
    
    [self.storeUsingNestedContext saveContext];
}

@end
