//
//  CCCMapSnapshotter.m
//  Coastal
//
//  Created by Jeremy Petter on 4/17/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import "CCCMapSnapshotter.h"
#import "SDImageCache.h"
#import "CCCImageManager.h"

@interface CCCMapSnapshotter ()

@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong) NSString *mapKey;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *annotatedImage;

@end

NSString * const keyFormat = @"map%f%f";

CGFloat const kCCCMapWidth = 2000;

@implementation CCCMapSnapshotter

- (instancetype)initWithOptions:(MKMapSnapshotOptions *)options
{
    self = [super initWithOptions:options];
    if (self != nil)
    {
        self.region = options.region;
    }
    return self;
}

- (void)deleteImageFromDisk
{
    [[CCCImageManager sharedManager] deleteImageAtPath:self.imagePath];
}

- (UIImage *)loadImageFromDisk
{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.mapKey];
    if (image == nil)
    {
        image = [[CCCImageManager sharedManager] imageAtPath:self.imagePath];
    }
    return image;
}

- (void)saveImageToDisk
{
    [[CCCImageManager sharedManager] saveImage:self.annotatedImage toPath:self.imagePath];
}

- (void)snapshotAndCacheImageWithHandler:(void(^)(UIImage *))handler
{
    [self startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError * error) {

        UIImage *annotationImage = [UIImage imageNamed:@"pin-yellow"];
        CGPoint point = [snapshot pointForCoordinate:self.region.center];

        point.x -= annotationImage.size.width / 2.0;
        point.y -= annotationImage.size.height;

        UIGraphicsBeginImageContextWithOptions(snapshot.image.size, NO, 0.0);
        [snapshot.image drawInRect:CGRectMake(0, 0, snapshot.image.size.width, snapshot.image.size.height)];
        [annotationImage drawInRect:CGRectMake(point.x, point.y, annotationImage.size.width, annotationImage.size.height)];
        self.annotatedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [[SDImageCache sharedImageCache] storeImage:self.annotatedImage forKey:self.mapKey completion:nil];

        // This handler is not used yet, but is here to enable batch saving of maps, if favouriting from outside the carousel view is implemented
        if (handler != nil)
        {
            handler(self.annotatedImage);
        }
    }];
}

#pragma mark - Accessors

- (NSString *)mapKey
{
    CLLocationCoordinate2D coordinate = self.region.center;
    return [NSString stringWithFormat:keyFormat, coordinate.latitude, coordinate.longitude];
}

- (NSString *)imagePath
{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] lastObject];

    return [@[documentsDirectory.path, @"/", self.mapKey, @".png"] componentsJoinedByString:@""];
}


@end
