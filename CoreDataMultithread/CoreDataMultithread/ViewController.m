//
//  ViewController.m
//  CoreDataMultithread
//
//  Created by CYJ on 16/5/17.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "ViewController.h"
#import "StoreUsingNestedContext.h"
#import "FetchedResultsTableDataSource.h"
#import "Importer.h"
#import "Stop.h"

@interface ViewController ()
{
    __weak IBOutlet UITableView *myTableView;
    StoreUsingNestedContext *storeUsingNestedContext;
    FetchedResultsTableDataSource *dataSource;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storeUsingNestedContext = [StoreUsingNestedContext shareStore];
    
    //创建查询请求
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Stop"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:storeUsingNestedContext.mainQueueContext sectionNameKeyPath:nil cacheName:nil];
    
    //配置tableView数据
    dataSource = [[FetchedResultsTableDataSource alloc] initWithTableView:myTableView fetchedResultsController:fetchController];
    dataSource.configureCellBlock = ^(UITableViewCell *cell, Stop *item){
        cell.textLabel.text = item.name;
    };
    myTableView.dataSource = dataSource;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    
    //开始导入数据
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"stops" ofType:@"txt"];
    Importer *importer = [[Importer alloc] initWithStore:storeUsingNestedContext fileName:fileName];
    importer.progressCallback = ^(float progress){
    
    };
    [importer startOperation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
