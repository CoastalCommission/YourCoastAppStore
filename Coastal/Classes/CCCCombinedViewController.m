//
//  CCCCombinedViewController.m
//  Coastal
//
//  Created by Malcolm on 2014-05-05.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCCombinedViewController.h"
#import "CCCCombinedView.h"
#import "CCCListCell.h"
#import "CCCDataClient.h"
#import "CCCSearchBarView.h"
#import "CCCMapSnapshotter.h"
#import "CCCPinAnnotationView.h"
#import "CCCPinAnnotation.h"
#import "CCCAboutViewController.h"
#import "CCCAccessPointViewController.h"
#import "CCCAccessPoint.h"
#import "CCCFilterViewController.h"
#import "GAI+CCC.h"
#import "CCCCoordinate.h"
#import "CCCSearchResultsViewController.h"
#import "CCCClusterOverlay.h"
#import "CCCClusterOverlayRenderer.h"
#import <CoreLocation/CoreLocation.h>
#import "CCCFilterDigestView.h"
#import "UIFont+CCCTypeFoundry.h"
#import "SDWebImagePrefetcher.h"
#import "GTMNSString+HTML.h"

@interface CCCCombinedViewController ()
<
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate,
MKMapViewDelegate,
CCCFilterViewControllerDelegate,
UIViewControllerTransitioningDelegate,
CCCCombinedViewDelegate,
CCCSearchResultsViewControllerDelegate,
CCCAccessPointViewControllerDelegate,
CCCPinAnnotationViewDelegate
>

@property (nonatomic, strong) CCCCombinedView *view;

@property (nonatomic, strong) NSArray *accessPoints;
@property (nonatomic, strong) NSMutableSet *filters;
@property (nonatomic, strong) NSArray *filteredAccessPoints;
@property (nonatomic, strong) NSArray *visibleAccessPoints;

@property (nonatomic, assign) MKCoordinateRegion entireCoastRegion;
@property (nonatomic, assign) MKMapRect lastMapRect;

@property (nonatomic, strong) NSMutableDictionary *existingGroupedOverlays;

@property (nonatomic, strong) dispatch_queue_t clusteringQueue;
@property (nonatomic, assign) BOOL clusteringDisabled;
@property (nonatomic, assign) BOOL filtersChanged;
@property (nonatomic, assign) BOOL launching;
@property (nonatomic, strong) CCCSearchResultsViewController *searchResultsViewController;
@property (nonatomic, weak) CCCPinAnnotation *annotationToSelect;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) NSTimer *reloadTimer;
@property (nonatomic, assign) BOOL regionIsChanging;
@property (nonatomic, assign) BOOL mapIsPanning;
@property (nonatomic, assign) BOOL calloutTapped;
@property (nonatomic, assign) BOOL searchShouldNotBecomeFirstResponder;

@end

@implementation CCCCombinedViewController

