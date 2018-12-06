//
//  CCCCalloutView.m
//  Coastal
//
//  Created by Dai Hovey on 30/01/2015.
//  Copyright (c) 2015 MetaLab. All rights reserved.
//

#import "CCCCalloutView.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCCalloutView ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;

@end

@implementation CCCCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.alpha = 0.0;

        self.arrowHeight = 13.0f;

        [self.layer addSublayer:self.backgroundLayer];

        [self addSubview:self.textLabel];
        [self addSubview:self.chevronImageView];

        [self setupConstraints];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _backgroundLayer.path = [self backgroundPath].CGPath;
    
}

- (void)setupConstraints
{
    NSDictionary *metrics = @{
                              @"padding" : @4,
                              @"bottomPadding" : @17,
                              @"maxWidth" : @280
                              };
    NSDictionary *views = @{
                            @"textLabel" : self.textLabel,
                            @"chevronImageView" : self.chevronImageView
                            };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[textLabel]-(bottomPadding)-|"
                                                                 options:0
                                                                 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[chevronImageView(>=10)]-(bottomPadding)-|"
                                                                 options:0
                                                                 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[textLabel(<=maxWidth)]-[chevronImageView(>=10)]-(padding)-|"
                                                                 options:0
                                                                 metrics:metrics views:views]];
}


- (void)showAnimated:(BOOL)animated
{
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [UIView animateWithDuration:(animated) ? 0.3 : 0.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         [self setNeedsLayout];

                         self.transform = CGAffineTransformIdentity;
                         self.alpha = 1.0;
                     }
                     completion:NULL];
}

- (void)hideAnimated:(BOOL)animated
{
    [UIView animateWithDuration:(animated) ? 0.3 : 0.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:NULL];
}

#pragma mark - Setters

-(void) setLocationName:(NSString *)locationName
{
    self.textLabel.text = locationName;

    [self updateConstraints];
}

#pragma mark - Getters

- (UIBezierPath *)backgroundPath
{
    CGFloat arrowWidth = 25.0;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);

    CGPoint center = CGPointMake(width * 0.5, height);
    CGPoint left = CGPointMake(width * 0.5 - arrowWidth * 0.5, height - self.arrowHeight);
    CGPoint right = CGPointMake(width * 0.5 + arrowWidth * 0.5, height - self.arrowHeight);

    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(0, 0)];
    [bezierPath addLineToPoint: CGPointMake(width, 0)];
    [bezierPath addLineToPoint: CGPointMake(width, height-self.arrowHeight)];
    [bezierPath addLineToPoint: right];
    [bezierPath addLineToPoint: center];
    [bezierPath addLineToPoint: left];
    [bezierPath addLineToPoint: CGPointMake(0, height-self.arrowHeight)];
    [bezierPath addLineToPoint: CGPointMake(0, 10)];
    [bezierPath closePath];

    return bezierPath;
}

- (CAShapeLayer *)backgroundLayer
{
    if (_backgroundLayer == nil)
    {
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.fillColor = [UIColor whiteColor].CGColor;
        _backgroundLayer.lineCap = kCALineCapRound;
        _backgroundLayer.lineJoin = kCALineJoinRound;
        _backgroundLayer.lineWidth = 10;
        _backgroundLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    return _backgroundLayer;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil)
    {
        _textLabel = [[UILabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.font = [UIFont ccc_calloutViewTextLabelFont];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.userInteractionEnabled = YES;
    }
    return _textLabel;
}

-(UIImageView *) chevronImageView
{
    if (_chevronImageView == nil)
    {
        UIImage *chevronImage = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _chevronImageView = [[UIImageView alloc] initWithImage:chevronImage];
        _chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
        _chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _chevronImageView.transform = CGAffineTransformMakeRotation(M_PI);
        _chevronImageView.userInteractionEnabled = YES;
        _chevronImageView.tintColor = [UIColor ccc_veryLightGrayColor];
    }
    return _chevronImageView;
}

@end
