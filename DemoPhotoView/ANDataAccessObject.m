//
//  ANDataAccessObject.m
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/31/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ANDataAccessObject.h"

NSString *const ANDAOTempDataAccessed = @"ANDAOTempDataAccessed";

@implementation ANDataAccessObject

+ (id)sharedManager
{
    static ANDataAccessObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initHidden];
    });
    
    return sharedInstance;
}

- (id)initHidden
{
    if (self = [super init]) {
        _imageStorage = [NSMutableArray new];
        _tempImageStorage = [NSMutableArray arrayWithCapacity:20];
    }
    
    return self;
}

- (id)init
{
    NSException *fatalError = [NSException exceptionWithName:@"Fatal Error" reason:@"This is the singleton class, use +(id)sharedManager instead" userInfo:nil];
    [fatalError raise];
    return nil;
}

@end
