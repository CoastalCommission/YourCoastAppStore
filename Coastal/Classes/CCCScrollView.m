//
//  CCCScrollView.m
//  Coastal
//
//  Created by Cezar Pereira on 5/19/16.
//  Copyright (c) 2016 MetaLab. All rights reserved.
//

#import "CCCScrollView.h"
#import "UIView+MLX.h"
#import "NSLayoutConstraint+MLX.h"

@interface CCCScrollView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterYConstraint;

@end

@implementation CCCScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.accessibilityIdentifier = NSStringFromClass([self class]);
        self.backgroundColor = [UIColor whiteColor];
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

        [self addSubview:self.contentView];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];

    self.contentViewCenterYConstraint.constant = -contentInset.top - contentInset.bottom / 2.0;
}

- (void)updateConstraints
{
    [self mlx_addConstraintsIfNeeded];

    [super updateConstraints];
}

- (NSArray *)mlx_constraints
{
    NSMutableArray *constraints = [[super mlx_constraints] mutableCopy];
    {
        NSDictionary *formats = @{
                                  @"V:|[contentView]|": @(0),
                                  @"H:|[contentView]|": @(0),
                                  };

        NSDictionary *metrics = @{
                                  };

        NSDictionary *views = MLXDictionaryOfPropertyBindings(
                                                              self.contentView
                                                              );

        [constraints addObjectsFromArray:[NSLayoutConstraint mlx_constraintsWithVisualFormatsAndOptions:formats
                                                                                                metrics:metrics
                                                                                                  views:views]];

        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           self.contentViewCenterYConstraint,
                                           ]];
    }
    return constraints;
}

#pragma mark - Lazy Getters

- (UIView *)contentView
{
    if (_contentView == nil)
    {
        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (NSLayoutConstraint *)contentViewCenterYConstraint
{
    if (_contentViewCenterYConstraint == nil)
    {
        _contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0.0];

        _contentViewCenterYConstraint.priority = UILayoutPriorityDefaultHigh;
    }
    return _contentViewCenterYConstraint;
}

@end
