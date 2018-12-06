//
//  CCCAboutScreenViewController.m
//  Coastal
//
//  Created by Cezar on 19/05/16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCAboutViewController.h"
#import "CCCAboutView.h"

@interface CCCAboutViewController ()

@property (nonatomic, strong) CCCAboutView *view;

@end

@implementation CCCAboutViewController

NSString * const FEEDBACK_URL = @"https://docs.google.com/forms/d/10UlT3JDgaxdKk5DyXyHdmGWHlLovSpoCMGBu0QWRTRk/viewform";

@dynamic view;

- (void)loadView
{
    [super loadView];

    self.view = [[CCCAboutView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"About", nil);
    [self.view.feedbackButton addTarget:self action:@selector(feedbackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

- (void)feedbackButtonTapped
{
    NSURL *feedbackURL = [NSURL URLWithString:FEEDBACK_URL];

    if ([[UIApplication sharedApplication] canOpenURL:feedbackURL])
    {
        [[UIApplication sharedApplication] openURL:feedbackURL options:@{} completionHandler:nil];
    }
}

@end
