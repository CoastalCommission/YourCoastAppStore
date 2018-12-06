//
//  CCCCalloutView.h
//  Coastal
//
//  Created by Dai Hovey on 30/01/2015.
//  Copyright (c) 2015 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCCalloutView : UIView

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, assign) CGFloat arrowHeight;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