@dynamic view;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;

        self.entireCoastRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(36.3, -119.75), MKCoordinateSpanMake(12.64086212377757, 12.21465457791));
        self.filters = [[NSMutableSet alloc] init];
        self.existingGroupedOverlays = [[NSMutableDictionary alloc] init];
        self.searchResultsViewController = [[CCCSearchResultsViewController alloc] init];
        [self.searchResultsViewController willMoveToParentViewController:self];
        [self addChildViewController:self.searchResultsViewController];
        self.locationManager = [[CLLocationManager alloc] init];
        self.clusteringQueue = dispatch_queue_create("co.metalab.coastal.clustering", DISPATCH_QUEUE_SERIAL);
        self.launching = YES;
        
        //Added in order to hide the title of back button
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.view = [[CCCCombinedView alloc] initWithFrame:self.view.frame];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = (UILabel *)^{

        UILabel *label = [[UILabel alloc] init];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Your", nil)
                                                                                            attributes:@{
                                                                                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                         NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelThinFont],
                                                                                                         }];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Coast", nil)
                                                                                       attributes:@{
                                                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                    NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelFont],
                                                                                                    }]];
        label.attributedText = attributedTitle;
        [label sizeToFit];
        return label;
    }();

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showAboutScreen) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    self.view.delegate = self;

    self.view.listOpen = NO;

    self.view.mapView.delegate = self;
    self.view.tableView.dataSource = self;
    self.view.tableView.delegate = self;

    [self.view.tableView registerClass:[CCCListCell class]
                forCellReuseIdentifier:@"listcell"];

    [self.view.currentLocationButton addTarget:self
                                        action:@selector(displayCurrentLocation)
                              forControlEvents:UIControlEventTouchUpInside];
    [self.view.entireCoastButton addTarget:self
                                    action:@selector(displayEntireCoast)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view.scrollTopButton addTarget:self
                                  action:@selector(scrollToTop)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.view.searchBarView.cancelSearchButton addTarget:self
                                          action:@selector(cancelSearch)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.view.searchBarView.filterButton addTarget:self
                                    action:@selector(displayFilters)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view.searchBarView.textField addTarget:self
                                 action:@selector(search:)
                       forControlEvents:UIControlEventEditingChanged];
    [self.view.searchBarView.textField addTarget:self
                                 action:@selector(search:)
                       forControlEvents:UIControlEventEditingDidBegin];

    self.view.searchBarView.textField.delegate = self;

    [self.view.outsideCaliView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideCaliforniaTap)]];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(toggleList)];
    {
        tap.delegate = self;
    }
    [self.view addGestureRecognizer:tap];

    [self.view.filterDigestView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayFilters)]];

    __weak typeof(self) weakSelf = self;

    [CCCDataClient getAccessPoints:^(NSArray *accessPoints, BOOL cached) {

        dispatch_async(dispatch_get_main_queue(), ^{

            weakSelf.accessPoints = accessPoints;
            weakSelf.view.listOpen = weakSelf.view.listOpen;
            [weakSelf reloadData];
            [weakSelf reloadClustering];

            // When the access point items are returned from API we need to trigger the update location method on map so
            // distances are calculated and the new data from API can be displayed and sorted same way when loaded from cached.
            if (cached == NO)
            {
                [weakSelf mapView:weakSelf.view.mapView didUpdateUserLocation:weakSelf.view.mapView.userLocation];
            }
        });
    }];

    self.searchResultsViewController.delegate = self;
    self.searchResultsViewController.view.alpha = 0.0;
    CGRect searchResultsViewControllerFrame = self.view.bounds;
    searchResultsViewControllerFrame.origin.y = CGRectGetMaxY(self.view.searchBarView.frame);
    searchResultsViewControllerFrame.size.height -= self.view.searchBarView.frame.size.height;
    self.searchResultsViewController.view.frame = searchResultsViewControllerFrame;
    [self.view addSubview:self.searchResultsViewController.view];

    UITapGestureRecognizer *overlayTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(mapTapped:)];
    {
        overlayTap.numberOfTapsRequired = 1;
        overlayTap.cancelsTouchesInView = NO;

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        {
            doubleTap.numberOfTapsRequired = 2;
            doubleTap.cancelsTouchesInView = NO;
        }
        [self.view.mapView addGestureRecognizer:doubleTap];

        [overlayTap requireGestureRecognizerToFail:doubleTap];
    }
    [self.view.mapView addGestureRecognizer:overlayTap];

    [self.view.mapView setRegion:self.entireCoastRegion
                        animated:NO];

    self.view.mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [GAI ccc_sendScreen:^{

        return self.view.listOpen ? CCCScreenList : CCCScreenMap;
    }()];

    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];

    for (NSIndexPath *indexPath in self.view.tableView.indexPathsForSelectedRows)
    {
        [self.view.tableView deselectRowAtIndexPath:indexPath
                                           animated:animated];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)setReloadTimer:(NSTimer *)reloadTimer
{
    [_reloadTimer invalidate];

    _reloadTimer = reloadTimer;
}

- (void)reloadTimerFired
{
    self.reloadTimer = nil;

    [self reloadData];
    [self reloadClustering];

    [self checkForZeroPinState];
    
    if (self.view.outOfBounds)
    {
        [self.view setListOpen:NO animated:YES];
    }
    else if (self.annotationToSelect)
    {
        [self.view.mapView selectAnnotation:self.annotationToSelect
                                   animated:YES];
    }
}

- (void)mapTapped:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view.mapView];
    CLLocationCoordinate2D coordinate = [self.view.mapView convertPoint:point
                                                   toCoordinateFromView:self.view.mapView];
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);

    MKCircle *circle = [MKCircle circleWithMapRect:self.view.mapView.visibleMapRect];
    MKOverlayRenderer *renderer = [[MKOverlayRenderer alloc] initWithOverlay:circle];

    point = [renderer pointForMapPoint:mapPoint];

    CCCClusterOverlay *selectedOverlay = nil;

    for (CCCClusterOverlay *overlay in self.view.mapView.overlays)
    {
        CGRect rect = [renderer rectForMapRect:[overlay boundingMapRect]];
        if (CGRectContainsPoint(rect, point))
        {
            selectedOverlay = overlay;
            break;
        }
    }

    if (selectedOverlay)
    {
        [self.view.hiddenMapView showAnnotations:[selectedOverlay.annotations allObjects]
                                        animated:NO];
        [self.view.mapView setRegion:self.view.hiddenMapView.region
                            animated:YES];
    }
}

- (void)search:(UITextField *)sender
{
    self.searchResultsViewController.searchTerm = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    self.searchResultsViewController.filters = self.filters;

    [self.view.searchBarView setSearching:YES animated:YES];

    BOOL searching = ([sender.text length] > 0);

    void(^animations)(void) = ^{

        self.searchResultsViewController.view.alpha = 1;

    };

    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:NULL];

    if (searching)
    {
        [GAI ccc_sendEvent:@"map_search"
                    action:@"search"
                     label:sender.text
                     value:nil];
    }
    else
    {
        [GAI ccc_sendEvent:@"map_search"
                    action:@"cancel"
                     label:nil
                     value:nil];
    }
}

