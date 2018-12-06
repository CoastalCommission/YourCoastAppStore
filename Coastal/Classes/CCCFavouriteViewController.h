//
//  CCCFavouriteViewController.h
//  Coastal
//
//  Created by Dai Hovey on 18/12/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCFavouriteViewControllerDelegate;

@interface CCCFavouriteViewController : UITableViewController

@property (nonatomic, strong) NSArray *favourites;

@property (nonatomic, weak) id <CCCFavouriteViewControllerDelegate> delegate;

@end

@protocol CCCFavouriteViewControllerDelegate <NSObject>

- (void)favouriteViewController:(CCCFavouriteViewController *)favouriteResultsViewController
               didSelectAccessPoint:(NSDictionary *)accessPoint;
@end
