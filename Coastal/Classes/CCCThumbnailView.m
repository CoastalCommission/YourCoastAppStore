//
//  CCCThumbnailView.m
//  Coastal
//
//  Created by Aaron Williams on 2016-09-16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCThumbnailView.h"
#import "NSLayoutConstraint+MLX.h"
#import "UIView+MLX.h"
#import "CCCImageManager.h"
#import "CCCPhoto.h"
#import "NYTPhotoCaptionViewLayoutWidthHinting.h"

@interface CCCThumbnailView()

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIStackView *imageStackView;
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation CCCThumbnailView

- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];

    if (self != nil)
    {
        self.shouldDimUnselected = NO;
        [self addSubview: self.imageScrollView];
        [self.imageScrollView addSubview:self.imageStackView];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    [self mlx_addConstraintsIfNeeded];

    [super updateConstraints];
}

- (NSArray *)mlx_constraints
{
    NSMutableArray *constraints = [[super mlx_constraints] mutableCopy];
    {
        NSDictionary *formats = @{
                                  @"V:|[imageScrollView]|": @0,
                                  @"H:|[imageScrollView]|": @0,

                                  @"V:|[imageStackView]|": @0,
                                  @"H:|[imageStackView]|": @0,
                                  };

        NSDictionary *metrics = @{
                                  };

        NSDictionary *views = MLXDictionaryOfPropertyBindings(
                                                              self.imageScrollView,
                                                              self.imageStackView
                                                              );

        [constraints addObjectsFromArray:[NSLayoutConstraint mlx_constraintsWithVisualFormatsAndOptions:formats
                                                                                                metrics:metrics
                                                                                                  views:views]];
    }
    return constraints;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.imageStackView.frame.size.width, 80);
}

#pragma mark - Actions

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    self.imageScrollView.contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)scrollToImageAtIndex:(NSInteger)index
{
    UIImageView *selectedImageView = self.imageStackView.arrangedSubviews[index];
    for (UIImageView *imageView in self.imageStackView.arrangedSubviews)
    {
        if (imageView == selectedImageView)
        {
            imageView.alpha = 1.0;
        }
        else
        {
            imageView.alpha = 0.5;
        }
    }

    CGRect imageRect = selectedImageView.frame;
    CGFloat xOffset = imageRect.origin.x - (self.frame.size.width / 2) + (imageRect.size.width / 2);
    [UIView animateWithDuration:0.4 animations:^{
        self.imageScrollView.contentOffset = CGPointMake(xOffset, imageRect.origin.y);
    }];
}

- (void)imageSelected:(UIGestureRecognizer *)sender
{
    UIImageView *imageView = (UIImageView *)sender.view;
    NSUInteger index = [self.imageStackView.arrangedSubviews indexOfObject:imageView];
    [self.delegate thumbnailView:self didSelectImage:self.photos[index] AtIndex:index];
}

- (void)addPhoto:(CCCPhoto *)photo
{
    UIImage *image = photo.image;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;

    if (self.shouldDimUnselected == YES)
    {
        imageView.alpha = 0.5;
    }

    [imageView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSelected:)]];

    [imageView.heightAnchor constraintEqualToConstant:80.0].active = YES;

    if (image.size.height > image.size.width)
    {
        [imageView.widthAnchor constraintEqualToConstant:55.0].active = YES;
    }
    else
    {
        [imageView.widthAnchor constraintEqualToConstant: 120.0].active = YES;
    }

    [self.photos addObject:photo];
    [self.imageStackView addArrangedSubview:imageView];
}

- (UIScrollView *)imageScrollView
{
    if (_imageScrollView == nil)
    {
        _imageScrollView = [[UIScrollView alloc] init];
        _imageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _imageScrollView;
}

- (UIStackView *)imageStackView
{
    if (_imageStackView == nil)
    {
        _imageStackView = [[UIStackView alloc] init];
        _imageStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageStackView.axis = UILayoutConstraintAxisHorizontal;
        _imageStackView.distribution = UIStackViewDistributionEqualSpacing;
        _imageStackView.alignment = UIStackViewAlignmentCenter;
        _imageStackView.spacing = 8;
    }
    return _imageStackView;
}

- (NSMutableArray *)photos
{
    if (_photos == nil)
    {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

@end
