//
//  CCCClusterOverlayRenderer.m
//  Coastal
//
//  Created by Malcolm on 2014-06-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCClusterOverlayRenderer.h"
#import "CCCClusterOverlay.h"

@interface CCCClusterOverlayRenderer ()

@property (atomic, strong) NSAttributedString *attributedString;
@property (atomic, strong) NSAttributedString *strokeAttributedString;
@property (atomic, assign) CGRect boundingRect;

@end

@implementation CCCClusterOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    {
        CCCClusterOverlay *overlay = self.overlay;
        CGRect rect = [self rectForMapRect:overlay.mapRect];

        [[UIColor colorWithRed:0.24 green:0.35 blue:0.63 alpha:0.50] setFill];
        CGContextFillEllipseInRect(context, rect);
    }
    UIGraphicsPopContext();
}

@end
