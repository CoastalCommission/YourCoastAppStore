//
//  CCCTourView.m
//  Coastal
//
//  Created by Ian Hoar on 2014-06-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCTourView.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCSlideView : UIView

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@interface CCCTourPageControl : UIView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *dots;

@end

@interface CCCTourView() <UIScrollViewDelegate>
{
    UIScrollView *_scrollview;
    CCCTourPageControl *_pageControl;
}
@end

@implementation CCCTourView

#define numberOfSlides 3

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        {
            _scrollview.pagingEnabled = YES;
            _scrollview.delegate = self;
            _scrollview.showsHorizontalScrollIndicator = NO;
            _scrollview.backgroundColor = [UIColor ccc_tourViewDarkBackgroundColor];

            [_scrollview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];

            NSArray *backgrounds = @[
                                     [UIImage imageNamed:@"tour_background_1"],
                                     [UIImage imageNamed:@"tour_background_2"],
                                     [UIImage imageNamed:@"tour_background_3"],
                                     ];

            NSArray *images =      @[
                                     [UIImage imageNamed:@"tour_image_1"],
                                     [UIImage imageNamed:@"tour_image_2"],
                                     [UIImage imageNamed:@"tour_image_3"],
                                     ];

            NSArray *labels =      @[
                                     NSLocalizedString(@"YourCoast makes it easy to explore the beautiful California Coast", nil),
                                     NSLocalizedString(@"Find the closest access points to you, or search new areas to explore.", nil),
                                     NSLocalizedString(@"Refine with filters to find exactly what you’re looking for.", nil),
                                     ];

            for (int i = 0; i < numberOfSlides; i++)
            {
                CCCSlideView *slideView = [[CCCSlideView alloc] initWithFrame:self.bounds];
                {
                    slideView.backgroundImage.image = backgrounds[i];
                    slideView.imageView.image = images[i];
                    slideView.label.text = labels[i];

                    if (i == 0)
                    {
                        slideView.imageView.contentMode = UIViewContentModeTop;
                    }
                }
                [_scrollview addSubview:slideView];
            }
        }
        [self addSubview:_scrollview];

        _pageControl = [[CCCTourPageControl alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.bounds) - 60.0, CGRectGetWidth(self.bounds), 60)];
        {
            _pageControl.numberOfPages = 3;
        }
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)tap
{
    [_scrollview setContentOffset:CGPointMake(_scrollview.contentOffset.x + CGRectGetWidth(_scrollview.bounds), 0) animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat xOffset = 0.0;

    for (UIView *subview in _scrollview.subviews)
    {
        if ([subview isKindOfClass:[CCCSlideView class]])
        {
            CGFloat width = CGRectGetWidth(subview.bounds);

            subview.frame = CGRectMake(xOffset, 0, width, CGRectGetHeight(self.bounds));

            xOffset += width;
        }
    }

    _scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * (numberOfSlides + 1), CGRectGetHeight(self.bounds));
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat midoffset = scrollView.contentOffset.x - CGRectGetWidth(self.bounds)/2;
    NSUInteger currentPage = floor((midoffset ) / CGRectGetWidth(self.bounds)) + 1;

    if (currentPage != _pageControl.currentPage)
        _pageControl.currentPage = currentPage;

    CGFloat rightoffset = scrollView.contentOffset.x;

    if (rightoffset > scrollView.contentSize.width - (scrollView.bounds.size.width * 2.0))
    {
        CGFloat delta = scrollView.contentSize.width - (scrollView.bounds.size.width * 2.0) - scrollView.contentOffset.x;

        if (delta > 0)
            return;

        delta = -delta;
        delta -= scrollView.bounds.size.width;

        CGFloat pc = delta / scrollView.bounds.size.width;

        self.alpha = -pc;

        if (rightoffset >= scrollView.contentSize.width - scrollView.bounds.size.width)
        {
            scrollView.delegate = nil;
            [self.delegate tourDidComplete];
        }
    }
}

@end

@implementation CCCSlideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        {
            self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
            self.backgroundImage.clipsToBounds = YES;
        }
        [self addSubview:self.backgroundImage];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)/8, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/2)];
        {
            self.imageView.contentMode = UIViewContentModeCenter;
        }
        [self addSubview:self.imageView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.imageView.frame), CGRectGetWidth(self.frame) - 60.0, CGRectGetHeight(self.frame) - CGRectGetMaxY(self.imageView.frame) - 60.0)];
        {
            self.label.textColor = [UIColor ccc_tourViewLightTextColor];
            self.label.font = [UIFont ccc_onboardingTourMainLabelFont];
            self.label.numberOfLines = 0;
            self.label.textAlignment = NSTextAlignmentCenter;
        }
        [self addSubview:self.label];
    }
    return self;
}

@end

@implementation CCCTourPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dots = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    _currentPage = currentPage;

    int index = 0;

    for (UIImageView *dot in self.dots)
    {
        UIImage *image = [UIImage imageNamed:((index == _currentPage) ? @"tour_dot_active" : @"tour_dot")];
        dot.image = image;

        index++;
    }
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
    _numberOfPages = numberOfPages;

    UIView *subview = nil;
    while ((subview = [self.subviews lastObject]))
    {
        [subview removeFromSuperview];
    }

    [self.dots removeAllObjects];

    UIImage *dotImage = [UIImage imageNamed:@"tour_dot"];

    CGFloat spacing = 20.0;

    CGFloat xoffset = CGRectGetWidth(self.frame)/2 - dotImage.size.width/2 - spacing - dotImage.size.width;

    for (int i = 0; i < numberOfPages; i++)
    {
        UIImageView *dotView = [[UIImageView alloc] initWithImage:dotImage];
        {
            dotView.frame = CGRectMake(xoffset, 0, dotView.image.size.width, dotView.image.size.height);
        }
        [self.dots addObject:dotView];
        [self addSubview:dotView];

        xoffset += dotImage.size.width + spacing;

    }
    
    self.currentPage = 0;
    
}

@end