- (void)displayFilters
{
    CCCFilterViewController *controller = [[CCCFilterViewController alloc] init];
    {
        controller.delegate = self;
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    {
        navigationController.navigationBar.titleTextAttributes = @{
                                                                   NSFontAttributeName: [UIFont ccc_navigationBarTitleLabelFont],
                                                                   NSForegroundColorAttributeName: [UIColor blackColor],
                                                                   };
    }
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         [controller setNeedsStatusBarAppearanceUpdate];
                     }];
}

- (void)setAccessPoints:(NSArray *)accessPoints
{
    _accessPoints = accessPoints;

    [self applyFilters];
}

- (void)setFilteredAccessPoints:(NSArray *)filteredAccessPoints
{
    _filteredAccessPoints = filteredAccessPoints;

    self.searchResultsViewController.accessPoints = _filteredAccessPoints;

    self.filtersChanged = YES;

    [self reloadAnnotations];

    [self reloadData];
    [self reloadClustering];
}

- (void)setVisibleAccessPoints:(NSArray *)visibleAccessPoints
{
    _visibleAccessPoints = visibleAccessPoints;

    NSString *accessPointsCount = [NSNumberFormatter localizedStringFromNumber:@([_visibleAccessPoints count])
                                                                   numberStyle:NSNumberFormatterDecimalStyle];

    self.view.leftGrabLabel.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ Nearby", nil), accessPointsCount];
    self.view.rightGrabLabel.text = ([self.filters count] > 0) ? NSLocalizedString(@"Filters Applied", nil) : @"";

    self.view.hasResults = [visibleAccessPoints count] > 0;

    [self.view.tableView reloadData];

    [self checkForZeroPinState];
}

- (void)toggleList
{
    BOOL listOpen = !self.view.listOpen;

    [GAI ccc_sendScreen:^{

        return listOpen ? CCCScreenList : CCCScreenMap;
    }()];

    [self.view setListOpen:listOpen
                  animated:YES];
}

- (void)displayCurrentLocation
{
    self.view.entireCoastButton.selected = NO;
    self.view.currentLocationButton.selected = YES;
    self.view.mapView.showsUserLocation = YES;

    [self mapView:self.view.mapView didUpdateUserLocation:self.view.mapView.userLocation];
}

- (void)outsideCaliforniaTap
{
    [self displayEntireCoast];
}

- (void)displayEntireCoast
{
    self.view.currentLocationButton.selected = NO;
    self.view.entireCoastButton.selected =YES;

    [self.view.mapView setRegion:[self.view.mapView regionThatFits:self.entireCoastRegion]
                        animated:YES];
}

- (void)scrollToTop
{
    if ([self.view.tableView numberOfRowsInSection:0] == 0) return;

    dispatch_async(dispatch_get_main_queue(), ^{

        [self.view.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:YES];
    });
}

- (NSArray *)accessPointsWithinMapRect:(MKMapRect)mapRect
{
    MKMapPoint minimumMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
    CLLocationCoordinate2D minimum = MKCoordinateForMapPoint(minimumMapPoint);

    MKMapPoint maximumMapPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMinY(mapRect));
    CLLocationCoordinate2D maximum = MKCoordinateForMapPoint(maximumMapPoint);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF[%@].doubleValue >= %@ && SELF[%@].doubleValue <= %@ && SELF[%@].doubleValue <= %@ && SELF[%@].doubleValue >= %@", kLatitude, @(minimum.latitude), kLongitude, @(minimum.longitude), kLatitude, @(maximum.latitude), kLongitude, @(maximum.longitude)];

    NSArray *accessPoints = [self.filteredAccessPoints filteredArrayUsingPredicate:predicate];

    return accessPoints;
}

