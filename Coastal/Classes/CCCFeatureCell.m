//
//  CCCFeatureCell.m
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFeatureCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

static CGFloat const disabledAccessTopCellPadding = 5.0;

@interface CCCFeatureCell()

@property (nonatomic, strong) UIImageView *postLabelImageView;
@property (nonatomic, strong) UITextView *detailTextView;

@end

@implementation CCCFeatureCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style
                     reuseIdentifier:reuseIdentifier]))
    {
        self.imageView.contentMode = UIViewContentModeLeft;

        self.textLabel.font = [UIFont ccc_featureCellTextLabelFont];
        self.textLabel.textColor = [UIColor ccc_darkGrayTextColor];

        self.detailTextView = [[UITextView alloc] init];
        self.detailTextView.editable = NO;
        self.detailTextView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
        self.detailTextView.font = [UIFont ccc_featureCellSecondaryTextLabelFont];
        self.detailTextView.textColor = [UIColor ccc_grayColor];
        self.detailTextView.backgroundColor = [UIColor clearColor];
        self.detailTextView.textContainer.lineFragmentPadding = 0;
        self.detailTextView.linkTextAttributes = @{
                                                   NSForegroundColorAttributeName: [UIColor ccc_grayColor],
                                                   NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                   };
        [self.detailTextView setTextContainerInset:UIEdgeInsetsZero];
        [self.contentView addSubview:self.detailTextView];

        if (self.postLabelImageView == nil)
        {
            self.postLabelImageView = [[UIImageView alloc] init];
            [self.contentView addSubview:self.postLabelImageView];
        }
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.imageView.image != nil)
    {
        self.imageView.frame = CGRectMake(20.0, self.adjustment, 35.0, self.frame.size.height);

        if ([self.detailTextView.text length] == 0)
        {
            self.textLabel.frame = CGRectMake(55.0, self.adjustment, self.frame.size.width - 55.0 - 10.0, self.frame.size.height);
        }
        else
        {
            CGSize textLabelSize = CGSizeMake([UIApplication sharedApplication].keyWindow.bounds.size.width - 55.0 - 10.0, CGFLOAT_MAX);
            CGRect textLabelRect = [self.textLabel.text boundingRectWithSize:textLabelSize
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{
                                                                               NSFontAttributeName : self.textLabel.font
                                                                               }
                                                                     context:NULL];

            textLabelRect.origin = CGPointMake(55.0, self.adjustment + disabledAccessTopCellPadding);
            textLabelRect.size = CGSizeMake(textLabelSize.width, ceil(textLabelRect.size.height));

            self.textLabel.frame = textLabelRect;

            if ([self.detailTextView.text length] > 0)
            {
                CGSize detailTextViewSize = CGSizeMake([UIApplication sharedApplication].keyWindow.bounds.size.width - 55.0 - 10.0, CGFLOAT_MAX);
                CGRect detailTextViewRect = [self.detailTextView.text boundingRectWithSize:detailTextViewSize
                                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : self.detailTextView.font
                                                                                               }
                                                                                     context:NULL];
                detailTextViewRect.origin = CGPointMake(55.0, CGRectGetMaxY(self.textLabel.frame));
                detailTextViewRect.size = CGSizeMake(detailTextViewSize.width, ceil(detailTextViewRect.size.height));

                self.detailTextView.frame = detailTextViewRect;
            }
        }
    }
    else
    {
        self.textLabel.frame = CGRectMake(20.0, self.adjustment, self.frame.size.width - 20.0 - 10.0, self.frame.size.height);
    }

    if (self.postLabelImageView.image != nil)
    {
        [self.textLabel sizeToFit];
        self.postLabelImageView.frame = CGRectMake(0.0, 0.0, self.textLabel.bounds.size.height * 0.65, self.textLabel.bounds.size.height * 0.65);
        self.postLabelImageView.center = CGPointMake(CGRectGetMaxX(self.textLabel.frame) + (self.postLabelImageView.bounds.size.width * 1.50), self.textLabel.center.y);
    }
}

- (void)setSecondaryIconImage:(UIImage *)secondaryIconImage
{
    _secondaryIconImage = secondaryIconImage;
    self.postLabelImageView.image = secondaryIconImage;
    [self setNeedsLayout];
}

@end
