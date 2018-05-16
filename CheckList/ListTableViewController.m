//
//  ListTableViewController.m
//  CheckList
//
//  Created by Eiichi Hayashi on 2018/05/15.
//  Copyright © 2018年 skyElements. All rights reserved.
//

#import "ListTableViewController.h"
// CoreData用
#import "AppDelegate.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController {
    // CoreData用
    AppDelegate *appDelegate;
    NSManagedObjectContext *context;
    
    NSArray *itemsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // CoreDataの準備
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    if (_checkListID && ![_checkListID isEqualToString:@""]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemList"];
        request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES], nil];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemList" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checkListID like %@", _checkListID];
        [request setEntity:entity];
        [request setPredicate:predicate];
        itemsArray = [context executeFetchRequest:request error:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    for (int i = 0; i < itemsArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([[itemsArray[indexPath.row] valueForKey:@"checked"] boolValue]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [itemsArray[indexPath.row] valueForKey:@"item"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *itemID = [itemsArray[indexPath.row] valueForKey:@"itemID"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemList"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemList" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@", itemID];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *result = [context executeFetchRequest:request error:nil];
    NSManagedObject *managedObject = result[0];
    [managedObject setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
    [appDelegate saveContext];
    
    NSInteger selectedRowsCount = [[tableView indexPathsForSelectedRows] count];
    // Complete処理
    if (selectedRowsCount == itemsArray.count) {
        for (NSIndexPath *selectedIndexPath in [tableView indexPathsForSelectedRows]) {
            [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        }
        for (NSManagedObject *managedObject in itemsArray) {
            NSString *itemID = [managedObject valueForKey:@"itemID"];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemList"];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemList" inManagedObjectContext:context];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@", itemID];
            [request setEntity:entity];
            [request setPredicate:predicate];
            NSArray *result = [context executeFetchRequest:request error:nil];
            NSManagedObject *managedObject = result[0];
            [managedObject setValue:[NSNumber numberWithBool:NO] forKey:@"checked"];
            [appDelegate saveContext];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:@"Completed!" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.splitViewController.viewControllers[0] popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *itemID = [itemsArray[indexPath.row] valueForKey:@"itemID"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemList"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemList" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@", itemID];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *result = [context executeFetchRequest:request error:nil];
    NSManagedObject *managedObject = result[0];
    [managedObject setValue:[NSNumber numberWithBool:NO] forKey:@"checked"];
    [appDelegate saveContext];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
