//
//  CCCMapOverlayRenderer.m
//  Coastal
//
//  Created by Jeremy Petter on 4/12/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import "CCCMapOverlayRenderer.h"
#import "CCCMapOverlay.h"

@interface CCCMapOverlayRenderer ()

@property (nonatomic, strong) CCCMapOverlay *overlay;

@end

@implementation CCCMapOverlayRenderer

@dynamic overlay;

- (instancetype)initWithOverlay:(CCCMapOverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    CGRect rect = [self rectForMapRect:self.overlay.boundingMapRect];

    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -rect.size.height);

    CGContextDrawImage(context, rect, self.overlay.image.CGImage);
}

@end
