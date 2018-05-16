//
//  ListsDownloader.m
//  CheckList
//
//  Created by Eiichi Hayashi on 2018/05/15.
//  Copyright © 2018年 skyElements. All rights reserved.
//

#import "ListsDownloader.h"

@implementation ListsDownloader {
    NSMutableData *mutableData;
}

- (void)startDownloadingLists {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *urlString = @"http://skyelements.jp/app/CheckList/example.json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    mutableData = [[NSMutableData alloc] init];
    
    [task resume];
}

// レスポンス受信時の処理
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);// どのレスポンスが来ても通信を継続
}

// データを受信時の処理
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [mutableData appendData:data];
}

// 通信完了、または失敗時の処理
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        // 成功時の処理
        [self.delegate didFinishDownloadingListsWithData:mutableData];
    } else {
        // 失敗時の処理
        [self.delegate didFailDownloadingLists];
    }
    [session invalidateAndCancel];
}

@end
