//
//  CCCFilterViewController.h
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCFilterViewControllerDelegate;

@interface CCCFilterViewController : UIViewController

@property (nonatomic, weak) id <CCCFilterViewControllerDelegate> delegate;

@end

@protocol CCCFilterViewControllerDelegate <NSObject>

- (BOOL)filterViewController:(CCCFilterViewController *)filterViewController
              valueForFilter:(NSString *)filter;

- (void)filterViewController:(CCCFilterViewController *)filterViewController
                 didSetValue:(BOOL)value
                   forFilter:(NSString *)filter;

- (void)filterViewControllerDidReset:(CCCFilterViewController *)filterViewController;

- (NSInteger)totalCountForFilterViewController:(CCCFilterViewController *)filterViewController;
- (NSInteger)filteredCountForFilterViewController:(CCCFilterViewController *)filterViewController;

//This method is invoked when the user taps on "Apply" button
- (void) applyButtonTapped;

@end
