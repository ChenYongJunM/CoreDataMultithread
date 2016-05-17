//
//  FetchedResultsTableDataSource.h
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ConfigureBlock)(id cell, id item);

@interface FetchedResultsTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) ConfigureBlock configureCellBlock;

- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController;

- (void)changePredicate:(NSPredicate *)predicate;

- (id)selectedItem;

@end
