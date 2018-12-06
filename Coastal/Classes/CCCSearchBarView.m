//
//  CCCTitleView.m
//  Coastal
//
//  Created by Malcolm on 2014-05-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCSearchBarView.h"
#import "MLXButton.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCNavigationSearchBarTextField : UITextField @end

@interface CCCSearchBarView ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelSearchButton;
@property (nonatomic, strong) UIButton *filterButton;

@property (nonatomic, assign, getter = isSearching) BOOL searching;
@property (nonatomic) CGFloat rightCancelButtonMargin;
@property (nonatomic) CGFloat rightFilterButtonMargin;

@end

@implementation CCCSearchBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor ccc_inactiveSearchBarBlueBackgroundColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UITextField *textField = self.textField = [[CCCNavigationSearchBarTextField alloc] init];
        {
            textField.font = [UIFont ccc_searchBarViewTextFieldAndLabelsFont];
            textField.textColor = [UIColor whiteColor];
            textField.tintColor = [UIColor whiteColor];
            textField.placeholder = NSLocalizedString(@"Search...", nil);
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            NSDictionary *attributes = @{
                                         NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.60],
                                         NSFontAttributeName: [UIFont ccc_searchBarPlaceholderFont],
                                        };
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:attributes];
            
            UIImage *magnifyingGlass = [UIImage imageNamed:@"CCCNavigationSearchBarMagnifyingGlass"];
            UIImageView *leftView = [[UIImageView alloc] initWithImage:magnifyingGlass];
            leftView.contentMode = UIViewContentModeCenter;
            leftView.frame = CGRectMake(0, 0, 40, 40);
            textField.leftView = leftView;
            textField.leftViewMode = UITextFieldViewModeAlways;
            
            UIButton *button = [[UIButton alloc] init];
            {
                button.alpha = 0.0;
                
                [button setImage:[UIImage imageNamed:@"CCCNavigationSearchBarButtonClear"]
                        forState:UIControlStateNormal];
                
                [button addTarget:self
                           action:@selector(clear)
                 forControlEvents:UIControlEventTouchUpInside];
                
                [button sizeToFit];
            }
            
            textField.rightView = button;
            textField.rightViewMode = UITextFieldViewModeNever;
        }
        [self addSubview:textField];
        
        self.filterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.filterButton.titleEdgeInsets = UIEdgeInsetsMake(1.5, 2.5, 1.5, -2.5);
        self.filterButton.backgroundColor = [UIColor clearColor];
        self.filterButton.titleLabel.font = [UIFont ccc_searchBarViewTextFieldAndLabelsFont];
        
        [self.filterButton setTitle:NSLocalizedString(@"Filter", nil) forState:UIControlStateNormal];
        
        [self.filterButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [self.filterButton setTitleColor:[UIColor ccc_lightHighlightedTextColor]
                                forState:UIControlStateHighlighted];
        [self.filterButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        [self.filterButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]
                                forState:UIControlStateSelected|UIControlStateHighlighted];
        [self addSubview:self.filterButton];
        
        self.cancelSearchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
        self.cancelSearchButton.titleEdgeInsets = UIEdgeInsetsMake(1.5, 2.5, 1.5, -2.5);
        
        self.cancelSearchButton.titleLabel.font = [UIFont ccc_searchBarViewTextFieldAndLabelsFont];
        
        [self.cancelSearchButton setTitleColor:[UIColor whiteColor]
                                      forState:UIControlStateNormal];
        [self.cancelSearchButton setTitleColor:[UIColor ccc_lightHighlightedTextColor]
                                      forState:UIControlStateHighlighted];
        
        [self.cancelSearchButton setTitle:NSLocalizedString(@"Cancel", nil)
                                 forState:UIControlStateNormal];
        
        [self addSubview:self.cancelSearchButton];
        
        self.searching = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect slice = CGRectZero;
    CGRect filterRemainder = CGRectZero;
    CGRect cancelRemainder = CGRectZero;
    
    CGRectDivide(self.bounds, &filterRemainder, &slice, self.rightFilterButtonMargin, CGRectMaxXEdge);
    CGRectDivide(self.bounds, &cancelRemainder, &slice, self.rightCancelButtonMargin, CGRectMaxXEdge);
    
    self.textField.frame = UIEdgeInsetsInsetRect(slice, UIEdgeInsetsMake(4.5, 2.0, 4.5, 2.0));
    
    self.filterButton.frame = filterRemainder;
    self.cancelSearchButton.frame = cancelRemainder;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview)
    {
        self.frame = newSuperview.bounds;
    }
}

#pragma mark - Actions

- (void)setSearching:(BOOL)searching
{
    [self setSearching:searching
              animated:NO];
}

- (void)setSearching:(BOOL)searching
            animated:(BOOL)animated
{
    self.filterButton.alpha = 1.0;
    _searching = searching;
    
    void(^animations)(void) = ^{
        
        if (self.searching)
        {
            self.rightCancelButtonMargin = 85.0f;
            self.rightFilterButtonMargin = 128.0f;
        }
        else
        {
            self.rightCancelButtonMargin = 0.0f;
            self.rightFilterButtonMargin = 71.0f;
        }
        
        self.textField.rightView.alpha = self.searching;
        self.backgroundColor = self.searching ? [UIColor ccc_activeSearchBarBlueBackgroundColor] : [UIColor ccc_inactiveSearchBarBlueBackgroundColor];
        [self layoutSubviews];
    };
    
    [UIView animateWithDuration:animated ? 0.4 : 0.0
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:^(BOOL finished) {
                         self.filterButton.alpha = self.searching ? 0.0 : 1.0;
                     }];
}

- (void)clear
{
    self.textField.text = @"";
    self.textField.rightViewMode = UITextFieldViewModeNever;
    [self.textField sendActionsForControlEvents:UIControlEventEditingChanged];
}

@end

@implementation CCCNavigationSearchBarTextField

//Commented as not required. Creating UI issue iOS 11.0 onwards.
/*
- (NSAttributedString *)attributedPlaceholderString
{
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.60],
                                 NSFontAttributeName: [UIFont ccc_searchBarPlaceholderFont],
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                           attributes:attributes];

    return attributedString;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super leftViewRectForBounds:bounds];
    {
        rect = CGRectOffset(rect, 11.0, 0.0);
    }
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super rightViewRectForBounds:bounds];
    {
        rect = CGRectOffset(rect, -5.5, 0.0);
    }
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    {
        rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0.0, 11.0, 0.0, 0.0));
    }
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self editingRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectOffset([super placeholderRectForBounds:bounds], 0.0, 6.0);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[self attributedPlaceholderString] drawInRect:rect];
}*/

@end
