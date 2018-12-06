//
//  CCCAccessPointViewController.m
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCAccessPointViewController.h"
#import "CCCDescriptionCell.h"
#import "CCCCarouselView.h"
#import "CCCAccessPoint.h"
#import "CCCMapSnapshotter.h"
#import "CCCDataClient.h"
#import "MCHammerView.h"
#import "CCCFeatureCell.h"
#import "CCCContactCell.h"
#import "CCCFilterCell.h"
#import "GAI+CCC.h"
#import "CCCForwardingTouchView.h"
#import "CCCAmenitiesHeaderCell.h"
#import "CCCShareViewController.h"
#import <SafariServices/SafariServices.h>
#import "UIFont+CCCTypeFoundry.h"
#import "CCCAccessPointImagesCell.h"
#import "CCCPhotosViewController.h"
#import "CCCThumbnailView.h"
#import "CCCUserDefaults.h"
#import "CCCPhoto.h"
#import "CCCImageManager.h"
#import "GTMNSString+HTML.h"
#import "CCCFilterCell.h"
#import "UIColor+CCCColorPallete.h"
#import "QBImagePickerController.h"
#import "UIColor+CCCColorPallete.h"
#import <MessageUI/MessageUI.h>

@interface CCCAccessPointViewController () <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCCShareViewControllerDelegate, CCCThumbnailViewDelegate, CCCPhotosViewControllerDelegate, QBImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *clippingView;
@property (nonatomic, strong) CCCCarouselView *carouselView;

@property (nonatomic, strong) CCCAccessPointImagesCell *imagesCell;
@property (nonatomic, strong) UIView *imagesCaptionView;
@property (nonatomic, strong) CCCThumbnailView *thumbnailView;

@property (nonatomic, strong) CCCShareViewController *shareViewController;

@property (nonatomic, strong) NSArray *features;
@property (nonatomic, strong) NSMutableArray *accessPointPhotos;
@property (nonatomic, assign) BOOL hasNoPhotos;

- (void)back:(id)sender;
- (void)favourite:(id)sender;
- (void)directions:(id)sender;
- (void)call:(id)sender;

@end

