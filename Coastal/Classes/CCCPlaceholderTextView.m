//
//  CCCPlaceholderTextView.m
//  Coastal
//
//  Created by Malcolm on 2014-04-28.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCPlaceholderTextView.h"

@interface CCCPassthroughTextView : UITextView @end


@implementation CCCPlaceholderTextView
{
    UITextView *_placeholderTextView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _placeholderTextView = [[CCCPassthroughTextView alloc] initWithFrame:self.bounds];
        {
            _placeholderTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            _placeholderTextView.editable = NO;
            _placeholderTextView.hidden = NO;
            _placeholderTextView.backgroundColor = [UIColor clearColor];
            _placeholderTextView.scrollsToTop = NO;
        }
        [self addSubview:_placeholderTextView];

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(textDidChange)
                                   name:UITextViewTextDidChangeNotification
                                 object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _placeholderTextView.frame = self.bounds;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];

    _placeholderTextView.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];

    _placeholderTextView.textColor = [textColor colorWithAlphaComponent:0.3];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];

    _placeholderTextView.contentInset = contentInset;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];

    _placeholderTextView.textContainerInset = textContainerInset;
}

- (void)setText:(NSString *)text
{
    [super setText:text];

    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];

    [self textDidChange];
}

- (void)textDidChange
{
    _placeholderTextView.hidden = ([self.text length] != 0);
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholderTextView.text = placeholder;
}

- (NSString *)placeholder
{
    return _placeholderTextView.text;
}

@end

@implementation CCCPassthroughTextView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point
                        withEvent:event];
    return (view == self) ? nil : view;
}

@end
