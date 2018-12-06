//
//  CCCClusterOverlay.h
//  Coastal
//
//  Created by Malcolm on 2014-06-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface CCCClusterOverlay : NSObject <MKOverlay>

@property (nonatomic, assign) MKMapRect mapRect;
@property (nonatomic, strong) NSSet *annotations;

@property (atomic, strong) NSAttributedString *attributedString;

@end
