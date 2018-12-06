//
//  CCCPinAnnotation.h
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import MapKit;

@interface CCCPinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDictionary *accessPoint;

@property (nonatomic, strong) NSString *color;

@end
