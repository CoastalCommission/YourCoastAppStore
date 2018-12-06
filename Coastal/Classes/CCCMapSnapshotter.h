//
//  CCCMapSnapshotter.h
//  Coastal
//
//  Created by Jeremy Petter on 4/17/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import <MapKit/MapKit.h>

extern CGFloat const kCCCMapWidth;

@interface CCCMapSnapshotter: MKMapSnapshotter

@property (nonatomic, readonly) UIImage *annotatedImage;

- (void)snapshotAndCacheImageWithHandler:(void(^)(UIImage *))handler;

- (void)saveImageToDisk;

- (void)deleteImageFromDisk;

- (UIImage *)loadImageFromDisk;

@end
