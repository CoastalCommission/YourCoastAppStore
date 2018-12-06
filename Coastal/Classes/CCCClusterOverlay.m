//
//  CCCClusterOverlay.m
//  Coastal
//
//  Created by Malcolm on 2014-06-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCClusterOverlay.h"

@implementation CCCClusterOverlay

@synthesize coordinate = _coordinate;
@synthesize attributedString = _attributedString;

- (MKMapRect)boundingMapRect
{
    return self.mapRect;
}

- (void)setMapRect:(MKMapRect)mapRect
{
    _mapRect = mapRect;

    MKMapPoint center = MKMapPointMake(MKMapRectGetMidX(_mapRect), MKMapRectGetMidY(_mapRect));
    _coordinate = MKCoordinateForMapPoint(center);
}

@end
