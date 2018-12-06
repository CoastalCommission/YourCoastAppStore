//
//  CCCSearchResultCell.m
//  Coastal
//
//  Created by Malcolm on 2014-06-04.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCSearchResultCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

NSString * const CCCSearchResultCellReuseIdentifier = @"CCCSearchResultCellReuseIdentifier";

@implementation CCCSearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.font = [UIFont ccc_textLabelFont];
        self.textLabel.textColor = [UIColor ccc_darkTextColor];

        self.detailTextLabel.font = [UIFont ccc_detailedTextLabelFont];
        self.detailTextLabel.textColor = [UIColor ccc_veryLightGrayColor];

        self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat leftMargin = 5.0f;

    if (self.imageView.image)
    {
        leftMargin = 30.0f;
    }

    [self.detailTextLabel sizeToFit];

    self.detailTextLabel.frame = ^{

        CGRect rect = self.detailTextLabel.frame;
        {
            rect.origin.x = CGRectGetMaxX(self.contentView.bounds) - CGRectGetWidth(rect) - 14.0;
            rect.origin.y = roundf(CGRectGetMidY(self.contentView.bounds) - CGRectGetHeight(rect) / 2.0);
        }
        return rect;
    }();

    self.textLabel.frame = ^{

        CGRect rect = self.contentView.bounds;
        {
            rect.origin.x = 14.0 + leftMargin;
            rect.size.width = CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.detailTextLabel.frame) - 28.0 - 5.0 - leftMargin;
        }
        return rect;
    }();

    CGRect frame = self.imageView.frame;
    frame.origin.x += 5;
    self.imageView.frame = frame;
    self.imageView.contentMode = UIViewContentModeCenter;
}

@end
