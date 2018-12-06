//
//  CCCFilterView.h
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCFilterView : UIView

@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, readonly) UIBarButtonItem *resetButton;
@property (nonatomic, readonly) UIBarButtonItem *applyButton;

@property (nonatomic, readonly) UITableView *tableView;

@property (nonatomic, readonly) UILabel *countLabel;

@end
