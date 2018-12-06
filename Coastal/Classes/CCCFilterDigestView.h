//
//  CCCFilterDigestView.h
//  Coastal
//
//  Created by Dai Hovey on 25/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCFilterDigestView : UIView

@property (nonatomic, strong) NSString *appliedFiltersText;
@property (nonatomic, strong) UILabel *filtersLabel;

-(void)filterStringWithFilters:(NSSet*)filters;

@end
