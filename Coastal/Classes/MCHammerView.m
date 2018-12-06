//
//  MCHammerView.m
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "MCHammerView.h"

@implementation MCHammerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point
                        withEvent:event];

    if (view == self && self.youCANTouchThis)
    {
        CGPoint hitPoint = [self.youCANTouchThis convertPoint:point
                                                     fromView:self];

        return [self.youCANTouchThis hitTest:hitPoint
                                   withEvent:event];
    }

    return view;
}

@end