- (void)reloadData
{
    MKMapRect mapRect = [self.view.hiddenMapView mapRectThatFits:self.view.mapView.visibleMapRect
                                                     edgePadding:UIEdgeInsetsMake(-60.0, 0.0, -75.0, 0.0)];
    NSMutableArray *accessPoints = [self accessPointsWithinMapRect:mapRect].mutableCopy;

    NSArray *sortDescriptors = @[
                                 [[NSSortDescriptor alloc] initWithKey:kDistance
                                                             ascending:YES],
                                 ];
    NSMutableArray *visibleAccessPoints = [accessPoints sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;

    // If there's an access point selected make it first in the access point list
    NSArray<CCCPinAnnotation *> *selectedAnnotations = self.view.mapView.selectedAnnotations;

    if (selectedAnnotations.count == 1 && visibleAccessPoints.count > 0)
    {
        id selectedAnnotation = selectedAnnotations.firstObject;
        if ([selectedAnnotation isKindOfClass:[CCCPinAnnotation class]])
        {
            NSDictionary *selectedAccessPoint = ((CCCPinAnnotation *)selectedAnnotation).accessPoint;
            NSUInteger selectedIndex = [accessPoints indexOfObjectPassingTest:^BOOL (NSDictionary *accessPoint, NSUInteger idx, BOOL *stop) {
                return [accessPoint[kID] integerValue] == [selectedAccessPoint[kID] integerValue];
            }];

            if (selectedIndex >= 0 && selectedIndex != NSNotFound)
            {
                [visibleAccessPoints removeObjectAtIndex:selectedIndex];
                [visibleAccessPoints insertObject:selectedAccessPoint atIndex:0];
            }
        }
    }

    self.visibleAccessPoints = visibleAccessPoints;
}

- (void)applyFilters
{
    NSPredicate *predicate = nil;

    for (NSString *filter in self.filters)
    {
        NSPredicate *subpredicate = nil;

        if ([filter isEqualToString:kFavourites])
        {
            NSArray *favourites = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey];
            subpredicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS SELF[%@]", favourites ?: @[], kID];
        }
        else
        {
            if ([filter isEqualToString:kFee])
            {
                subpredicate = [NSPredicate predicateWithFormat:@"SELF[%@] != %@", filter, kYes];
            }
            else if ([filter isEqualToString:kDisabled])
            {
                subpredicate = [NSPredicate predicateWithFormat:@"SELF[%@] == %@ || SELF[%@] != %@", filter, kYes, kBeachWheelchair, @""];
            }

            else
            {
                subpredicate = [NSPredicate predicateWithFormat:@"SELF[%@] == %@", filter, kYes];
            }
        }

        if (subpredicate)
        {
            predicate = predicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, subpredicate]] : subpredicate;
        }
    }

    [self processFilterDisplay];

    self.filteredAccessPoints = predicate ? [self.accessPoints filteredArrayUsingPredicate:predicate] : self.accessPoints;

    self.searchResultsViewController.filters = self.filters;
}

- (void)cancelSearch
{
    self.view.searchBarView.textField.text = @"";
    [self hideSearchAnimated];
}

- (void)processFilterDisplay
{
    if (self.filters.count == 0)
    {
        self.view.searchBarView.filterButton.selected = NO;
        self.view.filterDigestView.hidden = YES;
    }
    else
    {
        self.view.searchBarView.filterButton.selected = YES;
        self.view.filterDigestView.hidden = NO;

        [self.view.filterDigestView filterStringWithFilters:self.filters];
    }
}

- (void)showAboutScreen
{
    CCCAboutViewController *aboutViewController = [[CCCAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

- (void)showAccessPointScreen:(NSDictionary *)accessPoint
{
    CCCAccessPointViewController *viewController = [[CCCAccessPointViewController alloc] init];
    viewController.delegate = self;
    viewController.accessPoint = accessPoint;

    [self.navigationController pushViewController:viewController
                                         animated:YES];

    [self prefetchImagesAndMapsNearAccessPoint:accessPoint];
}

- (void)prefetchImagesAndMapsNearAccessPoint:(NSDictionary *)accessPoint
{
    CGSize screenSize = self.view.bounds.size;
    CGFloat screenScale = [UIScreen mainScreen].scale;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSMutableArray *photoUrls = [[NSMutableArray alloc] init];
        NSMutableArray *nearbyAccessPoints = [[NSMutableArray alloc] init];

        for (NSDictionary *point in self.accessPoints)
        {
            NSString *region = accessPoint[@"GEOGR_AREA"];
            if ( [point[@"GEOGR_AREA"] isEqualToString: region])
            {
                //We currently assume there will be up to 50 photos
                for (int i = 1; i < 51; i++)
                {
                    NSString *photoKey = [NSString stringWithFormat:@"Photo_%d", i];
                    NSString *photoURL = point[photoKey];
                    if ([photoURL isEqualToString:@""] == YES || photoURL == nil)
                    {
                        break;
                    }

                    [photoUrls addObject:photoURL];
                }
                [nearbyAccessPoints addObject:point];
            }
        }

        NSMutableArray *urls = [[NSMutableArray alloc] init];

        for (NSString *urlString in photoUrls)
        {
            if ([urlString isEqualToString:@""])
            {
                continue;
            }
            else
            {
                // URLWithString() returns a nil in some cases due to some url strings containing spaces.  This sanitizes the url strings before creating the NSURL.
                NSURL *url = [NSURL URLWithDataRepresentation:[urlString dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil];
                [urls addObject:url];
            }
        }

        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];

        CGFloat mapRatio = screenSize.width / screenSize.height;

        for (NSDictionary *accessPoint in nearbyAccessPoints)
        {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([accessPoint[kLatitude] doubleValue], [accessPoint[kLongitude] doubleValue]);

            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kCCCMapWidth, kCCCMapWidth * mapRatio);

            MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
            options.region = region;
            options.size = screenSize;
            options.scale = screenScale;

            CCCMapSnapshotter *snapshotter = [[CCCMapSnapshotter alloc] initWithOptions:options];
            [snapshotter snapshotAndCacheImageWithHandler:nil];
        }
    });
}

