//
//  CCCForwardingTouchView.m
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCForwardingTouchView.h"

@implementation CCCForwardingTouchView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point
                        withEvent:event];
    return view == self ? self.view : view;
}

@end
