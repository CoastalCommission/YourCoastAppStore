//
//  CCCFilterViewController.m
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFilterViewController.h"
#import "CCCFilterView.h"
#import "CCCAccessPoint.h"
#import "CCCFilterCell.h"
#import "GAI+CCC.h"

@interface CCCFilterViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
CCCFilterCellDelegate
>

@property (nonatomic, strong) CCCFilterView *view;
@property (nonatomic, assign) BOOL doesPreferDefaultStatusBar;
@property (nonatomic, strong) NSArray *filters;

@end

@implementation CCCFilterViewController

@dynamic view;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Filters", nil);

        self.filters = @[
                         kFavourites,
                         kFee,
                         kParking,
                         kDisabled,
                         kBluff,
                         kTidepool,
                         kBikePath,
                         kVisitorCenter,
                         kRestrooms,
                         kPicnicArea,
                         kDogFriendly,
                         kCampground,
                         kStrollerFriendly,
                         kVolleyball,
                         kSandyBeach,
                         kRockyShore,
                         kStairsToBeach,
                         kPathToBeach,
                         kBlufftopTrails,
                         kBlufftopPark,
                         kDunes,
                         kFishing,
                         kWildLifeViewing,
                         kBoating,
                         ];
    }
    return self;
}

- (void)loadView
{
    self.view = [[CCCFilterView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.tableView.dataSource = self;
    self.view.tableView.delegate = self;

    [self.view.tableView registerClass:[CCCFilterCell class]
                forCellReuseIdentifier:CCCFilterCellReuseIdentifier];

    self.view.applyButton.target = self;
    self.view.applyButton.action = @selector(apply);
    self.view.resetButton.target = self;
    self.view.resetButton.action = @selector(reset);
    self.view.cancelButton.target = self;
    self.view.cancelButton.action = @selector(apply);

    self.navigationItem.leftBarButtonItem = self.view.resetButton;
    self.navigationItem.rightBarButtonItem = self.view.applyButton;

    [self updateCount];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [GAI ccc_sendScreen:CCCScreenFilter];

    self.doesPreferDefaultStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.doesPreferDefaultStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return (self.doesPreferDefaultStatusBar) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)apply
{
    //Invoking delegate method for "Apply" button tapped event
    [self.delegate applyButtonTapped];
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];

    [GAI ccc_sendEvent:@"filter"
                action:@"apply"
                 label:nil
                 value:nil];
}

- (void)reset
{
    for (CCCFilterCell *cell in self.view.tableView.visibleCells)
    {
        [cell.toggle setOn:NO
                  animated:YES];
    }
    [self.delegate filterViewControllerDidReset:self];

    [self updateCount];

    [GAI ccc_sendEvent:@"filter"
                action:@"reset"
                 label:nil
                 value:nil];
}

- (void)updateCount
{
    NSInteger total = [self.delegate totalCountForFilterViewController:self];
    NSInteger filtered = [self.delegate filteredCountForFilterViewController:self];

    NSString *totalString = [NSNumberFormatter localizedStringFromNumber:@(total)
                                                             numberStyle:NSNumberFormatterDecimalStyle];
    NSString *filteredString = [NSNumberFormatter localizedStringFromNumber:@(filtered)
                                                                numberStyle:NSNumberFormatterDecimalStyle];

    NSString *format = NSLocalizedString(@"%@ of %@", nil);
    self.view.countLabel.text = [[NSString alloc] initWithFormat:format, filteredString, totalString];

    if (filtered < total)
    {
        [self.navigationItem setLeftBarButtonItem:self.view.resetButton
                                         animated:YES];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:self.view.cancelButton
                                         animated:YES];
    }
}

#pragma mark - CCCFilterCellDelegate

- (void)filterCellDidUpdateValue:(CCCFilterCell *)filterCell
{
    NSString *filter = filterCell.filter;
    BOOL isOn = filterCell.toggle.isOn;

    [GAI ccc_sendEvent:@"filter"
                action:@"toggle"
                 label:filter
                 value:@(isOn)];

    [self.delegate filterViewController:self
                            didSetValue:isOn
                              forFilter:filter];

    [self updateCount];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:CCCFilterCellReuseIdentifier
                                                            forIndexPath:indexPath];
    {
        cell.delegate = self;

        NSString *filter = self.filters[indexPath.row];
        cell.filter = filter;
        cell.toggle.on = [self.delegate filterViewController:self
                                              valueForFilter:filter];

        if (indexPath.row == 0)
        {
            cell.topCell = YES;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return tableView.rowHeight + 1.0;
    }

    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCFilterCell *cell = (CCCFilterCell *)[tableView cellForRowAtIndexPath:indexPath];
    {
        [cell.toggle setOn:!cell.toggle.on
                  animated:YES];
        [cell.toggle sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
