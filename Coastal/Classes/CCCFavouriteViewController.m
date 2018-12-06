//
//  CCCFavouriteViewController.m
//  Coastal
//
//  Created by Dai Hovey on 18/12/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFavouriteViewController.h"
#import "CCCSearchResultCell.h"
#import "CCCSearchAccessPoint.h"
#import "CCCAccessPoint.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"
#import "GTMNSString+HTML.h"

@interface CCCFavouriteViewController ()

@end

@implementation CCCFavouriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Favorites", nil);

    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView.separatorColor = [UIColor ccc_lightSeparatorColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;

    [self.tableView registerClass:[CCCSearchResultCell class]
           forCellReuseIdentifier:CCCSearchResultCellReuseIdentifier];
}

-(void) setFavourites:(NSArray *)favourites
{
    _favourites = favourites;

    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.favourites count] == 0)
    {
        return self.view.frame.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.favourites count] == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
        {
            view.backgroundColor = [UIColor whiteColor];

            UIImage *favImage = [UIImage imageNamed:@"FavouritesZeroState"];
            UIImageView *favouriteIcon = [[UIImageView alloc] initWithImage:favImage];
            favouriteIcon.contentMode = UIViewContentModeCenter;
            favouriteIcon.frame = CGRectMake(0, -favImage.size.height, view.bounds.size.width, view.bounds.size.height);
            [view addSubview:favouriteIcon];

            CGRect initialFrame = self.view.frame;
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 70, 0, 70);
            CGRect paddedFrame = UIEdgeInsetsInsetRect(initialFrame, contentInsets);

            UILabel *label = [[UILabel alloc] initWithFrame:paddedFrame];
            {
                label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                label.numberOfLines = 2;
                label.font = [UIFont ccc_zeroLabelFont];
                label.textColor = [UIColor ccc_darkTextColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = NSLocalizedString(@"Your Favorites Will Live Here", nil);
            }
            [view addSubview:label];
        }
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *accessPoint = self.favourites[indexPath.row];

    [self.delegate favouriteViewController:self didSelectAccessPoint:accessPoint];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favourites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CCCSearchResultCellReuseIdentifier
                                                                forIndexPath:indexPath];
    {
        cell.imageView.image = nil;

        NSDictionary *accessPoint = self.favourites[indexPath.row];
        cell.textLabel.text = [accessPoint[kName] gtm_stringByUnescapingFromHTML];

        CGFloat distance = [accessPoint[kDistance] doubleValue];
        cell.detailTextLabel.text = ((distance - DBL_EPSILON) > 0.0) ? [[NSString alloc] initWithFormat:@"%.1fmi", distance] : nil;
    }
    return cell;
}

@end
