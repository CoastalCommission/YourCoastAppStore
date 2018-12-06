//
//  CCCAccessPointImagesCell.m
//  Coastal
//
//  Created by Aaron Williams on 2016-09-08.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "NSLayoutConstraint+MLX.h"
#import "UIView+MLX.h"
#import "CCCAccessPointImagesCell.h"
#import "UIFont+CCCTypeFoundry.h"
#import "UIColor+CCCColorPallete.h"
#import "CCCPhoto.h"
#import "CCCThumbnailView.h"

@interface CCCAccessPointImagesCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CCCThumbnailView *thumbnailView;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation CCCAccessPointImagesCell

- (instancetype)initWithPhotos:(NSArray<CCCPhoto *> *)photos
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (self != nil)
    {
        self.photos = photos;

        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.thumbnailView];

        [self configureWithPhotos:photos];
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
                                  @"V:|[titleLabel]-[thumbnailView]|": @(NSLayoutFormatAlignAllLeft),
                                  @"H:|-20-[thumbnailView]|": @0,
                                  };

        NSDictionary *metrics = @{
                                  };

        NSDictionary *views = MLXDictionaryOfPropertyBindings(
                                                              self.titleLabel,
                                                              self.thumbnailView
                                                              );

        [constraints addObjectsFromArray:[NSLayoutConstraint mlx_constraintsWithVisualFormatsAndOptions:formats
                                                                                                metrics:metrics
                                                                                                  views:views]];
    }
    return constraints;
}

- (void)configureWithPhotos:(NSArray *)photos
{
    for (CCCPhoto *photo in photos)
    {
        [self.thumbnailView addPhoto:photo];
        [self setNeedsLayout];
    }
}

#pragma mark - Lazy Getters

- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont ccc_amenitiesHeaderCellTitleLabelFont];
        _titleLabel.textColor = [UIColor ccc_lightTextColor];
        _titleLabel.text = NSLocalizedString(@"Photos", nil);
    }
    return _titleLabel;
}

- (CCCThumbnailView *)thumbnailView
{
    if (_thumbnailView == nil)
    {
        _thumbnailView = [[CCCThumbnailView alloc] init];
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _thumbnailView;
}

- (NSArray *)photos
{
    if (_photos == nil)
    {
        _photos = [[NSArray alloc] init];
    }
    return _photos;
}

@end