#pragma mark - CCCSearchResultsViewControllerDelegate

- (void)hideSearchAnimated
{

    [self.view.searchBarView.textField resignFirstResponder];

    [self.view.searchBarView setSearching:NO animated:YES];

    void(^animations)(void) = ^{

        self.searchResultsViewController.view.alpha = 0.0;
    };

    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:NULL];
}

- (void)searchResultsViewController:(CCCSearchResultsViewController *)searchResultsViewController
               didSelectAccessPoint:(NSDictionary *)accessPoint
{
    [self cancelSearch];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accessPoint.%@ == %@", kID, accessPoint[kID]];

    NSArray *annotations = [self.view.hiddenMapView.annotations filteredArrayUsingPredicate:predicate];

    CCCPinAnnotation *annotation = [annotations firstObject];
    self.annotationToSelect = annotation;

    MKCoordinateRegion region;
    region.center = annotation.coordinate;
    region.span = MKCoordinateSpanMake(0.03, 0.03);

    [self.view.mapView setRegion:region
                        animated:YES];
}

- (void)searchResultsViewController:(CCCSearchResultsViewController *)searchResultsViewController
                 didSelectPlacemark:(CLPlacemark *)placemark
{
    [self hideSearchAnimated];

    CLLocationCoordinate2D coordinate = placemark.location.coordinate;

    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = MKCoordinateSpanMake(0.25, 0.25);

    [self.view.mapView setRegion:region
                        animated:YES];
}

- (BOOL)californiaVisibleOnMap:(MKMapView *)mapView
{
    CLLocationCoordinate2D californiaCoordinate = CLLocationCoordinate2DMake(37.1957913, -123.7641328);
    if (self.view.hasResults || MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(californiaCoordinate)))
    {
        return YES;
    }

    return NO;
}

-(void) displayFiltersTable:(CCCSearchResultsViewController *)searchResultsViewController
{
    [self displayFilters];
}

#pragma mark - CCCCombinedViewDelegate

- (void)combinedViewListOpenDidChange:(CCCCombinedView *)combinedView
{
    //[self displayOrHideClosestVisibleCallout];
}

- (void)reloadAnnotations
{
    [self.view.hiddenMapView removeAnnotations:self.view.hiddenMapView.annotations];

    NSMutableArray *annotations = [[NSMutableArray alloc] init];

    for (NSMutableDictionary *accessPoint in self.filteredAccessPoints)
    {
        CCCPinAnnotation *annotation = [[CCCPinAnnotation alloc] init];
        annotation.accessPoint = accessPoint;
        annotation.color = @"pin-yellow";

        [annotations addObject:annotation];
    }

    [self.view.hiddenMapView addAnnotations:annotations];
}

static inline BOOL CCCMKMapSizeEqualToSize(MKMapSize size1, MKMapSize size2)
{
    static double const epsilon = 0.0001;
    if (ABS(size1.width - size2.width) < epsilon)
    {
        if (ABS(size1.height - size2.height) < epsilon)
        {
            return YES;
        }
    }

    return NO;
}

- (MKCoordinateRegion)regionWithAnnotations:(NSArray *)annotations
{
    id <MKAnnotation> first = [annotations firstObject];
    CLLocationCoordinate2D upper = [first coordinate];
    CLLocationCoordinate2D lower = [first coordinate];

    // FIND LIMITS
    for(id <MKAnnotation> annotation in annotations)
    {
        if ([annotation coordinate].latitude > upper.latitude)
        {
            upper.latitude = [annotation coordinate].latitude;
        }

        if ([annotation coordinate].latitude < lower.latitude)
        {
            lower.latitude = [annotation coordinate].latitude;
        }

        if ([annotation coordinate].longitude > upper.longitude)
        {
            upper.longitude = [annotation coordinate].longitude;
        }

        if ([annotation coordinate].longitude < lower.longitude)
        {
            lower.longitude = [annotation coordinate].longitude;
        }
    }

    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;

    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
}

