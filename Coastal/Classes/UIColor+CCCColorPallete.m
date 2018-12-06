//
//  UIColor+CCCColorPallete.m
//  Coastal
//
//  Created by Cezar on 24/05/16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "UIColor+CCCColorPallete.h"

@implementation UIColor (CCCColorPallete)

+ (UIColor *)ccc_blackTextColor
{
    return [UIColor colorWithWhite:5.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_darkTextColor
{
    return [UIColor colorWithWhite:50.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_darkGrayTextColor
{
    return [UIColor colorWithWhite:84.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_lightTextColor
{
    return [UIColor colorWithWhite:156.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_lightHighlightedTextColor
{
    return [UIColor colorWithWhite:230.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_lightBackgroundColor
{
    return [UIColor colorWithWhite:245.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_separatorColor
{
    return [UIColor colorWithWhite:220.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_lightSeparatorColor
{
    return [UIColor colorWithWhite:233.0/255.0 alpha:1.0];
} 

+ (UIColor *)ccc_grayColor
{
    return [UIColor colorWithWhite:92.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_lightGrayColor
{
    return [UIColor colorWithWhite:165.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_veryLightGrayColor
{
    return [UIColor colorWithWhite:204.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_blueButtonColor
{
    return [UIColor colorWithRed:27.0/255.0 green:157.0/255.0 blue:232.0/255.0 alpha:1.0];
}

+ (UIColor *)ccc_tourViewLightTextColor
{
    return [UIColor colorWithRed:0.937 green:0.953 blue:0.953 alpha:1];
}

+ (UIColor *)ccc_tourViewDarkBackgroundColor
{
    return [UIColor colorWithRed:0.212 green:0.235 blue:0.247 alpha:1.000];
}

+ (UIColor *)ccc_navigationBarBlueTintColor
{
    return [UIColor colorWithRed:0.153 green:0.635 blue:0.973 alpha:1.000];
}

+ (UIColor *)ccc_filterViewBlueColor
{
    return [UIColor colorWithRed:0.165 green:0.627 blue:0.902 alpha:1.000];
}

+ (UIColor *)ccc_filterViewHighlightedBlueColor
{
    return [UIColor colorWithRed:0.059 green:0.492 blue:0.749 alpha:1.000];
}

+ (UIColor *)ccc_activeSearchBarBlueBackgroundColor
{
    return [UIColor colorWithRed:28.0/255.0 green:123.0/255.0 blue:193.0/255.0 alpha:1.000];
}

+ (UIColor *)ccc_inactiveSearchBarBlueBackgroundColor
{
    return [UIColor colorWithRed:33.0/255.0 green:153.0/255.0 blue:237.0/255.0 alpha:1.000];
}

+ (UIColor *)ccc_redOverlayColor;
{
    return [UIColor colorWithRed:244.0/255.0 green:80.0/255.0 blue:40.0/255.0 alpha:0.8];
}

+ (UIColor *)ccc_imageButtonTitleColor
{
    return [UIColor colorWithRed:0.216 green:0.212 blue:0.212 alpha:0.500];
}

+ (UIColor *)ccc_imageButtonHighlightedTitleColor
{
    return [UIColor colorWithRed:0.216 green:0.212 blue:0.212 alpha:1.000];
}

+ (UIColor *)ccc_filterCountLabelDarkTextColor
{
    return [UIColor colorWithRed:0.208 green:0.212 blue:0.216 alpha:1.000];
}

+ (UIColor *)ccc_filterCellTextColor
{
    return [UIColor colorWithRed:0.514 green:0.529 blue:0.537 alpha:1.000];
}

@end
