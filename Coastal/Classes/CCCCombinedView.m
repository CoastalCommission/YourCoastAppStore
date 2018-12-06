//
//  CCCCombinedView.m
//  Coastal
//
//  Created by Malcolm on 2014-05-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCCombinedView.h"
#import "CCCImageButton.h"
#import "MCHammerView.h"
#import "CCCSearchBarView.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"
#import "CCCVisualConstants.h"

static CGFloat const buttonDiameter = 44.0;
CGFloat BottomButtonInset()
{
    return MAX(SafeBottomInset(), 16.0);
}

@interface CCCCombinedView ()

@property (nonatomic, strong) UIView *mapClippingView;
@property (nonatomic, strong) MKMapView *hiddenMapView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *grabView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *hammerView;
@property (nonatomic, strong) UILabel *leftGrabLabel;
@property (nonatomic, strong) UILabel *rightGrabLabel;
@property (nonatomic, strong) UIView *outsideCaliView;
@property (nonatomic, strong) UILabel *outsideCaliViewLabel;
@property (nonatomic, strong) UIImage *handleImage;
@property (nonatomic, strong) MLXButton *currentLocationButton;
@property (nonatomic, strong) MLXButton *entireCoastButton;
@property (nonatomic, strong) MLXButton *scrollTopButton;
@property (nonatomic, strong) CCCFilterDigestView *filterDigestView;
@property (nonatomic, strong) CCCSearchBarView *searchBarView;

@end