- (void)reloadClustering
{
    __block MKMapRect visibleMapRect = self.view.mapView.visibleMapRect;
    MKMapRect lastMapRect = self.lastMapRect;

    NSMutableSet *existingOverlays = [[NSMutableSet alloc] initWithArray:self.view.mapView.overlays];
    NSMutableSet *annotationsToRemove = [[NSMutableSet alloc] initWithArray:self.view.mapView.annotations];

    BOOL filtersChanged = self.filtersChanged;
    self.filtersChanged = NO;

    dispatch_async(self.clusteringQueue, ^{

        // Expand visible map rect so we have some pins while panning
        MKMapRect expandedMapRect = MKMapRectInset(visibleMapRect, -(1.2 * MKMapRectGetWidth(visibleMapRect)), -(1.2 * MKMapRectGetHeight(visibleMapRect)));

        BOOL isPanning = CCCMKMapSizeEqualToSize(expandedMapRect.size, lastMapRect.size);

        // See if we need to switch to showing pins
        NSSet *allAnnotations = [self.view.hiddenMapView annotationsInMapRect:visibleMapRect];
        if ([allAnnotations count] < 80)
        {
            NSMutableSet *annotationsToAdd = [[self.view.hiddenMapView annotationsInMapRect:expandedMapRect] mutableCopy];

            self.clusteringDisabled = YES;

            NSMutableSet *intersection = [annotationsToRemove mutableCopy];
            [intersection intersectSet:annotationsToAdd];

            [annotationsToRemove minusSet:intersection];
            [annotationsToAdd minusSet:intersection];

            if ([annotationsToAdd count] < 300)
            {
                [self.existingGroupedOverlays removeAllObjects];

                dispatch_async(dispatch_get_main_queue(), ^{

                    self.lastMapRect = expandedMapRect;

                    [self.view.mapView removeOverlays:self.view.mapView.overlays];
                    [self.view.mapView removeAnnotations:[annotationsToRemove allObjects]];
                    [self.view.mapView addAnnotations:[annotationsToAdd allObjects]];
                });

                return;
            }
        }

        self.clusteringDisabled = NO;

        static NSInteger const columnCount = 34;
        static NSInteger const rowCount = 52;

        CGFloat width = MKMapRectGetWidth(expandedMapRect) / columnCount;
        CGFloat height = MKMapRectGetHeight(expandedMapRect) / rowCount;

        if (isPanning)
        {
            // We're panning, so instead of using the new visible map rect, lets offset the old one so we don't get a scale change
            width = MKMapRectGetWidth(lastMapRect) / columnCount;
            height = MKMapRectGetHeight(lastMapRect) / rowCount;

            double newMinX = MKMapRectGetMinX(expandedMapRect);
            double lastMinX = MKMapRectGetMinX(lastMapRect);
            double differenceX = ABS(newMinX - lastMinX);
            double modulusX = fmod(differenceX, width);

            double newMinY = MKMapRectGetMinY(expandedMapRect);
            double lastMinY = MKMapRectGetMinY(lastMapRect);
            double differenceY = ABS(newMinY - lastMinY);
            double modulusY = fmod(differenceY, height);

            if (newMinX > lastMinX)
            {
                modulusX *= -1;
            }

            if (newMinY > lastMinY)
            {
                modulusY *= -1;
            }

            expandedMapRect = MKMapRectOffset(expandedMapRect, modulusX, modulusY);
        }
        else
        {
            // Not panning, so we need to replace all overlays
            [self.existingGroupedOverlays removeAllObjects];
        }

        NSMutableDictionary *newGroupedOverlays = [[NSMutableDictionary alloc] init];
        NSMutableArray *overlaysToAdd = [[NSMutableArray alloc] init];

        MKMapRect remainder = expandedMapRect;

        for (NSInteger columnIndex = 0; columnIndex < columnCount; columnIndex++)
        {
            MKMapRect column;
            MKMapRectDivide(remainder, &column, &remainder, width, CGRectMinXEdge);

            for (NSInteger row = 0; row < rowCount; row++)
            {
                MKMapRect square;
                MKMapRectDivide(column, &square, &column, height, CGRectMinYEdge);

                MKMapPoint origin = square.origin;
                CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(origin);
                CCCCoordinate *coordinateValue = [[CCCCoordinate alloc] initWithCoordinate:coordinate];

                MKCircle *existingOverlay = self.existingGroupedOverlays[coordinateValue];
                if (existingOverlay && filtersChanged == NO)
                {
                    newGroupedOverlays[coordinateValue] = existingOverlay;
                    [existingOverlays removeObject:existingOverlay];
                }
                else
                {
                    NSSet *annotations = [self.view.hiddenMapView annotationsInMapRect:square];

                    if ([annotations count])
                    {
                        // Use the actual region of the annotations
                        MKCoordinateRegion region = [self regionWithAnnotations:[annotations allObjects]];
                        MKMapRect annotationRect = CCCMKMapRectForCoordinateRegion(region);

                        // Square off the region with the largest dimension
                        if (annotationRect.size.width > annotationRect.size.height)
                        {
                            CGFloat difference = annotationRect.size.width - annotationRect.size.height;
                            annotationRect.origin.y -= difference / 2.0;
                            annotationRect.size.height = annotationRect.size.width;
                        }
                        else if (annotationRect.size.height > annotationRect.size.width)
                        {
                            CGFloat difference = annotationRect.size.height - annotationRect.size.width;
                            annotationRect.origin.x -= difference / 2.0;
                            annotationRect.size.width = annotationRect.size.height;
                        }

                        CCCClusterOverlay *overlay = [[CCCClusterOverlay alloc] init];
                        {
                            overlay.mapRect = annotationRect;
                            overlay.annotations = annotations;
                        }
                        [overlaysToAdd addObject:overlay];
                    }
                }
            }
        }

        self.existingGroupedOverlays = newGroupedOverlays;

        dispatch_async(dispatch_get_main_queue(), ^{

            self.lastMapRect = expandedMapRect;
            [self.view.mapView removeAnnotations:self.view.mapView.annotations];
            [self.view.mapView removeOverlays:[existingOverlays allObjects]];
            [self.view.mapView addOverlays:overlaysToAdd];
        });
    });
}

