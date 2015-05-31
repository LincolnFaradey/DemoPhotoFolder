//
//  ANPhotoCollectionTableViewCell.h
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/29/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPhotoCollectionTableViewCell : UITableViewCell 

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imageStorage;
@property (nonatomic, assign) CGPoint cellPosition;

- (CGRect)collectionRect;

@end
