//
//  CCCCarouselView.m
//  Coastal
//
//  Created by Oliver White on 1/16/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCCarouselView.h"
#import "CCCAccessPoint.h"
#import "CCCMapOverlay.h"
#import "CCCMapOverlayRenderer.h"
#import "CCCPinAnnotation.h"
#import "CCCPinAnnotationView.h"
#import "GAI+CCC.h"
#import "CCCMapSnapshotter.h"
#import "SDImageCache.h"
#import "GTMNSString+HTML.h"

@interface CCCCarouselView () <MKMapViewDelegate>
{
    MKMapView *_mapView;
    MKCoordinateRegion _region;
    CCCMapSnapshotter *_snapshotter;
}

@end

@implementation CCCCarouselView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        [self addSubview:_mapView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _mapView.frame = self.bounds;
}

- (void)resetMapView
{
    self.coordinate = self.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;

    BOOL animated = (self.superview != nil);

    CGFloat mapRatio = self.bounds.size.width / self.bounds.size.height;
    _region = MKCoordinateRegionMakeWithDistance(_coordinate, kCCCMapWidth, kCCCMapWidth * mapRatio);

    _mapView.delegate = self;
    _mapView.userInteractionEnabled = NO;
    
    [_mapView setRegion:_region
               animated:animated];

    _mapView.showsUserLocation = YES;

    [_mapView removeAnnotations:[_mapView annotations]];
    
    CCCPinAnnotation *annotation = [[CCCPinAnnotation alloc] init];
    annotation.coordinate = _coordinate;
    annotation.color = @"pin-yellow";

    [_mapView addAnnotation:annotation];

    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = _region;
    options.size = self.bounds.size;
    options.scale = [UIScreen mainScreen].scale;

    _snapshotter = [[CCCMapSnapshotter alloc] initWithOptions:options];

    [_snapshotter snapshotAndCacheImageWithHandler:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    UIImage *image = [_snapshotter loadImageFromDisk];

    if (image != nil)
    {
        [_mapView removeAnnotations:[_mapView annotations]];
        CCCMapOverlay *overlay = [[CCCMapOverlay alloc] initWithCoordinate:_coordinate region:_region image:image];
        [_mapView addOverlay:overlay];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[CCCMapOverlay class]])
    {
        CCCMapOverlayRenderer *overlayRenderer = [[CCCMapOverlayRenderer alloc] initWithOverlay:overlay];
        return overlayRenderer;
    }
    return [[MKOverlayRenderer alloc] init];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CCCPinAnnotation class]])
    {
        static NSString * const identifier = @"CCCPinAnnotationView";
        
        CCCPinAnnotation *pinAnnotation = annotation;
        CCCPinAnnotationView *annotationView = (CCCPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil)
        {
            annotationView = [[CCCPinAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:identifier];
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        annotationView.titleText = [pinAnnotation.accessPoint[kName] gtm_stringByUnescapingFromHTML];
        
        return annotationView;
    }
    
    return nil;
}

@end
