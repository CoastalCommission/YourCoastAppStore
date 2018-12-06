//
//  CCCCombinedView.h
//  Coastal
//
//  Created by Malcolm on 2014-05-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import UIKit;
@import MapKit;

#import "MLXButton.h"
#import "CCCFilterDigestView.h"

@class CCCSearchBarView;
@protocol CCCCombinedViewDelegate;

@interface CCCCombinedView : UIView

@property (nonatomic, readonly) MKMapView *hiddenMapView;
@property (nonatomic, readonly) MKMapView *mapView;
@property (nonatomic, readonly) UIView *grabView;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UIView *hammerView;
@property (nonatomic, readonly) UILabel *leftGrabLabel;
@property (nonatomic, readonly) UILabel *rightGrabLabel;
@property (nonatomic, readonly) UIView *outsideCaliView;
@property (nonatomic, readonly) UILabel *outsideCaliViewLabel;

@property (nonatomic, readonly) CCCFilterDigestView *filterDigestView;

@property (nonatomic, assign) BOOL hasResults;
@property (nonatomic, assign) BOOL outOfBounds;

@property (nonatomic, readonly) MLXButton *currentLocationButton;
@property (nonatomic, readonly) MLXButton *entireCoastButton;
@property (nonatomic, readonly) MLXButton *scrollTopButton;

@property (nonatomic, readonly) CCCSearchBarView *searchBarView;

@property (nonatomic, weak) id <CCCCombinedViewDelegate> delegate;

@property (nonatomic, assign) BOOL listOpen;

- (void)setListOpen:(BOOL)listOpen
           animated:(BOOL)animated;

- (void)setListOpen:(BOOL)listOpen
           animated:(BOOL)animated
    initialVelocity:(CGFloat)initialVelocity; // points per second

- (void)layoutMapView;

@end

@protocol CCCCombinedViewDelegate <NSObject>

- (void)combinedViewListOpenDidChange:(CCCCombinedView *)combinedView;

@end
