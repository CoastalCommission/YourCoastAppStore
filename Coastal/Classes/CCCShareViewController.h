//
//  CCCShareViewController.h
//  Coastal
//
//  Created by Rehat Kathuria on 24/05/2016.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@protocol CCCShareViewControllerDelegate;

@interface CCCShareViewController : UIViewController

-(instancetype)initWithAccessPoint:(NSDictionary *)point;
@property (nonatomic, weak) id<CCCShareViewControllerDelegate> delegate;

@end

@protocol CCCShareViewControllerDelegate <NSObject>

-(void)shareViewController:(CCCShareViewController *)controller didRequestToPresentShareViewController:(UIViewController *)requestedController;

-(void)uploadPhoto;

@end
