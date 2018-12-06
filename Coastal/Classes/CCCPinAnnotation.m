//
//  CCCPinAnnotation.m
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCPinAnnotation.h"
#import "CCCAccessPoint.h"

@implementation CCCPinAnnotation
{
    CLLocationCoordinate2D _coordinate;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (void)setAccessPoint:(NSDictionary *)accessPoint
{
    if (_accessPoint != accessPoint)
    {
        _accessPoint = accessPoint;
        _coordinate = CLLocationCoordinate2DMake([accessPoint[kLatitude] doubleValue], [accessPoint[kLongitude] doubleValue]);
    }
}

- (NSString *)title
{
    return @"\0";
}

@end
