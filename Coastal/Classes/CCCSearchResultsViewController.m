//
//  CCCSearchResultsViewController.m
//  Coastal
//
//  Created by Malcolm on 2014-06-04.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCSearchResultsViewController.h"
#import "CCCSearchResultCell.h"
#import "CCCAccessPoint.h"
#import "GAI+CCC.h"
#import "CCCSearchAccessPoint.h"
#import "CCCModelContext.h"
#import "CCCFilterDigestView.h"
#import "CCCFavouriteViewController.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"
#import "GTMNSString+HTML.h"

@interface CCCSearchResultsViewController () <CCCFavouriteViewControllerDelegate>

@property (nonatomic, strong) NSArray *filteredRegions;
@property (nonatomic, strong) NSArray *filteredAccessPoints;
@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, strong) NSMutableArray *pastSearches;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) CCCFilterDigestView *filterDigestView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) CCCFavouriteViewController *favouriteViewController;
@property (nonatomic, assign, getter=isFavouriteHeaderShowing) BOOL favouriteHeaderShowing;


@end

@implementation CCCSearchResultsViewController

- (id)init
{
    return (self = [super initWithStyle:UITableViewStylePlain]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.filterDigestView = [[CCCFilterDigestView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    self.filterDigestView.backgroundColor = [UIColor whiteColor];

    self.dateFormatter = [[NSDateFormatter alloc] init];

    self.tableView.separatorColor = [UIColor ccc_lightSeparatorColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;

    [self.tableView registerClass:[CCCSearchResultCell class]
           forCellReuseIdentifier:CCCSearchResultCellReuseIdentifier];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filteredByTapped:)];

    [self loadSavedSearches];
}

- (void)loadSavedSearches
{
    self.pastSearches = [[CCCModelContext shared].objects mutableCopy];
    [self sortSearches];
}

- (void)sortSearches
{
    NSArray *sortDescriptors = @[
                                 [[NSSortDescriptor alloc] initWithKey:@"dateAdded"
                                                             ascending:NO],
                                 ];
    NSArray *sortedPastSearches = [self.pastSearches sortedArrayUsingDescriptors:sortDescriptors];
    self.pastSearches = [sortedPastSearches mutableCopy];
}

#pragma mark - Actions

- (void)setSearchTerm:(NSString *)searchTerm
{
    _searchTerm = [searchTerm copy];

    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                selector:@selector(filter)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)filter
{
    [self.timer invalidate];

    if ([self.searchTerm length] == 0)
    {
        // Show recent & favourites

        self.filteredAccessPoints = @[];
        self.filteredRegions = @[];
    }
    else
    {
        NSPredicate *predicate = nil;
        NSPredicate *combinedPredicate = nil;
        NSPredicate *filterPredicate = nil;
        {
            NSArray *words = [self.searchTerm componentsSeparatedByString:@" "];
            for (NSString *word in words)
            {
                if ([word length] == 0) continue;

                // Replace curly single/double quotes present in iOS keyboard with straight quotes which is the quote style provided by API
                NSString *cleanWord = [word stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
                cleanWord = [cleanWord stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
                cleanWord = [cleanWord stringByReplacingOccurrencesOfString:@"’" withString:@"'"];

                NSPredicate *subpredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", kName, cleanWord, kDescription, cleanWord];

                if (predicate)
                {
                    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, subpredicate]];
                }
                else
                {
                    predicate = subpredicate;
                }
            }

            for (NSString *filter in self.filters)
            {
                NSPredicate *subFilterPredicate = nil;

                if ([filter isEqualToString:kFavourites])
                {
                    NSArray *favourites = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey];
                    subFilterPredicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS SELF[%@]", favourites ?: @[], kID];
                }
                else
                {
                    if ([filter isEqualToString:kFee])
                    {
                        subFilterPredicate = [NSPredicate predicateWithFormat:@"SELF[%@] != %@", filter, kYes];
                    }
                    else if ([filter isEqualToString:kDisabled])
                    {
                        subFilterPredicate = [NSPredicate predicateWithFormat:@"SELF[%@] == %@ || SELF[%@] != %@", filter, kYes, kBeachWheelchair, @""];
                    }
                    else
                    {
                        subFilterPredicate = [NSPredicate predicateWithFormat:@"SELF[%@] == %@", filter, kYes];
                    }
                }

                if (subFilterPredicate)
                {
                    filterPredicate = filterPredicate ? [NSCompoundPredicate andPredicateWithSubpredicates:@[filterPredicate, subFilterPredicate]] : subFilterPredicate;
                }
            }
        }

        if (predicate && !filterPredicate)
        {
            combinedPredicate = predicate;
        }
        else if (predicate && filterPredicate)
        {
            combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
        }

        self.filteredAccessPoints = [self.accessPoints filteredArrayUsingPredicate:combinedPredicate];

        __weak typeof(self) weakSelf = self;

        [[[CLGeocoder alloc] init] geocodeAddressString:self.searchTerm
                                      completionHandler:^(NSArray *placemarks, NSError *error) {

                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == 'United States' && administrativeArea == 'CA'"];
                                          weakSelf.filteredRegions = [placemarks filteredArrayUsingPredicate:predicate];
                                      }];


    }

    [self addFilterDigest];
}

-(void) addFilterDigest
{
    if ([self.filters count] == 0 || [self.searchTerm length] == 0)
    {
        self.tableView.tableHeaderView = nil;

        return;
    }

    [self.filterDigestView filterStringWithFilters:self.filters];

    self.tableView.tableHeaderView = self.filterDigestView;

    if ([self.tableView.tableHeaderView.gestureRecognizers count] == 0)
    {
        [self.tableView.tableHeaderView addGestureRecognizer:self.tapGesture];
    }
}

-(void)filteredByTapped:(UIGestureRecognizer*)recognizer
{
    [self.delegate displayFiltersTable:self];
}

-(void)favouriteTapped:(UIGestureRecognizer*)recognizer
{
    NSArray *savedFavourites = [[NSUserDefaults standardUserDefaults] arrayForKey:CCCFavouritesUserDefaultsKey];
    NSPredicate *favouritePredicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS SELF[%@]", savedFavourites ?: @[], kID];

    NSArray *favouriteArray = [self.accessPoints filteredArrayUsingPredicate:favouritePredicate];

    self.favouriteViewController = [[CCCFavouriteViewController alloc] init];
    self.favouriteViewController.favourites = favouriteArray;
    self.favouriteViewController.delegate = self;

    [self.navigationController pushViewController:self.favouriteViewController animated:YES];
}

- (void)setFilteredAccessPoints:(NSArray *)filteredAccessPoints
{
    _filteredAccessPoints = filteredAccessPoints;

    [self reloadData];
}

- (void)setFilteredRegions:(NSArray *)filteredRegions
{
    _filteredRegions = filteredRegions;

    [self reloadData];
}

- (void)reloadData
{
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:4];
    {
        if ([self.searchTerm length] > 0)
        {
            self.favouriteHeaderShowing = NO;
        }
        else
        {
            self.favouriteHeaderShowing = YES;
            [sections addObject:[NSNull null]]; // Empty object for Favourite header
        }


        if ([self.filteredAccessPoints count] > 0)
        {
            [sections addObject:self.filteredAccessPoints];
        }

        if ([self.filteredRegions count] > 0)
        {
            [sections addObject:self.filteredRegions];
        }

        if ([self.pastSearches count] > 0 && [self.filteredAccessPoints count] == 0 && [self.filteredRegions count] == 0 && self.searchTerm.length == 0)
        {
            [sections addObject:self.pastSearches];
        }
    }
    self.sections = sections;
}