@implementation CCCCombinedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];

        UIView *mapClippingView = self.mapClippingView = [[UIView alloc] initWithFrame:self.bounds];
        {
            mapClippingView.clipsToBounds = YES;

            self.hiddenMapView = [[MKMapView alloc] initWithFrame:CGRectZero];

            MKMapView *mapView = self.mapView = [[MKMapView alloc] initWithFrame:self.bounds];
            {
                mapView.rotateEnabled = NO;
                mapView.pitchEnabled = NO;
            }
            [mapClippingView addSubview:mapView];
        }

        UITableView *tableView = self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        {
            tableView.separatorColor = [UIColor ccc_lightSeparatorColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.separatorInset = UIEdgeInsetsZero;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.rowHeight = 74.0;
            tableView.delaysContentTouches = YES;
            tableView.canCancelContentTouches = YES;
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);

            UIView *headerView = self.headerView = [[UIView alloc] initWithFrame:self.bounds];
            {
                CGRect slice = CGRectZero;
                CGRect remainder = CGRectZero;
                CGRectDivide(headerView.bounds, &slice, &remainder, 27.0, CGRectMaxYEdge);

                UIView *grabView = self.grabView = [[UIView alloc] initWithFrame:slice];
                {
                    grabView.backgroundColor = [UIColor whiteColor];
                    grabView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;

                    CGRect grabRemainder = CGRectZero;
                    CGRectDivide(grabView.bounds, &slice, &grabRemainder, 1.0 / [UIScreen mainScreen].scale, CGRectMinYEdge);

                    UIView *topSeparator = [[UIView alloc] initWithFrame:slice];
                    {
                        topSeparator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.08];
                        topSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
                    }
                    [grabView addSubview:topSeparator];

                    CGRectDivide(grabRemainder, &slice, &grabRemainder, 1.0 / [UIScreen mainScreen].scale, CGRectMaxYEdge);

                    UIView *bottomSeparator = [[UIView alloc] initWithFrame:slice];
                    {
                        bottomSeparator.backgroundColor = tableView.separatorColor;
                        bottomSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
                    }
                    [grabView addSubview:bottomSeparator];
                    
                    UILabel *leftGrabLabel = self.leftGrabLabel = [[UILabel alloc] initWithFrame:grabView.bounds];
                    {
                        leftGrabLabel.textColor = [UIColor ccc_veryLightGrayColor];
                        leftGrabLabel.font = [UIFont ccc_grabLabelFont];
                    }
                    [grabView addSubview:leftGrabLabel];

                    UILabel *rightGrabLabel = self.rightGrabLabel = [[UILabel alloc] initWithFrame:grabView.bounds];
                    {
                        rightGrabLabel.textColor = [UIColor ccc_veryLightGrayColor];
                        rightGrabLabel.font = [UIFont ccc_grabLabelFont];
                        rightGrabLabel.textAlignment = NSTextAlignmentRight;
                    }
                    [grabView addSubview:rightGrabLabel];
                }
                [headerView addSubview:grabView];

                MCHammerView *hammerView = [[MCHammerView alloc] initWithFrame:remainder];
                {
                    hammerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                    hammerView.youCANTouchThis = self.mapView;
                    hammerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];

                    self.hammerView = hammerView;

                    self.currentLocationButton = [[MLXButton alloc] initWithFrame:CGRectZero];
                    {
                        self.currentLocationButton.layer.cornerRadius = buttonDiameter / 2.0;

                        self.currentLocationButton.imageEdgeInsets = UIEdgeInsetsMake(1.0, -1.0, -1.0, 1.0);

                        [self.currentLocationButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]
                                                              forState:UIControlStateNormal];
                        UIColor *highlightedColor = [UIColor whiteColor];
                        [self.currentLocationButton setBackgroundColor:highlightedColor
                                                              forState:UIControlStateHighlighted];
                        [self.currentLocationButton setBackgroundColor:highlightedColor
                                                              forState:UIControlStateSelected];
                        [self.currentLocationButton setBackgroundColor:highlightedColor
                                                              forState:UIControlStateSelected|UIControlStateHighlighted];

                        [self.currentLocationButton setImage:[UIImage imageNamed:@"current_location"]
                                                    forState:UIControlStateNormal];
                        UIImage *highlightedImage = [UIImage imageNamed:@"current_location_highlight"];
                        [self.currentLocationButton setImage:highlightedImage
                                                    forState:UIControlStateHighlighted];
                        [self.currentLocationButton setImage:highlightedImage
                                                    forState:UIControlStateSelected];
                        [self.currentLocationButton setImage:highlightedImage
                                                    forState:UIControlStateSelected|UIControlStateHighlighted];
                    }
                    [hammerView addSubview:self.currentLocationButton];

                    self.entireCoastButton = [[MLXButton alloc] init];
                    {
                        self.entireCoastButton.layer.cornerRadius = buttonDiameter / 2.0;

//                        self.entireCoastButton.imageEdgeInsets = UIEdgeInsetsMake(1.0, -1.0, -1.0, 1.0);

                        [self.entireCoastButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]
                                                          forState:UIControlStateNormal];
                        UIColor *highlightedColor = [UIColor whiteColor];
                        [self.entireCoastButton setBackgroundColor:highlightedColor
                                                          forState:UIControlStateHighlighted];
                        [self.entireCoastButton setBackgroundColor:highlightedColor
                                                          forState:UIControlStateSelected];
                        [self.entireCoastButton setBackgroundColor:highlightedColor
                                                          forState:UIControlStateSelected|UIControlStateHighlighted];

                        [self.entireCoastButton setImage:[UIImage imageNamed:@"entire_coast"]
                                                forState:UIControlStateNormal];
                        UIImage *highlightedImage = [UIImage imageNamed:@"entire_coast_highlight"];
                        [self.entireCoastButton setImage:highlightedImage
                                                forState:UIControlStateHighlighted];
                        [self.entireCoastButton setImage:highlightedImage
                                                forState:UIControlStateSelected];
                        [self.entireCoastButton setImage:highlightedImage
                                                forState:UIControlStateSelected|UIControlStateHighlighted];
                    }
                    [hammerView addSubview:self.entireCoastButton];
                }
                [headerView addSubview:hammerView];
            }
            tableView.tableHeaderView = headerView;
        }

        [self addSubview:mapClippingView];
        [self addSubview:tableView];

        self.filterDigestView = [[CCCFilterDigestView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 40)];
        self.filterDigestView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.filterDigestView];

        UIView *outsideCaliView = self.outsideCaliView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 74.0 + BottomButtonInset() - 16.0)];
        {
            outsideCaliView.backgroundColor = [UIColor ccc_redOverlayColor];

            UILabel *label = self.outsideCaliViewLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 74.0)];
            {
                label.font = [UIFont ccc_outsideCaliforniaViewLabelFont];
                label.textColor = [UIColor whiteColor];
                
                //In Order to accumulate longer string
                label.numberOfLines = 0;
                
                label.text = NSLocalizedString(@"There are no access points. Tap here to return to California.", nil);
                label.textAlignment = NSTextAlignmentCenter;
            }
            [outsideCaliView addSubview:label];
        }
        [self addSubview:outsideCaliView];

        self.searchBarView = [[CCCSearchBarView alloc] init];
        [self addSubview:self.searchBarView];

        UIColor *scrollTopButtonColor = [UIColor ccc_veryLightGrayColor];
        UIColor *scrollTopButtonHighlightedColor = [scrollTopButtonColor colorWithAlphaComponent:0.8];
        self.scrollTopButton = [[MLXButton alloc] initWithFrame:CGRectZero];
        self.scrollTopButton.alpha = 0;
        self.scrollTopButton.layer.cornerRadius = buttonDiameter / 2.0;
        [self.scrollTopButton setBackgroundColor:[scrollTopButtonColor colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        [self.scrollTopButton setBackgroundColor:scrollTopButtonHighlightedColor forState:UIControlStateHighlighted];
        [self.scrollTopButton setBackgroundColor:scrollTopButtonHighlightedColor forState:UIControlStateSelected];
        [self.scrollTopButton setImage:[UIImage imageNamed:@"arrow-up"] forState:UIControlStateNormal];
        [self.scrollTopButton.imageView setTintColor:[UIColor colorWithRed:0.59 green:0.58 blue:0.58 alpha:1.00]];
        [self addSubview:self.scrollTopButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];


    CGRect searchBarViewFrame = self.bounds;
    searchBarViewFrame.size.height = 44.0;
    self.searchBarView.frame = searchBarViewFrame;

    self.mapView.frame = self.hiddenMapView.frame = self.bounds;
    self.tableView.frame = self.bounds;

    self.headerView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.tableView.rowHeight);
    self.tableView.tableHeaderView = self.headerView;
    
    CGFloat labelWidth = roundf((self.grabView.bounds.size.width / 2.0) - (self.handleImage.size.width / 2.0));
    CGRect largeLabelRect = CGRectMake(0, 0, labelWidth, self.grabView.bounds.size.height);
    CGRect insetLabelRect = CGRectInset(largeLabelRect, 9.0, 0);
    self.leftGrabLabel.frame = insetLabelRect;

    self.rightGrabLabel.frame = CGRectOffset(self.leftGrabLabel.frame, CGRectGetWidth(self.grabView.frame) - largeLabelRect.size.width, 0);

    static CGFloat const buttonMargin = 5.0;

    self.currentLocationButton.frame = CGRectMake(buttonMargin, CGRectGetMinY(self.grabView.frame) - buttonDiameter - buttonMargin, buttonDiameter, buttonDiameter);
    self.entireCoastButton.frame = CGRectMake(CGRectGetMaxX(self.hammerView.frame) - buttonDiameter - buttonMargin, CGRectGetMinY(self.grabView.frame) - buttonDiameter - buttonMargin, buttonDiameter, buttonDiameter);
    self.scrollTopButton.frame = CGRectMake(self.bounds.size.width - buttonDiameter - 16.0, self.bounds.size.height - buttonDiameter - BottomButtonInset(), buttonDiameter, buttonDiameter);

    [self layoutMapView];
}

