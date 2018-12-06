//
//  CCCTourViewController.h
//  Coastal
//
//  Created by Ian Hoar on 2014-06-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCTourViewControllerDelegate <NSObject>

- (void)tourDidComplete;

@end

@interface CCCTourViewController : UIViewController

@property (nonatomic, weak) id<CCCTourViewControllerDelegate> delegate;

@end
