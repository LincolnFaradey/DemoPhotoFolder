//
//  ANCollectionViewCell.m
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/31/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ANCollectionViewCell.h"

@interface ANCollectionViewCell ()

@property (nonatomic, strong) CALayer *blueDot;

@end

@implementation ANCollectionViewCell
@synthesize blueDot;

// Lazy loading of the imageView
- (UIImageView *) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

- (void)addBlueDot
{
    blueDot = [CALayer layer];
    [blueDot setFrame:CGRectMake(1, 1, 24, 24)];
    blueDot.backgroundColor = [UIColor colorWithHue:0.574 saturation:0.715 brightness:0.922 alpha:1].CGColor;
    blueDot.cornerRadius = 12;
    [self.layer addSublayer:blueDot];
}

- (void)removeBlueDot
{
    [self.blueDot removeFromSuperlayer];
}

@end
