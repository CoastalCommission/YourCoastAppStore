//
//  MLXButton.m
//
//  Copyright (c) 2013 MetaLab.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MLXButton.h"

@interface MLXButton ()

@property (nonatomic, strong) NSMutableDictionary *backgroundColors;
@property (nonatomic, strong) NSMutableDictionary *tintColors;

@end

@implementation MLXButton

- (void)setBackgroundColor:(UIColor *)color
                  forState:(UIControlState)state
{
    if (color)
    {
        self.backgroundColors[@(state)] = color;
    }
    else
    {
        [self.backgroundColors removeObjectForKey:@(state)];
    }

    [self updateBackgroundColor];
}

- (void)setTintColor:(UIColor *)tintColor
            forState:(UIControlState)state
{
    if (tintColor)
    {
        self.tintColors[@(state)] = tintColor;
    }
    else
    {
        [self.tintColors removeObjectForKey:@(state)];
    }

    [self updateTintColor];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return self.backgroundColors[@(state)];
}

- (UIColor *)tintColorForState:(UIControlState)state
{
    return self.tintColors[@(state)];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self setBackgroundColor:backgroundColor
                    forState:UIControlStateNormal];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [self setTintColor:tintColor
              forState:UIControlStateNormal];
}

- (NSMutableDictionary *)backgroundColors
{
    if (_backgroundColors == nil)
    {
        _backgroundColors = [[NSMutableDictionary alloc] init];
    }
    return _backgroundColors;
}

- (NSMutableDictionary *)tintColors
{
    if (_tintColors == nil)
    {
        _tintColors = [[NSMutableDictionary alloc] init];
    }
    return _tintColors;
}

- (void)updateBackgroundColor
{
    super.backgroundColor = self.backgroundColors[@(self.state)] ?: self.backgroundColors[@(UIControlStateNormal)];
}

- (void)updateTintColor
{
    super.tintColor = self.tintColors[@(self.state)] ?: self.tintColors[@(UIControlStateNormal)];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    [self updateBackgroundColor];
    [self updateTintColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    [self updateBackgroundColor];
    [self updateTintColor];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    [self updateBackgroundColor];
    [self updateTintColor];
}

@end