- (void)layoutMapView
{
    CGRect frame = self.headerView.bounds;
    {
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
        frame.size.height -= contentOffsetY;
        frame.size.height = MAX(frame.size.height, 180.0);
    }
    self.mapClippingView.frame = frame;

    CGRect bounds = self.mapClippingView.bounds;
    {
        CGFloat difference = CGRectGetHeight(self.mapView.frame) - CGRectGetHeight(self.mapClippingView.frame);
        bounds.origin.y = ceilf(difference / 2.0);
    }
    self.mapClippingView.bounds = bounds;

    CGFloat minimumHeight = 180.0;
    CGFloat height = CGRectGetHeight(self.mapClippingView.frame) - minimumHeight;
    CGFloat maximumHeight = 244.0 - minimumHeight;

    CGFloat percentage = 1.0 - MAX(0.0, MIN(height / maximumHeight, 1.0));

    CGFloat alpha = percentage * 0.5;

    self.hammerView.backgroundColor = [self.hammerView.backgroundColor colorWithAlphaComponent:alpha];

    BOOL enabled = percentage < FLT_EPSILON;
    self.hammerView.userInteractionEnabled = enabled;

    [self configureScrollTopButtonState];
}

- (void)setHasResults:(BOOL)hasResults
{
    _hasResults = hasResults;

    [self setListOpen:self.listOpen animated:YES];
}

