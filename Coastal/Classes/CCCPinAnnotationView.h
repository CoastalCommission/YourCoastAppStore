//
//  CCCPinAnnotationView.h
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import MapKit;

@class CCCPinAnnotationView, CCCCalloutView;

@protocol CCCPinAnnotationViewDelegate <NSObject>

- (void)annotationView:(CCCPinAnnotationView *)view didTapCallout:(CCCCalloutView *)callout;

@end

@interface CCCPinAnnotationView : MKAnnotationView

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, weak) id<CCCPinAnnotationViewDelegate> delegate;

@end
