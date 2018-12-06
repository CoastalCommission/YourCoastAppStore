//
//  CCCMapOverlay.h
//  Coastal
//
//  Created by Jeremy Petter on 4/12/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CCCMapOverlay : NSObject <MKOverlay>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordiante
                            region:(MKCoordinateRegion)region
                             image:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@property (readonly, assign)MKMapRect boundingMapRect;
@property (readonly, assign)CLLocationCoordinate2D coordinate;
@property (readonly, strong)UIImage *image;

@end
