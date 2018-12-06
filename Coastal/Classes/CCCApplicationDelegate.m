//
//  CCCApplicationDelegate.m
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCApplicationDelegate.h"
#import "CCCRootViewController.h"
#import "UIApplication+MLX.h"
#import "CCCRootViewController.h"
#import "UIFont+CCCTypeFoundry.h"
#import "CCCDownloadQueue.h"

// AdSupport, CoreData, and SystemConfiguration are needed for Google Analytics
@import AdSupport;
@import CoreData;
@import SystemConfiguration;
#import "GAI+CCC.h"

int main(int argc, char * argv[])
{
    @autoreleasepool
    {
        NSString *delegateClassName = NSStringFromClass([CCCApplicationDelegate class]);
        return UIApplicationMain(argc, argv, nil, delegateClassName);
    }
}

@implementation CCCApplicationDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)options
{
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50508900-1"];

    [GAI ccc_startSession];

    CGRect rect = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:rect];

    [self applyAppearance];

    self.window.rootViewController = [[CCCRootViewController alloc] init];

    [self.window makeKeyAndVisible];

    [[NSNotificationCenter defaultCenter] addObserver:[CCCDownloadQueue sharedQueue] selector:@selector(downloadQueuedImagesAndMaps) name:UIApplicationSignificantTimeChangeNotification object:nil];

    return YES;
}

- (void)applyAppearance
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont ccc_barButtonNormalFont],
                                 };
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelFont],
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCCDownloadQueue sharedQueue] downloadQueuedImagesAndMaps];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [GAI ccc_startSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [GAI ccc_endSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [GAI ccc_endSession];
}

@end