- (void)setSections:(NSArray *)sections
{
    _sections = sections;

    [self.tableView reloadData];
}

- (void)addToPastSearches:(id)accessPointOrPlacemark
{
    if ([accessPointOrPlacemark isKindOfClass:[CLPlacemark class]])
    {
        CLPlacemark *placemark = accessPointOrPlacemark;

        BOOL containsItem = NO;

        for (CCCSearchAccessPoint *searchItem in self.pastSearches)
        {
            if (searchItem.placemark == placemark)
            {
                containsItem = YES;
                searchItem.dateAdded = [NSDate date];
            }
        }
        if (containsItem == NO)
        {
            CCCSearchAccessPoint *searchItem = [[CCCSearchAccessPoint alloc] init];
            searchItem.placemark = placemark;
            searchItem.dateAdded = [NSDate date];

            [self.pastSearches addObject:searchItem];
        }
    }
    else if ([accessPointOrPlacemark isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *accessPoint = accessPointOrPlacemark;

        BOOL containsItem = NO;

        for (CCCSearchAccessPoint *searchItem in self.pastSearches)
        {
            if (searchItem.accessPoint == accessPoint)
            {
                containsItem = YES;
                searchItem.dateAdded = [NSDate date];
            }
        }
        if (containsItem == NO)
        {
            CCCSearchAccessPoint *searchItem = [[CCCSearchAccessPoint alloc] init];
            searchItem.accessPoint = accessPoint;
            searchItem.dateAdded = [NSDate date];

            [self.pastSearches addObject:searchItem];
        }
    }

    [[CCCModelContext shared] updateContext:self.pastSearches];

    [self sortSearches];
}

-(void) setFilters:(NSSet *)filters
{
    _filters = filters;

    [self filter];

    [self reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id sectionObject = self.sections[indexPath.section];

    if (sectionObject == self.filteredAccessPoints)
    {
        NSDictionary *accessPoint = self.filteredAccessPoints[indexPath.row];

        [self addToPastSearches:accessPoint];

        [self.delegate searchResultsViewController:self
                              didSelectAccessPoint:accessPoint];
    }
    else if (sectionObject == self.filteredRegions)
    {
        CLPlacemark *placemark = self.filteredRegions[indexPath.row];

        [self addToPastSearches:placemark];

        [self.delegate searchResultsViewController:self
                                didSelectPlacemark:placemark];
    }
    else if (sectionObject == self.pastSearches)
    {
        CCCSearchAccessPoint *searchItem = self.pastSearches[indexPath.row];

        if (searchItem.accessPoint)
        {
            NSDictionary *accessPoint = searchItem.accessPoint;

            [self addToPastSearches:accessPoint];

            [self.delegate searchResultsViewController:self
                                  didSelectAccessPoint:accessPoint];
        }
        else if (searchItem.placemark)
        {
            CLPlacemark *placemark = searchItem.placemark;

            [self addToPastSearches:placemark];

            [self.delegate searchResultsViewController:self
                                    didSelectPlacemark:placemark];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.isFavouriteHeaderShowing)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        {
            view.backgroundColor = [UIColor whiteColor];

            UIImage *favImage = [UIImage imageNamed:@"favourites_large"];
            UIImageView *favouriteIcon = [[UIImageView alloc] initWithImage:favImage];
            favouriteIcon.contentMode = UIViewContentModeCenter;
            favouriteIcon.frame = CGRectMake(20, 0, favImage.size.width, view.bounds.size.height);
            [view addSubview:favouriteIcon];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 45.0, 0.0)];
            {
                label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

                label.font = [UIFont ccc_textLabelFont];
                label.textColor = [UIColor ccc_darkTextColor];

                label.text = NSLocalizedString(@"Favorites", nil);
            }
            [view addSubview:label];

            UIImage *accessoryIconImage = [UIImage imageNamed:@"CCCAccessoryIcon"];
            UIImageView *accessoryIcon = [[UIImageView alloc] initWithImage:accessoryIconImage];
            accessoryIcon.contentMode = UIViewContentModeCenter;
            accessoryIcon.frame = CGRectMake(view.bounds.size.width - accessoryIconImage.size.width - 20 , 0, accessoryIconImage.size.width, view.bounds.size.height);
            [view addSubview:accessoryIcon];

            UITapGestureRecognizer *favouriteTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favouriteTapped:)];
            favouriteTapGesture.cancelsTouchesInView = NO;
            [view addGestureRecognizer:favouriteTapGesture];
        }
        return view;
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    {
        view.backgroundColor = [UIColor ccc_lightBackgroundColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 20.0, 0.0)];
        {
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

            label.font = [UIFont ccc_searchResultsHeaderLabelFont];
            label.textColor = [[UIColor ccc_darkTextColor] colorWithAlphaComponent:0.500];

            label.text = [self tableView:tableView titleForHeaderInSection:section];
        }
        [view addSubview:label];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.isFavouriteHeaderShowing)
    {
        return 44;
    }
    return 30;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id sectionObject = self.sections[section];

    if (sectionObject == self.filteredAccessPoints)
    {
        return NSLocalizedString(@"Access Points", nil);
    }
    else if (sectionObject == self.filteredRegions)
    {
        return NSLocalizedString(@"Regions", nil);
    }
    else if (sectionObject == self.pastSearches && [self.filteredAccessPoints count] == 0 && [self.filteredRegions count] == 0 && self.searchTerm.length == 0)
    {
        return NSLocalizedString(@"Recent Searches", nil);
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionObject = self.sections[section];

    if (sectionObject == self.filteredAccessPoints)
    {
        return [self.filteredAccessPoints count];
    }
    else if (sectionObject == self.filteredRegions)
    {
        return [self.filteredRegions count];
    }
    else if (sectionObject == self.pastSearches && [self.filteredAccessPoints count] == 0 && [self.filteredRegions count] == 0 && self.searchTerm.length == 0)
    {
        return [self.pastSearches count];
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CCCSearchResultCellReuseIdentifier
                                                                forIndexPath:indexPath];
    {
        id sectionObject = self.sections[indexPath.section];

        cell.imageView.image = nil;

        if (sectionObject == self.filteredAccessPoints)
        {
            NSDictionary *accessPoint = self.filteredAccessPoints[indexPath.row];
            cell.textLabel.text = [accessPoint[kName] gtm_stringByUnescapingFromHTML];

            CGFloat distance = [accessPoint[kDistance] doubleValue];
            cell.detailTextLabel.text = ((distance - DBL_EPSILON) > 0.0) ? [[NSString alloc] initWithFormat:@"%.1fmi", distance] : nil;
        }
        else if (sectionObject == self.filteredRegions)
        {
            CLPlacemark *placemark = self.filteredRegions[indexPath.row];

            cell.textLabel.text = [self placemarkString:placemark];
        }
        else if (sectionObject == self.pastSearches)
        {
            CCCSearchAccessPoint *searchItem = self.pastSearches[indexPath.row];

            if (searchItem.placemark)
            {
                CLPlacemark *placemark = searchItem.placemark;

                cell.textLabel.text = [self placemarkString:placemark];
            }
            else if (searchItem.accessPoint)
            {
                NSDictionary *accessPoint = searchItem.accessPoint;
                cell.textLabel.text = [accessPoint[kName] gtm_stringByUnescapingFromHTML];
            }

            NSString *sinceSaved = [self calculateTimeString:searchItem.dateAdded];

            cell.detailTextLabel.text = sinceSaved;

            cell.imageView.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.tintColor = [[UIColor ccc_darkTextColor] colorWithAlphaComponent:0.500];
        }
    }
    return cell;
}

