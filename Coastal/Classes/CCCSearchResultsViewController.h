//
//  CCCSearchResultsViewController.h
//  Coastal
//
//  Created by Malcolm on 2014-06-04.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@protocol CCCSearchResultsViewControllerDelegate;

@interface CCCSearchResultsViewController : UITableViewController

@property (nonatomic, copy) NSString *searchTerm;

@property (nonatomic, strong) NSArray *accessPoints;
@property (nonatomic, strong) NSSet *filters;

@property (nonatomic, weak) id <CCCSearchResultsViewControllerDelegate> delegate;

@end

@protocol CCCSearchResultsViewControllerDelegate <NSObject>

- (void)searchResultsViewController:(CCCSearchResultsViewController *)searchResultsViewController
               didSelectAccessPoint:(NSDictionary *)accessPoint;
- (void)searchResultsViewController:(CCCSearchResultsViewController *)searchResultsViewController
                 didSelectPlacemark:(CLPlacemark *)placemark;
-(void)displayFiltersTable:(CCCSearchResultsViewController *)searchResultsViewController;
-(void)setSearchShouldNotBecomeFirstResponder:(BOOL)searchShouldNotBecomeFirstResponder;

@end
