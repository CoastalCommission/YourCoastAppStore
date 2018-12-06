//
//  CCCCoordinate.h
//  Coastal
//
//  Created by Malcolm on 2014-05-16.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface CCCCoordinate : NSObject <NSCopying>

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
