//
//  CCCMapOverlayRenderer.h
//  Coastal
//
//  Created by Jeremy Petter on 4/12/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class CCCMapOverlay;

@interface CCCMapOverlayRenderer : MKOverlayRenderer

- (instancetype)initWithOverlay:(CCCMapOverlay *)overlay;

@end
