//
//  CCCImageButton.m
//  Coastal
//
//  Created by Jesse Lupini on 2014-05-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCImageButton.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@implementation CCCImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel.font = [UIFont ccc_imageLabelTitleLabelFont];
        self.backgroundColor = [UIColor ccc_lightBackgroundColor];
        
        [self setTitleColor:[UIColor ccc_imageButtonTitleColor]
                   forState:UIControlStateNormal];
        UIColor *highlightedColor = [UIColor ccc_imageButtonHighlightedTitleColor];
        [self setTitleColor:highlightedColor
                   forState:UIControlStateHighlighted];
        [self setTitleColor:highlightedColor
                   forState:UIControlStateSelected];
        [self setTitleColor:highlightedColor
                   forState:UIControlStateSelected|UIControlStateHighlighted];

        CGFloat spacing = 10;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    }
    return self;
}

@end
