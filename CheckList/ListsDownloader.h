//
//  ListsDownloader.h
//  CheckList
//
//  Created by Eiichi Hayashi on 2018/05/15.
//  Copyright © 2018年 skyElements. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListsDownloaderDelegate

@optional

- (void)didFinishDownloadingListsWithData:(NSData *)data;
- (void)didFailDownloadingLists;

@end

@interface ListsDownloader : NSObject <NSURLSessionDelegate>

@property (strong, nonatomic) id<ListsDownloaderDelegate> delegate;

- (void)startDownloadingLists;

@end
