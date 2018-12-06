//
//  CCCTitleView.h
//  Coastal
//
//  Created by Malcolm on 2014-05-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLXButton;

@interface CCCSearchBarView : UIView

@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, readonly) UIButton *cancelSearchButton;
@property (nonatomic, readonly) UIButton *filterButton;

- (void)setSearching:(BOOL)searching
            animated:(BOOL)animated;

@end
