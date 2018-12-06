//
//  CCCAmenitiesHeaderCell.m
//  Coastal
//
//  Created by Dai Hovey on 20/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCAmenitiesHeaderCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@implementation CCCAmenitiesHeaderCell


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style
                     reuseIdentifier:reuseIdentifier]))
    {
        self.textLabel.font = [UIFont ccc_amenitiesHeaderCellTitleLabelFont];
        self.textLabel.textColor = [UIColor ccc_lightTextColor];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.textLabel.frame = CGRectMake(20.0, 0.0, self.frame.size.width, 30.0);
}

@end
