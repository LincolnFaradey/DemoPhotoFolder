//
//  ANPhotoCollectionTableViewCell.m
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/29/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ANPhotoCollectionTableViewCell.h"
#import "ANCollectionViewCell.h"
#import "ANDataAccessObject.h"

@interface ANPhotoCollectionTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) ANDataAccessObject *dao;

@end

@implementation ANPhotoCollectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _dao = [ANDataAccessObject sharedManager];
    }

    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _collectionView = [[UICollectionView alloc] initWithFrame:[self collectionRect]
                                         collectionViewLayout:self.flowLayout];
    
    self.collectionView.scrollsToTop = YES;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.canCancelContentTouches = NO;
    [self.collectionView registerClass:[ANCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:self.collectionView];
}


- (CGRect)collectionRect
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height - 180;
    NSUInteger lines = [self.imageStorage count]%4;
    CGFloat estimatedHeight = (screenWidth / 4) * ([self.imageStorage count]/4 + (lines != 0 ? 1 : 0));
    CGRect frame;
    
    if (estimatedHeight >= screenHeight) {
        frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }else {
        frame = CGRectMake(0, 0, screenWidth, estimatedHeight);
    }
    
    return frame;
}



#pragma mark <UICollectionViewDataSource>

static NSString * const reuseIdentifier = @"myCell";
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageStorage count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ANCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIImage *img = self.imageStorage[indexPath.row];
    cell.imageView.image = img;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ANCollectionViewCell *cell = (ANCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ([self.dao.tempImageStorage containsObject:cell.imageView.image]) {
        [cell removeBlueDot];
        [self.dao.tempImageStorage removeObject:cell.imageView.image];
    }else if ([self.dao.tempImageStorage count] != 20){
        [cell addBlueDot];
        [self.dao.tempImageStorage addObject:cell.imageView.image];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:ANDAOTempDataAccessed
                                                                                         object:self]];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellWidth = self.frame.size;
    return CGSizeMake(cellWidth.width/4 - 10, cellWidth.width/4 - 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
}

@end
