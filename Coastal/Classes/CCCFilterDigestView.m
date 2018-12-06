//
//  CCCFilterDigestView.m
//  Coastal
//
//  Created by Dai Hovey on 25/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCFilterDigestView.h"
#import "CCCFilterCell.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCFilterDigestView ()

@end

@implementation CCCFilterDigestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel *staticLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frame.size.width, frame.size.height)];
        staticLabel.font = [UIFont ccc_filterDigestViewLabelFont];
        staticLabel.textColor = [UIColor blackColor];
        staticLabel.text = NSLocalizedString(@"Filtered by:", nil);
        [self addSubview:staticLabel];

        self.filtersLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, frame.size.width - 95, frame.size.height)];
        self.filtersLabel.font = [UIFont ccc_filterDigestViewLabelFont];
        self.filtersLabel.numberOfLines = 1;
        self.filtersLabel.textColor = [UIColor ccc_lightTextColor];
        [self addSubview:self.filtersLabel];
    }

    return self;
}

-(void) setAppliedFiltersText:(NSString *)appliedFiltersText
{
    self.filtersLabel.text = appliedFiltersText;
}

-(NSString*) combinedStringWithFilters:(NSSet*)filters
{
    NSMutableString *combinedString = [[NSMutableString alloc] init];
    NSString *modifiedFilter;
    NSInteger count = 0;

    for (NSString *filter in filters)
    {
        count ++;

        if (filters.count == count)
        {
            modifiedFilter = [NSString stringWithFormat:@"%@", [CCCFilterCell localizedStringForFilter:filter].capitalizedString];
        }
        else
        {
            modifiedFilter = [NSString stringWithFormat:@"%@, ", [CCCFilterCell localizedStringForFilter:filter].capitalizedString];
        }

        [combinedString appendString:modifiedFilter];
    }
    
    return combinedString;
}

-(void)filterStringWithFilters:(NSSet*)filters;
{
    NSString *combinedString = [self combinedStringWithFilters:filters];

    CGSize size = [combinedString sizeWithAttributes:@{NSFontAttributeName: self.filtersLabel.font}];
    size.width = ceilf(size.width);

    if (size.width < self.filtersLabel.frame.size.width)
    {
        self.appliedFiltersText = combinedString;
    }
    else
    {
        NSMutableSet *tempFilters = [NSMutableSet setWithSet:filters];

        __block NSMutableString *newCombinedString;

        BOOL(^doesNewStringFit)(BOOL) = ^(BOOL fits) {

            newCombinedString = [[NSMutableString alloc] initWithString:[self combinedStringWithFilters:tempFilters]];

            NSString *localizedNumber = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInteger:(filters.count - tempFilters.count)]
                                                                         numberStyle:0];

            NSString *moreString = [NSString stringWithFormat:@" +%@ %@...", localizedNumber, NSLocalizedString(@"more", nil)];

            [newCombinedString appendString:moreString];

            self.appliedFiltersText = newCombinedString;

            CGSize size = [newCombinedString sizeWithAttributes:
                           @{NSFontAttributeName: self.filtersLabel.font}];
            size.width = ceilf(size.width);

            if (size.width < self.filtersLabel.frame.size.width)
            {
                fits = YES;
            }
            else
            {
                fits = NO;
                [tempFilters removeObject:[tempFilters anyObject]];
            }
            return fits;
        };

        BOOL shouldStop = NO;
        while (shouldStop == NO)
        {
            shouldStop = doesNewStringFit(&shouldStop);
        }

        self.appliedFiltersText = newCombinedString;
    }
}

@end
