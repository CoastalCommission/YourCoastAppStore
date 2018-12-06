//
//  CCCTourViewController.m
//  Coastal
//
//  Created by Ian Hoar on 2014-06-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCTourViewController.h"
#import "CCCTourView.h"

@interface CCCTourViewController () <CCCTourViewDelegate>

@end

@implementation CCCTourViewController

- (void)loadView
{
    [super loadView];

    CCCTourView *tourView = [[CCCTourView alloc] initWithFrame:self.view.frame];
    tourView.delegate = self;
    self.view = tourView;
}

- (void)tourDidComplete
{
    [self.delegate tourDidComplete];
}

@end
