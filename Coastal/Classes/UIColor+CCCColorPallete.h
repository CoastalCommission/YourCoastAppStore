//
//  UIColor+CCCColorPallete.h
//  Coastal
//
//  Created by Cezar on 24/05/16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CCCColorPallete)

+ (UIColor *)ccc_blackTextColor;
+ (UIColor *)ccc_darkTextColor;
+ (UIColor *)ccc_darkGrayTextColor;
+ (UIColor *)ccc_lightTextColor;
+ (UIColor *)ccc_lightHighlightedTextColor;
+ (UIColor *)ccc_lightBackgroundColor;

+ (UIColor *)ccc_separatorColor;
+ (UIColor *)ccc_lightSeparatorColor;

+ (UIColor *)ccc_grayColor;
+ (UIColor *)ccc_lightGrayColor;
+ (UIColor *)ccc_veryLightGrayColor;

+ (UIColor *)ccc_blueButtonColor;
+ (UIColor *)ccc_tourViewLightTextColor;
+ (UIColor *)ccc_tourViewDarkBackgroundColor;
+ (UIColor *)ccc_navigationBarBlueTintColor;
+ (UIColor *)ccc_filterViewBlueColor;
+ (UIColor *)ccc_filterViewHighlightedBlueColor;
+ (UIColor *)ccc_activeSearchBarBlueBackgroundColor;
+ (UIColor *)ccc_inactiveSearchBarBlueBackgroundColor;

+ (UIColor *)ccc_redOverlayColor;

+ (UIColor *)ccc_imageButtonTitleColor;
+ (UIColor *)ccc_imageButtonHighlightedTitleColor;
+ (UIColor *)ccc_filterCountLabelDarkTextColor;
+ (UIColor *)ccc_filterCellTextColor;

@end

NS_ASSUME_NONNULL_END
