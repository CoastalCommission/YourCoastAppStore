//
//  CCCCarouselView.h
//  Coastal
//
//  Created by Oliver White on 1/16/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import UIKit;
@import MapKit;

@class CCCMapSnapshotter;

@interface CCCCarouselView : UIView

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSDictionary *accessPoint;
@property (nonatomic, readonly) CCCMapSnapshotter *snapshotter;

- (void)resetMapView;

@end