@implementation CCCAccessPointViewController

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)favourite:(id)sender
{
    id identifier = self.accessPoint[kID];

    NSMutableArray *favourites = [([[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey] ?: @[]) mutableCopy];

    [favourites containsObject:identifier] ? [favourites removeObject:identifier] : [favourites addObject:identifier];

    [[NSUserDefaults standardUserDefaults] setObject:favourites
                                              forKey:CCCFavouritesUserDefaultsKey];

    [GAI ccc_sendEvent:@"access point"
                action:@"favorite"
                 label:self.accessPoint[kName]
                 value:@([favourites containsObject:identifier])];

    [self.delegate accessPointController:self didFavouriteAccessPoint:self.accessPoint];

    BOOL favourited = [favourites containsObject:identifier];

    NSMutableArray *queuedFavouriteImages = [([[NSUserDefaults standardUserDefaults] arrayForKey:CCCUserDefaultsQueuedFavouriteImagesKey] ?: @[]) mutableCopy];
    NSMutableArray *queuedFavouriteCoordinates = [([[NSUserDefaults standardUserDefaults] arrayForKey:CCCUserDefaultsQueuedFavouriteCoordinatesKey] ?: @[]) mutableCopy];

    [self configureNavigationItemForFavourited:favourited];

    if (favourited)
    {
        if (_carouselView.snapshotter.annotatedImage != nil)
        {
            [_carouselView.snapshotter saveImageToDisk];
        }
        else
        {
            NSDictionary *coordinates = @{
                                          kLatitude: self.accessPoint[kLatitude],
                                          kLongitude: self.accessPoint[kLongitude],
                                          };
            [queuedFavouriteCoordinates addObject:coordinates];
        }

        for (CCCPhoto *photo in _accessPointPhotos)
        {
            if (photo.image != nil)
            {
                CCCImageManager *imageManager = [CCCImageManager sharedManager];
                [imageManager saveImage:photo.image toPath:[imageManager documentPathForURL:photo.url]];
            }
            else
            {
                NSString *urlString = [photo.url absoluteString];
                if ([queuedFavouriteImages containsObject:urlString] == NO)
                {
                    [queuedFavouriteImages addObject:urlString];
                }
            }
        }
    }
    else
    {
        [_carouselView.snapshotter deleteImageFromDisk];

        __block NSInteger coordinateIndex = -1;
        [queuedFavouriteCoordinates enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {

            if ([dictionary[kLatitude] isEqual:self.accessPoint[kLatitude]] == YES &&
                [dictionary[kLongitude] isEqual:self.accessPoint[kLongitude]] == YES)
            {
                coordinateIndex = index;
                *stop = YES;
            }
        }];
        if (coordinateIndex != -1)
        {
            [queuedFavouriteCoordinates removeObjectAtIndex:coordinateIndex];
        }

        for (CCCPhoto *photo in _accessPointPhotos)
        {
            CCCImageManager *imageManager = [CCCImageManager sharedManager];
            [imageManager deleteImageAtPath:[imageManager documentPathForURL:photo.url]];

            NSString *urlString = [photo.url absoluteString];
            if ([queuedFavouriteImages containsObject:urlString] == YES)
            {
                [queuedFavouriteImages removeObject:urlString];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:queuedFavouriteImages
                                              forKey:CCCUserDefaultsQueuedFavouriteImagesKey];
    [[NSUserDefaults standardUserDefaults] setObject:queuedFavouriteCoordinates
                                              forKey:CCCUserDefaultsQueuedFavouriteCoordinatesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)directions:(id)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    if ([[UIApplication sharedApplication] canOpenURL:[[NSURL alloc] initWithString:@"comgooglemaps://"]])
    {
        UIAlertAction *googleMapsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open in Google Maps", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
            NSString *string = [[NSString alloc] initWithFormat:@"comgooglemaps://?daddr=%f,%f", [self.accessPoint[kLatitude] doubleValue], [self.accessPoint[kLongitude] doubleValue]];
            NSURL *googleMapsURL = [[NSURL alloc] initWithString:string];
            [[UIApplication sharedApplication] openURL:googleMapsURL options:@{} completionHandler:nil];
            
            [GAI ccc_sendEvent:@"access point"
                        action:@"directions"
                         label:self.accessPoint[kName]
                         value:nil];
        }];
        [controller addAction:googleMapsAction];
    }

    UIAlertAction *appleMapsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open in Apple Maps", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        NSString *string = [[NSString alloc] initWithFormat:@"http://maps.apple.com/?daddr=%f,%f", [self.accessPoint[kLatitude] doubleValue], [self.accessPoint[kLongitude] doubleValue]];
        NSURL *appleMapsURL = [[NSURL alloc] initWithString:string];
        [[UIApplication sharedApplication] openURL:appleMapsURL options:@{} completionHandler:nil];
        
        [GAI ccc_sendEvent:@"access point"
                    action:@"directions"
                     label:self.accessPoint[kName]
                     value:nil];
    }];
    [controller addAction:appleMapsAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)call:(id)sender
{
    NSString *string = self.accessPoint[kPhone];
    if ([string length] > 0)
    {
        [GAI ccc_sendEvent:@"access point"
                    action:@"call"
                     label:self.accessPoint[kName]
                     value:nil];

        string = [@"tel:" stringByAppendingString:string];

        NSURL *url = [[NSURL alloc] initWithString:string];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)pushAppropriateSafariViewControllerWithAccessPointSearchTerm
{
    NSString *name = [[[_accessPoint objectForKey:kName] gtm_stringByUnescapingFromHTML]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@", name]];
    
    if ([SFSafariViewController class] != nil)
    {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:searchURL];
        [self presentViewController:controller animated:true completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:searchURL options:@{} completionHandler:nil];
    }
}

- (void)configureNavigationItemForFavourited:(BOOL)favourited
{
            self.navigationItem.rightBarButtonItem.image = ^{

                if (favourited)
                {
                    return [[UIImage imageNamed:@"favourites-alternate"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                }
                return self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"favourites-default"];
            }();
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger sections[] = {1, (_hasNoPhotos ? 0 : 1), 1 + (([self.accessPoint[kPhone] length] > 0) ? 1 : 0) + (([_features count] > 0) ? 1 + [_features count] : 0), 1 };
    return sections[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        CCCDescriptionCell *cell = [[CCCDescriptionCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                             reuseIdentifier:nil];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.text = [self.accessPoint[kName] gtm_stringByUnescapingFromHTML];
        cell.detailTextView.text = [self.accessPoint[kDescription] gtm_stringByUnescapingFromHTML];
        
        return cell;
    }

    else if (indexPath.section == 1)
    {
        _imagesCell = [[CCCAccessPointImagesCell alloc] initWithPhotos:_accessPointPhotos];

        _imagesCell.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
        _imagesCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _imagesCell.thumbnailView.delegate = self;

        return _imagesCell;
    }
    else if (indexPath.section == 2)
    {
        CCCContactCell *cell = [[CCCContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                     reuseIdentifier:nil];
        cell.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Address", nil);
            cell.detailTextLabel.text = [self.accessPoint[kLocation] gtm_stringByUnescapingFromHTML];

            [cell.button setTitle:NSLocalizedString(@"Directions", nil)
                         forState:UIControlStateNormal];

            [cell.button addTarget:self
                            action:@selector(directions:)
                  forControlEvents:UIControlEventTouchUpInside];
        }
        else if ([self.accessPoint[kPhone] length] > 0 && indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Phone", nil);
            cell.detailTextLabel.text = [self.accessPoint[kPhone] length] ? self.accessPoint[kPhone] : NSLocalizedString(@"Unavailable", nil);

            [cell.button setTitle:NSLocalizedString(@"Call", nil)
                         forState:UIControlStateNormal];

            [cell.button addTarget:self
                            action:@selector(call:)
                  forControlEvents:UIControlEventTouchUpInside];
        }
        else if (([self.accessPoint[kPhone] length] == 0 && indexPath.row == 1) || ([self.accessPoint[kPhone] length] > 0 && indexPath.row == 2))
        {
            CCCAmenitiesHeaderCell *cell = [[CCCAmenitiesHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                               reuseIdentifier:nil];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"Amenities", nil);
            return cell;
        }
        else
        {
            // 'Address' and 'Amenities' rows, plus the phone number row, if it is shown
            NSUInteger offset  = ([self.accessPoint[kPhone] length] > 0 == YES) ? 3 : 2;

            CCCFeatureCell *cell = [[CCCFeatureCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:nil];
            NSString *key = _features[indexPath.row - offset];
            
            cell.separatorInset = UIEdgeInsetsMake(0.0, self.view.frame.size.width, 0.0, 0.0);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = [CCCFilterCell localizedStringForFilter:key];
            if ([key isEqualToString:kFee]) {
                cell.textLabel.text = NSLocalizedString(@"Fees", nil); // By default this filter says "No Fees" but if a location contains this feature then it is a paid location. So, we change it to say "Fees"
            }
            cell.imageView.image = [CCCFilterCell largeIconForFilter:key];

            if ([key isEqualToString:kDisabled] == YES && [self.accessPoint[kBeachWheelchair] isEqualToString:@""] == NO)
            {
                cell.detailTextView.text = self.accessPoint[kBeachWheelchair];
            }

            cell.adjustment = (indexPath.row == offset - 1) ? 8.0 : (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) ? 0.0 : 0.0;

            return cell;

        }

        return cell;
    }
    else
    {
        
        CCCFeatureCell *cell = [[CCCFeatureCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                     reuseIdentifier:nil];
     
        cell.secondaryIconImage = [UIImage imageNamed:@"external-link-icon"];
        cell.separatorInset = UIEdgeInsetsMake(0.0, self.view.frame.size.width, 0.0, 40.0);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = [CCCFilterCell localizedStringForFilter:kSearchForMoreInformation];
        cell.textLabel.textColor = [UIColor colorWithRed:0.39 green:0.57 blue:0.95 alpha:1.00];
        
        cell.adjustment = 0.0;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        CCCDescriptionCell *cell = [[CCCDescriptionCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                             reuseIdentifier:nil];
        cell.separatorInset = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.text = [self.accessPoint[kName] gtm_stringByUnescapingFromHTML];
        cell.detailTextView.text = [self.accessPoint[kDescription] gtm_stringByUnescapingFromHTML];

        [cell layoutSubviews];

        return CGRectGetMaxY(cell.detailTextView.frame) + CGRectGetMinY(cell.textLabel.frame);
    }
    else if (indexPath.section == 1)
    {
        return _hasNoPhotos ? 0 : 110;
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
            return 100.0;

        if (([self.accessPoint[kPhone] length] > 0) && indexPath.row == 1)
            return 100.0;

        NSUInteger offset = 1;
        if ([self.accessPoint[kPhone] length] > 0)
            offset++;

        if (([self.accessPoint[kPhone] length] == 0 && indexPath.row == 1) || ([self.accessPoint[kPhone] length] > 0 && indexPath.row == 2))
        {
            return 30;
        }

        if (indexPath.row == offset || indexPath.row == (offset + [_features count] - 1))
        {
            return 45.0;
        }

        NSString *key = _features[indexPath.row - offset - 1];

        if ([key isEqualToString:kDisabled] == YES && [self.accessPoint[kBeachWheelchair] isEqualToString:@""] == NO)
        {
            CCCFeatureCell *cell = [[CCCFeatureCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

            cell.separatorInset = UIEdgeInsetsMake(0.0, self.view.frame.size.width, 0.0, 0.0);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.text = [CCCFilterCell localizedStringForFilter:key];
            cell.detailTextView.text = self.accessPoint[kBeachWheelchair];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_large", key].lowercaseString];

            cell.adjustment = 0.0;

            [cell layoutSubviews];

            return CGRectGetMaxY(cell.detailTextView.frame) + CGRectGetMinY(cell.textLabel.frame);
        }
        return 45.0;
    }
    else if (indexPath.section == 3)
    {
        return 45.0;
    }

    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 0.0)];

        [view addSubview:^{

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 2.0)];
            view.backgroundColor = [UIColor whiteColor];

            return view;
        }()];

        return view;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        [_carouselView resetMapView];
    }
    else if (indexPath.section == 3)
    {
     
        [self pushAppropriateSafariViewControllerWithAccessPointSearchTerm];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGRect frame = _tableView.tableHeaderView.bounds;
    {
        CGFloat contentOffsetY = _tableView.contentOffset.y;
        frame.size.height -= contentOffsetY;
        frame.size.height = MAX(frame.size.height, 0.0);
    }
    _clippingView.frame = frame;

    CGRect bounds = _clippingView.bounds;
    {
        CGFloat difference = CGRectGetHeight(_carouselView.frame) - CGRectGetHeight(_clippingView.frame);
        bounds.origin.y = ceilf(difference / 2.0);
    }
    _clippingView.bounds = bounds;

    if (scrollView.contentOffset.y > 330.0)
    {
        self.navigationItem.title = [self.accessPoint[kName] gtm_stringByUnescapingFromHTML];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Details", nil);
    }
}

#pragma mark - QBImagePickerControllerDelegate

-(void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    [imagePickerController.presentingViewController dismissViewControllerAnimated:true completion:nil];

    UIView *blockerView = [[UIView alloc] initWithFrame:self.view.bounds];
    blockerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blockerView.backgroundColor = [UIColor whiteColor];

    CGPoint center = blockerView.center;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = center;
    activityIndicator.color = [UIColor ccc_navigationBarBlueTintColor];

    UILabel *activityLabel = [[UILabel alloc] init];
    activityLabel.font = [UIFont ccc_detailedTextLabelFont];
    activityLabel.textColor = [UIColor ccc_navigationBarBlueTintColor];
    activityLabel.text = NSLocalizedString(@"Loading Images...", nil);
    activityLabel.textAlignment = NSTextAlignmentCenter;
    center.y += 40;
    activityLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    activityLabel.center = center;

    [blockerView addSubview:activityIndicator];
    [blockerView addSubview:activityLabel];
    self.navigationController.view.userInteractionEnabled = NO;

    [self.view addSubview:blockerView];
    [activityIndicator startAnimating];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = YES;
        [requestOptions setNetworkAccessAllowed:true];

        __block double lastProgress = 0;
        __block int imageNumber = 1;
        [requestOptions setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {

            if (lastProgress > progress) {
                imageNumber++;
            }

            lastProgress = progress;
            int displayProgress = lastProgress * 100;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *updateString = [NSString stringWithFormat:NSLocalizedString(@"Loading Image %i - %%%i", nil), imageNumber, displayProgress];
                activityLabel.text = updateString;
            });
        }];



        PHImageManager *manager = [PHImageManager defaultManager];

        NSMutableArray *assetsArray = [[NSMutableArray alloc] init];

        for (PHAsset *phAsset in assets) {
            [manager requestImageForAsset:phAsset
                               targetSize:PHImageManagerMaximumSize
                              contentMode:PHImageContentModeDefault
                                  options:requestOptions
                            resultHandler:^void(UIImage *image, NSDictionary *info) {
                                if (image != nil) {
                                    [assetsArray addObject:image];
                                }
                            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [blockerView removeFromSuperview];
            [self dispatchMailByAttachingImages:(NSArray*)assetsArray.mutableCopy controller:self];
            self.navigationController.view.userInteractionEnabled = YES;
        });
    });
}

-(void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self cancelPickingImagesForController:imagePickerController.presentingViewController];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dispatchMailByAttachingImages:[[NSArray alloc] initWithObjects:image, nil] controller:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelPickingImagesForController:picker];
}

