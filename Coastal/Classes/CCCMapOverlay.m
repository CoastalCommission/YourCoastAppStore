//
//  CCCMapOverlay.m
//  Coastal
//
//  Created by Jeremy Petter on 4/12/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import "CCCMapOverlay.h"

@interface CCCMapOverlay ()

@property (nonatomic, assign)MKMapRect boundingMapRect;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, strong)UIImage *image;

@end

@implementation CCCMapOverlay 

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordiante region:(MKCoordinateRegion)region image:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.boundingMapRect = [self mapRectForCoordinateRegion:region];
        self.coordinate = coordiante;
        self.image = image;
    }
    return self;
}

- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));

    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

@end
