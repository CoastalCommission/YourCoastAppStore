//
//  CCCRootViewController.m
//  Coastal
//
//  Created by Oliver White on 2/20/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCRootViewController.h"
#import "CCCCombinedViewController.h"
#import "CCCTourViewController.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCRootViewController ()
<
CCCTourViewControllerDelegate
>
{
    CCCTourViewController *_tourController;
    UINavigationController *_mainNavigationController;
}

@end

@implementation CCCRootViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadView
{
    [super loadView];

    CCCCombinedViewController *viewController = [[CCCCombinedViewController alloc] init];

    _mainNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    _mainNavigationController.navigationBar.barTintColor = [UIColor ccc_navigationBarBlueTintColor];
    _mainNavigationController.navigationBar.translucent = NO;
    [_mainNavigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelFont]
                                                                      }];

    //Removes the line and shadow shown below the navigation bar. Both the backgroundImage and shadowImage must be set to achieve this.
    [_mainNavigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];

    [_mainNavigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

    [self addChildViewController:_mainNavigationController];

    [_mainNavigationController.view setFrame:self.view.frame];
    
    [self.view addSubview:_mainNavigationController.view];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hasSeenTour"] == nil)
    {
        _tourController = [[CCCTourViewController alloc] init];
        {
            _tourController.delegate = self;
        }
        [self.view addSubview:_tourController.view];

        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"hasSeenTour"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)tourDidComplete
{
    [_tourController.view removeFromSuperview];
    _tourController = nil;
}

@end
