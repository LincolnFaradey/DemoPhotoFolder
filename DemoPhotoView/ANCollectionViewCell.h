//
//  ANCollectionViewCell.h
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/31/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (void)addBlueDot;
- (void)removeBlueDot;

@end
