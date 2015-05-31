//
//  ANDownloader.m
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/30/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ANLoader.h"
#import <UIKit/UIKit.h>
#import "ANDataAccessObject.h"

NSString *const ANLoaderDownloadFinished = @"ANLoaderDownloadFinished";
NSString *const ANLoaderFetcherFinished = @"ANLoaderDownloadFinished";

@interface ANLoader ()

@property (nonatomic, assign) NSUInteger folderCount;

@end
@implementation ANLoader

- (instancetype)init
{
    if (self = [super init]) {
        _folderCount = 800;
    }
    
    return self;
}

- (void)downloadImagesWith:(NSUInteger)amount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 200; i <= _folderCount; i += 50) {
            [self download:amount toFolder:i];
        }
        [self runFetcher];
    });
}

- (void)download:(NSUInteger)photoNum toFolder:(NSUInteger)folderNum
{
    NSError *error = nil;
    NSString *path = [NSString stringWithFormat:@"%@/%lu/", NSTemporaryDirectory(), (unsigned long)folderNum];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                       withIntermediateDirectories:NO
                                        attributes:nil
                                             error:&error];
    [self downloadImages:photoNum InFolder:[NSString stringWithFormat:@"%lu", (unsigned long)folderNum]];

}

- (void)downloadImages:(NSUInteger)amount InFolder:(NSString *)path
{
    if (amount == 0) return;
    
    NSURL *url = [[NSURL URLWithString:@"http://placekitten.com/g/"] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%lu", path, amount+301]];
    
    NSError *error;
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%lu.jpg", path, (unsigned long)amount]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if ([data length] > 0)
            [data writeToFile:tmpPath options:NSDataWritingAtomic error:&error];
    }

    [self downloadImages:amount-1 InFolder:path];

}

- (void)saveImages:(NSArray *)images
{
    NSError *error = nil;
    NSString *folderName =[NSString stringWithFormat:@"%lu", [[[ANDataAccessObject sharedManager] imageStorage] count]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", folderName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&error];
    
    for (UIImage *img in images) {
        NSData *data = UIImageJPEGRepresentation(img, 0.0);
        NSString *name = [NSString stringWithFormat:@"%u", arc4random()%100000];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg", path, name];
        
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
}

- (void)runFetcher
{
    [[[ANDataAccessObject sharedManager] imageStorage] removeAllObjects];
    [self imageFoldersForPath:NSTemporaryDirectory()];
}

- (void)imageFoldersForPath:(NSString *)strPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:strPath error:nil];
    NSLog(@"%@", dirs);
    for (NSString *folderStringPath in dirs) {
        NSString *folderPath = [strPath stringByAppendingPathComponent:folderStringPath];
        [[[ANDataAccessObject sharedManager] imageStorage] addObject:[self fetchImagesAtPath:folderPath withFileManager:fileManager]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ANLoaderFetcherFinished
                                                                                         object:self]];
    
}


- (NSArray *)fetchImagesAtPath:(NSString *)path withFileManager:(NSFileManager *)fileManager
{
    NSMutableArray *images = [NSMutableArray array];
    NSArray *dirs = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *fileStringPath in dirs) {
        NSString *fullPath = [path stringByAppendingPathComponent:fileStringPath];
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            [images addObject:image];
        else {
            NSLog(@"%s", __FUNCTION__);
        }
    }

    return images;
}



@end
