//
//  ANDataAccessObject.h
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/31/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ANDAOTempDataAccessed;

@interface ANDataAccessObject : NSObject

@property (nonatomic, strong) NSMutableArray *imageStorage;
@property (nonatomic, strong) NSMutableArray *tempImageStorage;

+ (id)sharedManager;

@end
