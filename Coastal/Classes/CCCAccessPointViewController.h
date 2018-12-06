//
//  CCCAccessPointViewController.h
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import UIKit;
@class CCCAccessPointViewController;

@protocol CCCAccessPointViewControllerDelegate <NSObject>

- (void)accessPointController:(CCCAccessPointViewController *)accessPointController didFavouriteAccessPoint:(NSDictionary *)accessPoint;

@end

@interface CCCAccessPointViewController : UIViewController

@property (nonatomic, strong) NSDictionary *accessPoint;
@property (nonatomic, weak) id<CCCAccessPointViewControllerDelegate> delegate;

@end
