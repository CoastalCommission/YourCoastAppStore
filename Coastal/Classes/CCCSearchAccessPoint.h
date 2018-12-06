//
//  CCCSearchAccessPoint.h
//  Coastal
//
//  Created by Dai Hovey on 27/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface CCCSearchAccessPoint : NSObject

@property (nonatomic, strong) NSDictionary *accessPoint;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSDate *dateAdded;

@end
