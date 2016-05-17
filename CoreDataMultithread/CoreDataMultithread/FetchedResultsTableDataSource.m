//
//  FetchedResultsTableDataSource.m
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "FetchedResultsTableDataSource.h"

@interface FetchedResultsTableDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FetchedResultsTableDataSource

- (id)initWithTableView:(UITableView *)tableView fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController
{
    self = [super init];
    
    if (self) {
        self.tableView = tableView;
        self.fetchedResultsController = aFetchedResultsController;
        
        [self setup];
    }
    
    return self;
}

// 配置NSFetchedResultsController
- (void)setup
{
    self.tableView.dataSource = self;
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:NULL];
}

- (id)itemAtIndexPath:(NSIndexPath *)path
{
    return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:path.section]];
}

- (id)selectedItem
{
    return [self itemAtIndexPath:self.tableView.indexPathForSelectedRow];
}

- (void)changePredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = self.fetchedResultsController.fetchRequest;
    fetchRequest.predicate = predicate;
    
    [self.fetchedResultsController performFetch:NULL];
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path
{
    id item = [self itemAtIndexPath:path];
    
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = [self.fetchedResultsController.sections objectAtIndex:section];
    
    return info.name;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        case NSFetchedResultsChangeDelete:
            
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        default:
            break;
    }
}

// 当fetched object更新后save时调用此代理
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([self.tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

@end