- (void)checkForZeroPinState
{
    if (!self.filteredAccessPoints || !self.filteredAccessPoints.count){
        self.view.outOfBounds = YES;
        self.view.outsideCaliViewLabel.text = NSLocalizedString(@"There are no access points. Tap to return to California, or update your filters.", nil);
    } else {
        self.view.outOfBounds = [self californiaVisibleOnMap:self.view.mapView] == NO;
        self.view.outsideCaliViewLabel.text = NSLocalizedString(@"There are no access points. Tap here to return to California.", nil);
    }
}

#pragma mark - CCCFilterViewControllerDelegate

-(void) applyButtonTapped {
    //This checks whether there are no access points on the map.
    [self checkForZeroPinState];
}

- (NSInteger)totalCountForFilterViewController:(CCCFilterViewController *)filterViewController
{
    return [self.accessPoints count];
}

- (NSInteger)filteredCountForFilterViewController:(CCCFilterViewController *)filterViewController
{
    return [self.filteredAccessPoints count];
}

- (void)filterViewController:(CCCFilterViewController *)filterViewController
                 didSetValue:(BOOL)value
                   forFilter:(NSString *)filter
{
    value ? [self.filters addObject:filter] : [self.filters removeObject:filter];

    [self applyFilters];
}

- (BOOL)filterViewController:(CCCFilterViewController *)filterViewController
              valueForFilter:(NSString *)filter
{
    return [self.filters containsObject:filter];
}

- (void)filterViewControllerDidReset:(CCCFilterViewController *)filterViewController
{
    [self.filters removeAllObjects];

    [self applyFilters];
}

#pragma mark - CCCAccessPointViewControllerDelegate

- (void)accessPointController:(CCCAccessPointViewController *)accessPointController didFavouriteAccessPoint:(NSDictionary *)accessPoint
{
    NSIndexPath *indexPath = [self indexPathForAccessPoint:accessPoint];

    if (indexPath)
    {
        [self.view.tableView reloadRowsAtIndexPaths:@[
                                                      indexPath,
                                                      ]
                                   withRowAnimation:UITableViewRowAnimationNone];
    }

    if ([self.filters containsObject:kFavourites] == YES)
    {
        [self applyFilters];
    }
}

#pragma mark - MKMapViewDelegate

MKMapRect CCCMKMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // We need to wait a small period of time for the map view to relaod and finish animating to make a reliable selection
    [self performSelector:@selector(restoreAnnotationSelection)
               withObject:nil afterDelay:0.5];
}

-(void)restoreAnnotationSelection
{
    if (self.annotationToSelect != nil)
    {
        [self.view.mapView selectAnnotation:self.annotationToSelect animated:NO];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    UIView* view = mapView.subviews.firstObject;

    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
    {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]] && recognizer.state == UIGestureRecognizerStateBegan)
        {
            self.mapIsPanning = YES;
        }
    }

    if (self.mapIsPanning == NO)
    {
        [self.view.mapView removeAnnotations:self.view.mapView.annotations];
        [self.view.mapView removeOverlays:self.view.mapView.overlays];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.mapIsPanning = NO;

    if (self.launching == NO)
    {
        MKUserLocation *location = mapView.userLocation;
        self.view.currentLocationButton.selected = location && (fabs(location.coordinate.latitude - mapView.centerCoordinate.latitude) < FLT_EPSILON && fabs(location.coordinate.longitude - mapView.centerCoordinate.longitude) < FLT_EPSILON);

        MKMapRect entireCoastRect = CCCMKMapRectForCoordinateRegion(self.entireCoastRegion);
        NSSet *entireCoastAnnotations = [self.view.hiddenMapView annotationsInMapRect:entireCoastRect];
        NSSet *annotations = [self.view.hiddenMapView annotationsInMapRect:mapView.visibleMapRect];
        self.view.entireCoastButton.selected = [annotations count] >= [entireCoastAnnotations count];

        [self reloadTimerFired];
    }
    else
    {
        [self reloadTimerFired];

        if (self.launching == YES && animated == YES)
        {
            self.launching = NO;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CCCPinAnnotation class]])
    {
        static NSString * const identifier = @"CCCPinAnnotationView";

        CCCPinAnnotation *pinAnnotation = annotation;
        CCCPinAnnotationView *annotationView = (CCCPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil)
        {
            annotationView = [[CCCPinAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:identifier];
        }
        else
        {
            annotationView.annotation = annotation;
        }

        annotationView.delegate = self;

        annotationView.titleText = [pinAnnotation.accessPoint[kName] gtm_stringByUnescapingFromHTML];

        return annotationView;
    }

    return nil;
}

