//
//  CCCFeatureCell.h
//  Coastal
//
//  Created by Oliver White on 2/21/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import UIKit;

@interface CCCFeatureCell : UITableViewCell

@property (nonatomic, retain) UIImage *secondaryIconImage;
@property (nonatomic, assign) CGFloat adjustment;
@property (nonatomic, readonly) UITextView *detailTextView;

@end
