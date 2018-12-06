//
//  CCCFilterView.m
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFilterView.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCFilterView ()

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *resetButton;
@property (nonatomic, strong) UIBarButtonItem *applyButton;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation CCCFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                                               style:UITableViewStylePlain];
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.rowHeight = 57.0;
        }
        [self addSubview:tableView];

        NSDictionary *normalAttributes = @{
                                           NSFontAttributeName: [UIFont ccc_filterViewButtonFont],
                                           NSForegroundColorAttributeName: [UIColor ccc_filterViewBlueColor],
                                           };
        NSDictionary *highlightedAttributes = @{
                                                NSFontAttributeName: [UIFont ccc_filterViewButtonFont],
                                                NSForegroundColorAttributeName: [UIColor ccc_filterViewHighlightedBlueColor],
                                                };

        UIBarButtonItem *cancelButton = self.cancelButton = [[UIBarButtonItem alloc] init];
        {
            cancelButton.title = NSLocalizedString(@"Cancel", nil);
            [cancelButton setTitleTextAttributes:normalAttributes
                                        forState:UIControlStateNormal];
            [cancelButton setTitleTextAttributes:highlightedAttributes
                                        forState:UIControlStateHighlighted];
        }

        UIBarButtonItem *resetButton = self.resetButton = [[UIBarButtonItem alloc] init];
        {
            resetButton.title = NSLocalizedString(@"Reset", nil);
            [resetButton setTitleTextAttributes:normalAttributes
                                       forState:UIControlStateNormal];
            [resetButton setTitleTextAttributes:highlightedAttributes
                                       forState:UIControlStateHighlighted];
        }

        UIBarButtonItem *applyButton = self.applyButton = [[UIBarButtonItem alloc] init];
        {
            applyButton.title = NSLocalizedString(@"Apply", nil);
            [applyButton setTitleTextAttributes:normalAttributes
                                       forState:UIControlStateNormal];
            [applyButton setTitleTextAttributes:highlightedAttributes
                                       forState:UIControlStateHighlighted];
        }

        UILabel *countLabel = self.countLabel = [[UILabel alloc] init];
        {
            countLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
            countLabel.font = [UIFont ccc_filterCountLabelFont];
            countLabel.textColor = [UIColor ccc_filterCountLabelDarkTextColor];
            countLabel.textAlignment = NSTextAlignmentCenter;
        }
        [self addSubview:countLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect slice = CGRectZero;
    CGRect remainder = self.bounds;

    CGRectDivide(remainder, &slice, &remainder, 48.0, CGRectMaxYEdge);
    self.countLabel.frame = slice;

    self.tableView.frame = self.bounds;

    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = CGRectGetHeight(slice);
    self.tableView.contentInset = contentInset;

    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = CGRectGetHeight(slice);
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
}

@end
