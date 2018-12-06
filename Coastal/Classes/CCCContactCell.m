//
//  CCCContactCell.m
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCContactCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@implementation CCCContactCell

@synthesize button = _button;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style
                     reuseIdentifier:reuseIdentifier]))
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont ccc_contactCellButtonFont];

        UIColor *buttonColor = [UIColor ccc_blueButtonColor];
        _button.layer.borderColor = buttonColor.CGColor;
        _button.layer.borderWidth = 1.0;

        [_button setTitleColor:buttonColor
                      forState:UIControlStateNormal];

        [self.contentView addSubview:_button];

        self.textLabel.font = [UIFont ccc_contactCellTextLabelFont];

        self.textLabel.textColor = [UIColor ccc_lightTextColor];

        self.detailTextLabel.numberOfLines = 2;
        self.detailTextLabel.font = [UIFont ccc_contactCellDetailTextLabelFont];
        self.detailTextLabel.textColor = [UIColor ccc_darkGrayTextColor];
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [_button sizeToFit];

    CGFloat x = self.contentView.frame.size.width - (_button.frame.size.width + 20) - 20.0;
    _button.frame = CGRectMake(x, 40, _button.frame.size.width + 20, _button.frame.size.height);

    _button.layer.cornerRadius = _button.frame.size.height / 2.0;
    self.textLabel.frame = CGRectMake(20.0, 0.0, CGRectGetMinX(_button.frame) - 20.0 - 10.0, 60.0);

    CGSize detailSize = [self.detailTextLabel sizeThatFits:CGSizeMake(self.textLabel.frame.size.width, self.frame.size.height - 20.0)];

    self.detailTextLabel.frame = CGRectMake(20.0, 50.0, detailSize.width, detailSize.height);

    _button.frame = CGRectMake(_button.frame.origin.x, _button.frame.origin.y + 3.0, _button.frame.size.width, _button.frame.size.height);
}

@end