#pragma mark - CCCPinAnnotationViewDelegate

- (void)annotationView:(CCCPinAnnotationView *)view didTapCallout:(CCCCalloutView *)callout
{
    self.calloutTapped = YES;

    NSDictionary *accessPoint = ((CCCPinAnnotation *)((CCCPinAnnotationView *)view).annotation).accessPoint;
    
    [self showAccessPointScreen:accessPoint];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.mapIsPanning = YES;

    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    self.annotationToSelect = nil;
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.calloutTapped == YES)
    {
        [mapView selectAnnotation:view.annotation
                         animated:NO];

        self.calloutTapped = NO;
        return;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation)
    {
        for (NSMutableDictionary *accessPoint in self.accessPoints)
        {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[accessPoint[kLatitude] doubleValue]
                                                              longitude:[accessPoint[kLongitude] doubleValue]];

            CLLocationDistance distance = [currentLocation distanceFromLocation:location] / 1609.34;
            accessPoint[kDistance] = @(distance);
        }

        [self reloadData];

        //[self displayOrHideClosestVisibleCallout];

        if (self.view.currentLocationButton.selected)
        {
            MKCoordinateRegion region;
            region.center = currentLocation.coordinate;
            region.span = MKCoordinateSpanMake(0.3, 0.3);

            [mapView setRegion:region
                      animated:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];

    CGRect grabRect = [self.view convertRect:self.view.grabView.frame
                                    fromView:self.view.grabView.superview];

    if (self.view.listOpen)
    {
        if (self.view.hammerView.userInteractionEnabled)
        {
            return CGRectContainsPoint(grabRect, location);
        }
        else
        {
            return location.y <= CGRectGetMaxY(grabRect);
        }
    }
    else
    {
        return location.y >= CGRectGetMinY(grabRect);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view layoutMapView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((self.view.listOpen && scrollView.contentOffset.y < ABS(scrollView.contentInset.top)) || self.view.hasResults == NO)
    {
        CGFloat closedHeight = (self.view.hasResults) ? 0.0 : self.view.tableView.rowHeight;

        [self.view setListOpen:NO
                      animated:YES
               initialVelocity:ABS(velocity.y * 1000)];
        *targetContentOffset = CGPointMake(0.0, closedHeight);

        [GAI ccc_sendScreen:CCCScreenMap];
    }
    else if (self.view.listOpen == NO && scrollView.contentOffset.y > 0.0)
    {
        [self.view setListOpen:YES
                      animated:YES
               initialVelocity:ABS(velocity.y * 1000)];
        *targetContentOffset = CGPointMake(0.0, -scrollView.contentInset.top);

        [GAI ccc_sendScreen:CCCScreenList];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    CCCClusterOverlayRenderer *renderer = [[CCCClusterOverlayRenderer alloc] initWithOverlay:overlay];
    return renderer;
}

#pragma mark - UITableViewDataSource

- (NSIndexPath *)indexPathForAccessPoint:(NSDictionary *)accessPoint
{
    NSInteger row = [self.visibleAccessPoints indexOfObject:accessPoint];

    if (row != NSNotFound)
    {
        return [NSIndexPath indexPathForRow:row
                                  inSection:0];
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.visibleAccessPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listcell"
                                                        forIndexPath:indexPath];
    {
        NSDictionary *accessPoint = self.visibleAccessPoints[indexPath.row];
        cell.accessPoint = accessPoint;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.listOpen;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self showAccessPointScreen:self.visibleAccessPoints[indexPath.row]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // When popping to a view controller whose text field was the first responder at the time another view controller was pushed on top of it, UIApplication restores first responder status to the text field in question between viewWillAppear() and viewDidAppear(). When dismissing the favourites controller, we want to circumvent this behaviour, as the pop animation causes this view controller to appear--and show the search controller--immediately after that search controller is dismissed.
    if (self.searchShouldNotBecomeFirstResponder == YES)
    {
        self.searchShouldNotBecomeFirstResponder = NO;
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.searchBarView.filterButton.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.searchBarView.filterButton.hidden = NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.view.searchBarView.textField.rightViewMode = ^{
        if (resultString.length == 0)
        {
            return UITextFieldViewModeNever;
        }
        return UITextFieldViewModeWhileEditing;
    }();
    return YES;
}

@end
