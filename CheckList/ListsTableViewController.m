//
//  ListsTableViewController.m
//  CheckList
//
//  Created by Eiichi Hayashi on 2018/05/15.
//  Copyright © 2018年 skyElements. All rights reserved.
//

#import "ListsTableViewController.h"
// CoreData用
#import "AppDelegate.h"

@interface ListsTableViewController ()

@end

@implementation ListsTableViewController {
    // CoreData用
    AppDelegate *appDelegate;
    NSManagedObjectContext *context;
    
    NSArray *checkListsArray;
    ListsDownloader *listsDownloader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    listsDownloader = [[ListsDownloader alloc] init];
    listsDownloader.delegate = self;
    
    // CoreDataの準備
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    [self reload];
}

- (IBAction)refresh:(id)sender {
    [listsDownloader startDownloadingLists];
}

- (void)reload {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TitleList"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TitleList" inManagedObjectContext:context];
    [request setEntity:entity];
    checkListsArray = [context executeFetchRequest:request error:nil];
    [self.tableView reloadData];
}

- (void)didFinishDownloadingListsWithData:(NSData *)data {
    NSDictionary *listsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *titleList = listsDictionary[@"TitleList"];
    for (NSDictionary *titleDictionary in titleList) {
        NSString *checkListID = titleDictionary[@"checkListID"];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TitleList"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TitleList" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checkListID like %@", checkListID];
        [request setEntity:entity];
        [request setPredicate:predicate];
        NSArray *result = [context executeFetchRequest:request error:nil];
        NSManagedObject *managedObject;
        if (result.count == 0) {
            managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TitleList" inManagedObjectContext:context];
        } else {
            managedObject = result[0];
        }
        [managedObject setValue:titleDictionary[@"checkListID"] forKey:@"checkListID"];
        [managedObject setValue:titleDictionary[@"title"] forKey:@"title"];
        [appDelegate saveContext];
    }
    
    NSArray *itemList = listsDictionary[@"ItemList"];
    for (NSDictionary *itemDictionary in itemList) {
        NSString *itemID = itemDictionary[@"itemID"];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemList"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemList" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@", itemID];
        [request setEntity:entity];
        [request setPredicate:predicate];
        NSArray *result = [context executeFetchRequest:request error:nil];
        NSManagedObject *managedObject;
        if (result.count == 0) {
            managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ItemList" inManagedObjectContext:context];
        } else {
            managedObject = result[0];
        }
        [managedObject setValue:itemDictionary[@"itemID"] forKey:@"itemID"];
        [managedObject setValue:itemDictionary[@"checkListID"] forKey:@"checkListID"];
        [managedObject setValue:itemDictionary[@"order"] forKey:@"order"];
        [managedObject setValue:itemDictionary[@"item"] forKey:@"item"];
        [managedObject setValue:itemDictionary[@"checked"] forKey:@"checked"];
        [appDelegate saveContext];
    }
    
    [self reload];
    [self.refreshControl endRefreshing];
}

- (void)didFailDownloadingLists {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed Downloading" message:@"Check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.refreshControl endRefreshing];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return checkListsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [checkListsArray[indexPath.row] valueForKey:@"title"];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ListSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UINavigationController *navigationController = segue.destinationViewController;
        ListTableViewController *listTableViewController = (ListTableViewController *)navigationController.topViewController;
        listTableViewController.checkListID = [checkListsArray[indexPath.row] valueForKey:@"checkListID"];
        listTableViewController.title = [checkListsArray[indexPath.row] valueForKey:@"title"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
