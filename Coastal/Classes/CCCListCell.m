//
//  CCCListCell.m
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCListCell.h"
#import "CCCAccessPoint.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"
#import "GTMNSString+HTML.h"

@interface CCCListCell ()

@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIImage *star;

@end

@implementation CCCListCell

- (void)setAccessPoint:(NSDictionary *)accessPoint
{
    _accessPoint = accessPoint;

    self.textLabel.text = [accessPoint[kName] gtm_stringByUnescapingFromHTML];
    self.detailTextLabel.text = [accessPoint[kDescription] gtm_stringByUnescapingFromHTML];

    CGFloat distance = [accessPoint[kDistance] doubleValue];
    self.distanceLabel.text = ((distance - DBL_EPSILON) > 0.0) ? [[NSString alloc] initWithFormat:@"%.1fmi", distance] : nil;

    NSArray *favourites = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey];

    BOOL favourited = [favourites containsObject:self.accessPoint[kID]];

    self.star = [UIImage imageNamed:@"star"];
    self.imageView.image = favourited ? self.star : nil;
}

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:reuseIdentifier]))
    {
        self.imageView.contentMode = UIViewContentModeCenter;

        self.textLabel.textColor = [UIColor ccc_blackTextColor];
        self.textLabel.font = [UIFont ccc_textLabelFont];

        self.detailTextLabel.textColor = [UIColor ccc_lightGrayColor];
        self.detailTextLabel.font = [UIFont ccc_detailedTextLabelFont];
        
        UIImage *chevron = [UIImage imageNamed:@"cell_chevron"];
        self.accessoryView = [[UIImageView alloc] initWithImage:chevron];
        self.accessoryView.contentMode = UIViewContentModeLeft;
        self.accessoryView.alpha = 0.2;

        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.distanceLabel.textColor = [UIColor ccc_veryLightGrayColor];
        self.distanceLabel.font = [UIFont ccc_listDistanceLabelFont];
        [self.contentView addSubview:self.distanceLabel];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(0.0, 0.0, 18.0, self.frame.size.height);
    
    self.accessoryView.frame = CGRectMake(self.frame.size.width - 23.0, 0, 23.0, 23.0);

    [self.distanceLabel sizeToFit];

    self.distanceLabel.frame = ^CGRect{

        CGRect frame = self.distanceLabel.frame;
        frame.origin = CGPointMake(self.frame.size.width - frame.size.width - 18, 0.0);

        return frame;
    }();

    CGFloat x = self.distanceLabel.frame.origin.x - 36;

    self.textLabel.frame = ^CGRect{

        CGRect frame = self.textLabel.frame;
        frame.origin.x = 18.0;
        frame.size.width = x;

        return frame;
    }();

    self.detailTextLabel.frame = ^CGRect{

        CGRect frame = self.detailTextLabel.frame;
        frame.origin.x = 18.0;
        frame.size.width = self.frame.size.width - 36;
        
        return frame;
    }();

    self.imageView.frame = ^CGRect{

        CGRect frame = self.imageView.frame;
        frame.origin.y = self.textLabel.frame.size.height * 0.5 + self.star.size.height - 1;
        frame.size.height = self.star.size.height;
        return frame;
    }();

    _distanceLabel.frame = ^CGRect{

        CGRect frame = self.distanceLabel.frame;
        frame.origin.y = self.textLabel.frame.origin.y;
        frame.size.height = self.textLabel.frame.size.height;
        return frame;
    }();
}

@end
