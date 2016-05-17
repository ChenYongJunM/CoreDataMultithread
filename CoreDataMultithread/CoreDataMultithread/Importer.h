//
//  importer.h
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoreUsingNestedContext;

@interface Importer : NSObject

- (id)initWithStore:(StoreUsingNestedContext *)store fileName:(NSString *)name;

- (void)startOperation;
- (void)cancelOperation;

@property (nonatomic) BOOL isCancelled;
@property (nonatomic) float progress;
@property (nonatomic, copy) void (^progressCallback)(float);

@end