#pragma mark - CCCFavouriteViewControllerDelegate

- (void)favouriteViewController:(CCCFavouriteViewController *)favouriteResultsViewController
           didSelectAccessPoint:(NSDictionary *)accessPoint
{
    [self.delegate setSearchShouldNotBecomeFirstResponder:YES];
    [self.delegate searchResultsViewController:self didSelectAccessPoint:accessPoint];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma Utility methods

- (NSMutableString *)placemarkString:(CLPlacemark *)placemark
{
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    {
        void(^appendString)(NSString *) = ^(NSString *string) {

            if ([mutableString length] > 0)
            {
                [mutableString appendString:@", "];
            }

            [mutableString appendString:string];
        };

        if ([placemark.locality length])
        {
            appendString(placemark.locality);
        }

        if ([placemark.administrativeArea length])
        {
            appendString(placemark.administrativeArea);
        }
    }
    return mutableString;
}

- (NSString *)calculateTimeString:(NSDate *)savedDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components = [calendar components:NSCalendarUnitSecond|NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                               fromDate:savedDate
                                                 toDate:[NSDate date]
                                                options:0];
    NSString *timeRemainingString;

    if (components.year != 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%ldY", (long)components.year];
    }
    else if (components.month != 0 && components.year == 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%ldM", (long)components.month];
    }
    else if (components.day != 0 && components.month == 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%ldd", (long)components.day];
    }
    else if (components.hour != 0 && components.day == 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%ldh", (long)components.hour];
    }
    else if (components.minute != 0 && components.hour == 0 && components.day == 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%ldm", (long)components.minute];
    }
    else if (components.second != 0 && components.minute == 0 && components.hour == 0 && components.day == 0)
    {
        timeRemainingString = [NSString stringWithFormat:@"%lds", (long)components.second];
    }
    
    return timeRemainingString;
}

@end
