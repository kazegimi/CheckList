//
//  ListsTableViewController.h
//  CheckList
//
//  Created by Eiichi Hayashi on 2018/05/15.
//  Copyright © 2018年 skyElements. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListTableViewController.h"

#import "ListsDownloader.h"

@interface ListsTableViewController : UITableViewController <ListsDownloaderDelegate>

- (IBAction)refresh:(id)sender;

@end
