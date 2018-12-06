//
//  CCCDownloadQueue.m
//  Coastal
//
//  Created by Jeremy Petter on 4/25/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import "CCCDownloadQueue.h"
#import "CCCUserDefaults.h"
#import "CCCImageManager.h"
#import <CoreLocation/CoreLocation.h>
#import "CCCAccessPoint.h"
#import "CCCMapSnapshotter.h"

@implementation CCCDownloadQueue

+ (instancetype)sharedQueue
{
    static id sharedQueue = nil;

    static dispatch_once_t token;
    dispatch_once(&token, ^{

        sharedQueue = [[[self class] alloc] init];
    });

    return sharedQueue;
}

- (void)downloadQueuedImagesAndMaps
{
    CGSize screenSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    CGFloat screenScale = [UIScreen mainScreen].scale;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray *queuedFavouriteImages = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCUserDefaultsQueuedFavouriteImagesKey] ?: @[];
        NSMutableArray *mutableQueuedFavouriteImages = [queuedFavouriteImages mutableCopy];
        NSLog(@"%@", queuedFavouriteImages);

        NSArray *queuedFavouriteCoordinates = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCUserDefaultsQueuedFavouriteCoordinatesKey] ?: @[];
        NSMutableArray *mutableQueuedFavouriteCoordinates = [queuedFavouriteCoordinates mutableCopy];
        NSLog(@"%@", queuedFavouriteCoordinates);

        for (NSString *string in queuedFavouriteImages)
        {
            // URLWithString() returns a nil in some cases due to some url strings containing spaces.  This sanitizes the url strings before creating the NSURL.
            NSURL *url = [NSURL URLWithDataRepresentation:[string dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil];
            [[CCCImageManager sharedManager] imageForURL:url forceFetch:YES completion:^(UIImage *image, NSURL * url) {

                if (image != nil)
                {
                    NSString *path = [[CCCImageManager sharedManager] documentPathForURL:url];
                    [[CCCImageManager sharedManager] saveImage:image toPath:path];
                    [mutableQueuedFavouriteImages removeObject:string];
                    [[NSUserDefaults standardUserDefaults] setObject:mutableQueuedFavouriteImages
                                                              forKey:CCCUserDefaultsQueuedFavouriteImagesKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSLog(@"Saved an image!");
                }
            }];
        }

        CGFloat mapRatio = screenSize.width / screenSize.height;

        for (NSDictionary *dictionary in queuedFavouriteCoordinates)
        {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([dictionary[kLatitude] doubleValue], [dictionary[kLongitude] doubleValue]);

            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kCCCMapWidth, kCCCMapWidth * mapRatio);

            MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
            options.region = region;
            options.size = screenSize;
            options.scale = screenScale;

            CCCMapSnapshotter *snapshotter = [[CCCMapSnapshotter alloc] initWithOptions:options];
            [snapshotter snapshotAndCacheImageWithHandler:^(UIImage *image) {

                [snapshotter saveImageToDisk];

                __block NSInteger coordinateIndex = -1;
                [mutableQueuedFavouriteCoordinates enumerateObjectsUsingBlock:^(NSDictionary *dictionaryAtIndex, NSUInteger index, BOOL *stop) {

                    if ([dictionary[kLatitude] isEqual:dictionaryAtIndex[kLatitude]] == YES &&
                        [dictionary[kLongitude] isEqual:dictionaryAtIndex[kLongitude]] == YES)
                    {
                        coordinateIndex = index;
                        *stop = YES;
                    }
                }];
                if (coordinateIndex != -1)
                {
                    [mutableQueuedFavouriteCoordinates removeObjectAtIndex:coordinateIndex];
                }

                [[NSUserDefaults standardUserDefaults] setObject:mutableQueuedFavouriteCoordinates
                                                          forKey:CCCUserDefaultsQueuedFavouriteCoordinatesKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"saved a map!");
            }];
        }
    });
}

@end
