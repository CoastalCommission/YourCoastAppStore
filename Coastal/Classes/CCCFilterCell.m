//
//  CCCFilterCell.m
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFilterCell.h"
#import "CCCAccessPoint.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

NSString * const CCCFilterCellReuseIdentifier = @"CCCFilterCellReuseIdentifier";

@interface CCCFilterCell ()

@property (nonatomic, strong) UISwitch *toggle;

@property (nonatomic, strong) UIView *topSeparatorView;
@property (nonatomic, strong) UIView *bottomSeparatorView;

@end

@implementation CCCFilterCell

+ (NSString *)localizedStringForFilter:(NSString *)filter
{
    static NSDictionary *dictionary = nil;

    if (dictionary == nil)
    {
        dictionary = @{
                       kFee : NSLocalizedString(@"No Fees", nil),
                       kParking : NSLocalizedString(@"Parking", nil),
                       kDisabled : NSLocalizedString(@"Disabled Access", nil),
                       kVisitorCenter : NSLocalizedString(@"Visitor Center", nil),
                       kRestrooms : NSLocalizedString(@"Restrooms", nil),
                       kPicnicArea : NSLocalizedString(@"Picnic Area", nil),
                       kDogFriendly : NSLocalizedString(@"Dog Friendly", nil),
                       kCampground : NSLocalizedString(@"Campground", nil),
                       kStrollerFriendly : NSLocalizedString(@"Stroller Friendly", nil),
                       kVolleyball : NSLocalizedString(@"Volleyball", nil),
                       kSandyBeach : NSLocalizedString(@"Sandy Beach", nil),
                       kRockyShore : NSLocalizedString(@"Rocky Shore", nil),
                       kStairsToBeach : NSLocalizedString(@"Stairs to Beach", nil),
                       kBeachWheelchair: NSLocalizedString(@"Beach Wheelchair Access", nil),
                       kBluff : NSLocalizedString(@"Bluff", nil),
                       kTidepool: NSLocalizedString(@"Tidepools", nil),
                       kBikePath: NSLocalizedString(@"Bike Path", nil),
                       kPathToBeach : NSLocalizedString(@"Path to Beach", nil),
                       kBlufftopTrails : NSLocalizedString(@"Blufftop Trails", nil),
                       kBlufftopPark : NSLocalizedString(@"Blufftop Park", nil),
                       kDunes : NSLocalizedString(@"Dunes", nil),
                       kFishing : NSLocalizedString(@"Fishing", nil),
                       kWildLifeViewing : NSLocalizedString(@"Wildlife Viewing", nil),
                       kBoating : NSLocalizedString(@"Boating", nil),
                       kFavourites : NSLocalizedString(@"Favorites", nil),
                       kSearchForMoreInformation: NSLocalizedString(@"Search for info about this location", nil)
                       };
    }

    return dictionary[filter];
}

+ (UIImage *)largeIconForFilter:(NSString *)filter
{
    return [UIImage imageNamed:[[filter lowercaseString] stringByAppendingString:@"_large"]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        self.textLabel.font = [UIFont ccc_filterCellTextLabelFont];
        self.textLabel.textColor = [UIColor ccc_filterCellTextColor];

        self.imageView.contentMode = UIViewContentModeCenter;

        UISwitch *toggle = self.toggle = [[UISwitch alloc] init];
        {
            [toggle addTarget:self
                       action:@selector(updateValue)
             forControlEvents:UIControlEventValueChanged];
        }
        [self addSubview:toggle];

        UIView *topSeparatorView = self.topSeparatorView = [[UIView alloc] init];
        {
            topSeparatorView.backgroundColor = [UIColor ccc_lightSeparatorColor];
            topSeparatorView.hidden = YES;
        }
        [self.contentView addSubview:topSeparatorView];

        UIView *bottomSeparatorView = self.bottomSeparatorView = [[UIView alloc] init];
        {
            bottomSeparatorView.backgroundColor = [UIColor ccc_lightSeparatorColor];
        }
        [self.contentView addSubview:bottomSeparatorView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.delegate = nil;
    self.topCell = NO;
    self.toggle.on = NO;
}

static inline CGRect CCCCGRectCenterInRect(CGRect rect, CGRect containerRect)
{
    CGFloat x = CGRectGetMidX(containerRect) - roundf(CGRectGetWidth(rect) / 2.0);
    CGFloat y = CGRectGetMidY(containerRect) - roundf(CGRectGetHeight(rect) / 2.0);

    CGRect centeredRect = (CGRect){CGPointMake(x, y), rect.size};

    return centeredRect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = CGRectInset(self.contentView.bounds, 18.0, 0.0);

    CGRect slice = CGRectZero;
    CGRect remainder = CGRectZero;

    CGRectDivide(bounds, &slice, &remainder, 1.0, CGRectMinYEdge);
    self.topSeparatorView.frame = slice;

    CGRectDivide(bounds, &slice, &remainder, 1.0, CGRectMaxYEdge);
    self.bottomSeparatorView.frame = slice;

    [self.toggle sizeToFit];
    CGRectDivide(bounds, &slice, &remainder, CGRectGetWidth(self.toggle.frame), CGRectMaxXEdge);
    self.toggle.frame = CCCCGRectCenterInRect(self.toggle.frame, slice);

    CGRectDivide(remainder, &slice, &remainder, 29.0, CGRectMinXEdge);
    self.imageView.frame = slice;

    self.textLabel.frame = CGRectInset(remainder, 10.0, 0.0);
}

#pragma mark - Actions

- (void)setFilter:(NSString *)filter
{
    _filter = filter;

    self.textLabel.text = [[self class] localizedStringForFilter:_filter];
    self.imageView.image = [[self class] largeIconForFilter:_filter];
}

- (void)setTopCell:(BOOL)topCell
{
    _topCell = topCell;

    self.topSeparatorView.hidden = !_topCell;
}

- (void)updateValue
{
    [self.delegate filterCellDidUpdateValue:self];
}

@end
