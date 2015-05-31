//
//  ANDownloader.h
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/30/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ANDownloaderCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);
extern NSString *const ANLoaderDownloadFinished;
extern NSString *const ANLoaderFetcherFinished;

@interface ANLoader : NSObject

- (void)downloadImagesWith:(NSUInteger)amount;
- (void)saveImages:(NSArray *)images;
- (void)runFetcher;

@end
