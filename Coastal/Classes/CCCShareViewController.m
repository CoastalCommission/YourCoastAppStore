//
//  CCCShareViewController.m
//  Coastal
//
//  Created by Rehat Kathuria on 24/05/2016.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCShareViewController.h"
#import "CCCAccessPoint.h"
#import <SafariServices/SafariServices.h>
#import "UIFont+CCCTypeFoundry.h"
#import "GTMNSString+HTML.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"
#import <MessageUI/MessageUI.h>

@interface CCCShareViewController()
{
    UIView *separatorLine;
    UIButton *submitAPhotoButton;
    UIButton *shareLocationButton;
}

@property (nonatomic, readonly) NSDictionary *accessPoint;

@end

@implementation CCCShareViewController

- (instancetype)initWithAccessPoint:(NSDictionary *)point
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _accessPoint = point;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.00];
    [self.view addSubview:separatorLine];

    UIColor *buttonColor = [UIColor ccc_blueButtonColor];
    submitAPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitAPhotoButton.titleLabel.font = [UIFont ccc_contactCellButtonFont];
    submitAPhotoButton.layer.borderColor = buttonColor.CGColor;
    submitAPhotoButton.layer.borderWidth = 1.0;
    [submitAPhotoButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [submitAPhotoButton setTitle:NSLocalizedString(@"Submit A Photo", nil) forState:UIControlStateNormal];
    [submitAPhotoButton addTarget:self action:@selector(submitAPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitAPhotoButton];

    shareLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareLocationButton.titleLabel.font = [UIFont ccc_contactCellButtonFont];
    shareLocationButton.layer.borderColor = buttonColor.CGColor;
    shareLocationButton.layer.borderWidth = 1.0;
    [shareLocationButton setTitleColor:buttonColor forState:UIControlStateNormal];
    [shareLocationButton setTitle:NSLocalizedString(@"Share Location", nil) forState:UIControlStateNormal];
    [shareLocationButton addTarget:self action:@selector(shareLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareLocationButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    separatorLine.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width * 0.90f, 1.0);
    separatorLine.center = CGPointMake(self.view.bounds.size.width * 0.5, 1.0);

    [submitAPhotoButton sizeToFit];
    submitAPhotoButton.frame = CGRectMake(submitAPhotoButton.frame.origin.x, submitAPhotoButton.frame.origin.y, self.view.bounds.size.width * 0.43f, submitAPhotoButton.frame.size.height + 6.0);
    submitAPhotoButton.layer.cornerRadius = submitAPhotoButton.frame.size.height / 2.0;
    submitAPhotoButton.center = CGPointMake(self.view.bounds.size.width / 2 - shareLocationButton.frame.size.width / 2 - 6.0, self.view.bounds.size.height * 0.50f);

    [shareLocationButton sizeToFit];
    shareLocationButton.frame = CGRectMake(shareLocationButton.frame.origin.x, shareLocationButton.frame.origin.y, self.view.bounds.size.width * 0.43f, shareLocationButton.frame.size.height + 6.0);
    shareLocationButton.layer.cornerRadius = shareLocationButton.frame.size.height / 2.0;
    shareLocationButton.center = CGPointMake(self.view.bounds.size.width / 2 + shareLocationButton.frame.size.width / 2 + 6.0, self.view.bounds.size.height * 0.50f);
}

- (void)shareLocation
{
    NSString *name = [_accessPoint[kName] gtm_stringByUnescapingFromHTML];
    NSString *location = [_accessPoint[kLocation] gtm_stringByUnescapingFromHTML];

    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithCapacity:3];
    [shareItems addObject:name];
    if (location != nil && ![location isEqualToString:@""]) {
        [shareItems addObject:location];
    }

    NSString *shareText = [shareItems componentsJoinedByString:@"\n"];
    NSURL *shareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.coastal.ca.gov/YourCoast/#/map/location/id/%@", _accessPoint[kID]]];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, shareURL]
                                                                                         applicationActivities:nil];

    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeAirDrop,
                                   UIActivityTypePostToWeibo,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeOpenInIBooks,
                                   ];

    activityViewController.excludedActivityTypes = excludeActivities;

    [self.delegate shareViewController:self didRequestToPresentShareViewController:activityViewController];
}

- (void)submitAPhoto
{
    if ([MFMailComposeViewController canSendMail] == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Your email client is not set up.  Please do this before submitting a photo.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        __weak typeof(self) weakSelf = self;

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Accept Terms & Conditions", nil) message:NSLocalizedString(@"\nBy accepting you agree to the following terms:\n\n1. You took the photograph and have rights to the image.\n2. The Coastal Commission may use the image pursuant to the Coastal Commission's Terms of Use and Privacy Policy.\n3. The image does not contain objectionable imagery.\n4. There is no guarantee that the image will be used, or that the Coastal Commission will respond to the submittal.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"I Accept", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

            [weakSelf.delegate uploadPhoto];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