#pragma mark ImagePicker Handler Methods

-(void) dispatchMailByAttachingImages : (NSArray *) imagesArray controller:(UIViewController *) controller {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [[mailComposeViewController navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ccc_navigationBarBlueTintColor]}];//Update the navigation bar text color
    [mailComposeViewController setToRecipients:@[@"yourcoast@coastal.ca.gov"]];
    [mailComposeViewController setSubject:[NSString stringWithFormat:@"YourCoast App Photo(s) Submission - %@ (ID:%lu)", self.accessPoint[kName], [self.accessPoint[kID] integerValue]]];
    mailComposeViewController.mailComposeDelegate = self;

    for (int i=0; i<imagesArray.count; i++) {
        [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(imagesArray[i], 0.85) mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"submissionPhoto%d.jpg",i+1]];
    }

    [controller presentViewController:mailComposeViewController animated:YES completion:nil];
}

-(void) cancelPickingImagesForController : (UIViewController *) controller {
    [GAI ccc_sendEvent:@"access point"
                action:@"photo_cancel"
                 label:nil
                 value:nil];
    
    [controller dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CCCAccessPointImageCellDelegate

- (void)thumbnailView:(CCCThumbnailView *)thumbnailView didSelectImage:(CCCPhoto *)image AtIndex:(NSInteger)index
{
    CCCPhotosViewController *photoViewController = [[CCCPhotosViewController alloc] initWithPhotos:_imagesCell.photos initialPhoto:_imagesCell.photos[index]];
    photoViewController.delegate = self;
    photoViewController.rightBarButtonItem = nil;

    if (_thumbnailView == nil)
    {
        _thumbnailView = [[CCCThumbnailView alloc] init];
    }

    _thumbnailView.delegate = photoViewController;

    __weak typeof(self) weakSelf = self;

    [self presentViewController:photoViewController animated:YES completion:^{

        photoViewController.shouldHideStatusBar = YES;
        [photoViewController setNeedsStatusBarAppearanceUpdate];
        [weakSelf.thumbnailView scrollToImageAtIndex:index];
    }];
}

#pragma mark - NYTPhotoViewControllerDelegate

- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex totalPhotoCount:(NSUInteger)totalPhotoCount
{
    return [self.accessPoint[kName] gtm_stringByUnescapingFromHTML];
}

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController captionViewForPhoto:(id<NYTPhoto>)photo
{
    if (_imagesCaptionView == nil)
    {
        _imagesCaptionView = [[UIView alloc] initWithFrame:CGRectZero];

        if (_thumbnailView == nil)
        {
            _thumbnailView = [[CCCThumbnailView alloc] initWithFrame:CGRectZero];
        }
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.shouldDimUnselected = YES;

        for (CCCPhoto *photo in _imagesCell.photos)
        {
            [_thumbnailView addPhoto:photo];
        }
        [_imagesCaptionView addSubview:_thumbnailView];

        [_thumbnailView.leadingAnchor constraintEqualToAnchor:_imagesCaptionView.leadingAnchor].active = YES;
        [_thumbnailView.trailingAnchor constraintEqualToAnchor:_imagesCaptionView.trailingAnchor].active = YES;
        [_thumbnailView.topAnchor constraintEqualToAnchor:_imagesCaptionView.topAnchor].active = YES;
        [_thumbnailView.bottomAnchor constraintEqualToAnchor:_imagesCaptionView.bottomAnchor constant:-15.0].active = YES;

        _imagesCaptionView.frame = (CGRect){CGPointZero, [_thumbnailView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]};
        [_thumbnailView setContentInset:UIEdgeInsetsMake(0.0, self.view.frame.size.width / 2 - 60, 0.0, 0.0)];
    }
    return _imagesCaptionView;
}

- (void)photosViewController:(CCCPhotosViewController *)photosViewController willNavigateToPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex
{
    [_thumbnailView scrollToImageAtIndex:photoIndex];
}

#pragma mark - CCCShareViewControllerDelegate

- (void)shareViewController:(CCCShareViewController *)controller didRequestToPresentShareViewController:(UIViewController *)requestedController
{
    [self presentViewController:requestedController animated:true completion:nil];
}

- (void)uploadPhoto
{
    [GAI ccc_sendEvent:@"access point"
                action:@"photo_start"
                 label:nil
                 value:nil];

    __weak typeof(self) weakSelf = self;

    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [weakSelf configureNavigationBarColor:[UIColor ccc_blueButtonColor]];

        QBImagePickerController *imagePickerController = [QBImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.mediaType = QBImagePickerMediaTypeImage;//Media type only UIImage
        imagePickerController.allowsMultipleSelection = true;//Allow multiple selection
        imagePickerController.maximumNumberOfSelection = 10;//Set the maximum 10 number of images to select
        imagePickerController.showsNumberOfSelectedAssets = true;//Show the number of selected assets to user
        
        //Present modally
        [weakSelf presentViewController:imagePickerController animated:YES completion:NULL];

        [GAI ccc_sendEvent:@"access point"
                    action:@"photo_actionsheet"
                     label:nil
                     value:@(0)];
    }];
    [controller addAction:libraryAction];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;

            [GAI ccc_sendEvent:@"access point"
                        action:@"photo_actionsheet"
                         label:nil
                         value:@(1)];

            [weakSelf presentViewController:picker animated:YES completion:NULL];
        }];
        [controller addAction:cameraAction];
    }

    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.navigationItem.title = NSLocalizedString(@"Details", nil);

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favourites-default"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(favourite:)];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _clippingView = [[UIView alloc] initWithFrame:self.view.bounds];
    {
        _clippingView.clipsToBounds = YES;

        _carouselView = [[CCCCarouselView alloc] initWithFrame:_clippingView.bounds];
        {
            _carouselView.accessPoint = self.accessPoint;
        }
        [_clippingView addSubview:_carouselView];
    }
    [self.view addSubview:_clippingView];

    CGRect rect = self.view.bounds;

    _tableView = [[UITableView alloc] initWithFrame:rect
                                              style:UITableViewStyleGrouped];

    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];

    _tableView.sectionHeaderHeight = -1.0;
    _tableView.sectionFooterHeight = 0.0;

    _tableView.dataSource = self;
    _tableView.delegate = self;

    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    __weak typeof(self) weakSelf = self;

    _tableView.tableHeaderView = ^{
        MCHammerView *view = [[MCHammerView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 280.0 - rect.origin.y)];
        view.youCANTouchThis = weakSelf.carouselView;
        return view;
    }();

    _shareViewController = [[CCCShareViewController alloc] initWithAccessPoint:self.accessPoint];
    _shareViewController.delegate = self;

    _shareViewController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 160.0);
    [_shareViewController.view setNeedsLayout];
    
    _tableView.tableFooterView = _shareViewController.view;
    
    [self.view addSubview:_tableView];
    
    [self scrollViewDidScroll:_tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _carouselView.coordinate = CLLocationCoordinate2DMake([self.accessPoint[kLatitude] doubleValue], [self.accessPoint[kLongitude] doubleValue]);

    //We currently assume there will be up to 50 photos
    NSMutableArray *urlStrings = [[NSMutableArray alloc] init];
    for (int i = 1; i < 51; i++)
    {
        NSString *photoKey = [NSString stringWithFormat:@"Photo_%d", i];
        NSString *photoURL = self.accessPoint[photoKey];
        if ([photoURL isEqualToString:@""] == YES || photoURL == nil)
        {
            break;
        }

        [urlStrings addObject:photoURL];
    }

    _accessPointPhotos = [[NSMutableArray alloc] init];

    for (NSString *string in urlStrings)
    {
        if ([string isEqualToString:@""]) continue;

        // URLWithString() returns a nil in some cases due to some url strings containing spaces.  This sanitizes the url strings before creating the NSURL.
        NSURL *url = [NSURL URLWithDataRepresentation:[string dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil];

        CCCPhoto *photo = [[CCCPhoto alloc] init];
        [_accessPointPhotos addObject:photo];
        photo.url = url;

        __weak typeof(self) weakSelf = self;

        [[CCCImageManager sharedManager] imageForURL:url forceFetch:NO completion:^(UIImage *image, NSURL *url) {

            photo.image = image;
            [weakSelf.tableView reloadData];
        }];
    }

    _hasNoPhotos = _accessPointPhotos.count == 0;

    _features = ^{

        NSMutableArray *array = [[NSMutableArray alloc] init];

        NSArray *keys = @[ kFee, kParking, kDisabled, kVisitorCenter, kRestrooms, kPicnicArea, kVolleyball, kDogFriendly, kCampground, kStrollerFriendly, kBikePath, kSandyBeach, kDunes, kBluff, kTidepool, kRockyShore, kStairsToBeach, kPathToBeach, kBlufftopTrails, kBlufftopPark, kWildLifeViewing, kFishing, kBoating, kFavourites ];

        for (NSString *key in keys)
        {
            if ([key isEqualToString:kDisabled] == YES)
            {
                if ([self.accessPoint[key] isEqualToString:kYes] == YES || [self.accessPoint[kBeachWheelchair] isEqualToString:@""] == NO)
                {
                    [array addObject:key];
                }
            }
            else if ([self.accessPoint[key] isEqualToString:kYes])
            {
                [array addObject:key];
            }
        }
        
        return [array copy];
    }();

    NSArray *favourites = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey] ?: @[];

    [self configureNavigationItemForFavourited:[favourites containsObject:self.accessPoint[kID]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configureNavigationBarColor:[UIColor whiteColor]];

    [GAI ccc_sendScreen:CCCScreenAccessPoint];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setAccessPoint:(NSDictionary *)accessPoint
{
    _accessPoint = accessPoint;

    _carouselView.accessPoint = accessPoint;

    [GAI ccc_sendEvent:@"access point"
                action:@"display"
                 label:[self.accessPoint[kName] gtm_stringByUnescapingFromHTML]
                 value:nil];
}

- (void)configureNavigationBarColor:(UIColor *)color
{
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:[UIFont ccc_barButtonNormalFont]
                                                           }
                                                forState:UIControlStateNormal];

    [[UINavigationBar appearance] setTintColor:color];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelFont],
                                                           NSForegroundColorAttributeName:color
                                                           }];
}

@end
