//
//  CCCTourView.h
//  Coastal
//
//  Created by Ian Hoar on 2014-06-06.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCTourViewDelegate <NSObject>

- (void)tourDidComplete;

@end

@interface CCCTourView : UIView

@property (nonatomic, weak) id<CCCTourViewDelegate> delegate;

@end