- (void)setOutOfBounds:(BOOL)outOfBounds
{
    _outOfBounds = outOfBounds;

    [self setListOpen:self.listOpen animated:YES];
}

#pragma mark - Actions

- (void)setListOpen:(BOOL)listOpen
{
    [self setListOpen:listOpen animated:NO];
}

- (void)setListOpen:(BOOL)listOpen animated:(BOOL)animated
{
    [self setListOpen:listOpen animated:animated initialVelocity:0.0];
}

- (void)setListOpen:(BOOL)listOpen animated:(BOOL)animated initialVelocity:(CGFloat)initialVelocity
{
    _listOpen = listOpen;

    CGFloat duration = animated ? 0.5 : 0.0;
    CGFloat initialSpringVelocity = 0.0;

    CGFloat closedHeight = 0.0;
    CGFloat openHeight = 180.0;
    
    self.tableView.showsVerticalScrollIndicator = NO;

    if (animated && initialVelocity > 0.0)
    {
        CGFloat offset = _listOpen ? self.tableView.contentOffset.y : openHeight - self.tableView.contentOffset.y;
        initialSpringVelocity = initialVelocity / offset;
    }

    void(^animations)(void) = ^{

        UIEdgeInsets contentInset = self.tableView.contentInset;
        {
            contentInset.top = listOpen ? -openHeight : closedHeight;
            contentInset.bottom = listOpen ? closedHeight : -(self.tableView.contentSize.height - CGRectGetHeight(self.tableView.frame) + contentInset.top);
        }

        self.tableView.contentInset = contentInset;

        if (animated && initialVelocity > 0.0)//listOpen == NO)
        {
            self.tableView.contentOffset = listOpen ? CGPointMake(0.0, openHeight) : CGPointZero;
        }

        CGRect frame = self.outsideCaliView.frame;
        frame.origin.y = CGRectGetHeight(self.frame) - (self.outOfBounds ? CGRectGetHeight(self.outsideCaliView.frame) : 0.0);
        self.outsideCaliView.frame = frame;
    };

    void(^completion)(BOOL) = ^(BOOL finished) {

        if (finished)
        {
            self.tableView.showsVerticalScrollIndicator = YES;
            [self.delegate combinedViewListOpenDidChange:self];
        }
    };

    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:initialSpringVelocity
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|(initialVelocity > 0.0 ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseInOut)
                     animations:animations
                     completion:completion];
}

#pragma mark - Helpers

- (void)configureScrollTopButtonState
{
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat headerHeight = self.tableView.tableHeaderView.frame.size.height - self.searchBarView.frame.size.height - self.leftGrabLabel.frame.size.height;

    static CGFloat lastY = 0;
    if ((lastY <= headerHeight) && (contentOffsetY > headerHeight)) {
        self.scrollTopButton.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollTopButton.alpha = 1;
        }];
    }
    if ((lastY > headerHeight) && (contentOffsetY <= headerHeight)) {
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollTopButton.alpha = 0;
        }];
    }
    lastY = contentOffsetY;
}

@end
