//
//  CCCDescriptionCell.m
//  Coastal
//
//  Created by Oliver White on 2/24/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCDescriptionCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCDescriptionCell ()

@property (nonatomic, strong) UITextView *detailTextView;

@end

@implementation CCCDescriptionCell

#pragma mark - UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style
                     reuseIdentifier:reuseIdentifier]))
    {
        self.textLabel.font = [UIFont ccc_descriptionCellTextLabelFont];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 0;

        self.detailTextView = [[UITextView alloc] init];
        self.detailTextView.editable = NO;
        self.detailTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        self.detailTextView.font = [UIFont ccc_detailedTextLabelFont];
        self.detailTextView.textColor = [UIColor whiteColor];
        self.detailTextView.textAlignment = NSTextAlignmentCenter;
        self.detailTextView.backgroundColor = [UIColor clearColor];
        self.detailTextView.textContainer.lineFragmentPadding = 0;
        self.detailTextView.linkTextAttributes = @{
                                                   NSForegroundColorAttributeName: [UIColor whiteColor],
                                                   NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                   };
        [self.detailTextView setTextContainerInset:UIEdgeInsetsZero];
        [self.contentView addSubview:self.detailTextView];

        self.contentView.backgroundColor = [UIColor ccc_navigationBarBlueTintColor];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGSize size = CGSizeMake([UIApplication sharedApplication].keyWindow.bounds.size.width - 20.0, CGFLOAT_MAX);
        CGRect rect = [self.textLabel.text boundingRectWithSize:size
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName : self.textLabel.font
                                                                  }
                                                        context:NULL];

        rect.origin = CGPointMake(10.0, 35.0);
        rect.size = CGSizeMake(size.width, ceil(rect.size.height));

        self.textLabel.frame = rect;
    }
    {
        CGSize size = CGSizeMake([UIApplication sharedApplication].keyWindow.bounds.size.width - 20.0, CGFLOAT_MAX);
        CGRect rect = [self.detailTextView.text boundingRectWithSize:size
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName : self.detailTextView.font}
                                                              context:NULL];

        rect.origin = CGPointMake(10.0, CGRectGetMaxY(self.textLabel.frame));
        rect.size = CGSizeMake(size.width, ceil(rect.size.height));

        self.detailTextView.frame = rect;
    }
}

@end
