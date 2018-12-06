//
//  CCCFilterCell.h
//  Coastal
//
//  Created by Malcolm on 2014-05-13.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CCCFilterCellReuseIdentifier;

@protocol CCCFilterCellDelegate;

@interface CCCFilterCell : UITableViewCell

@property (nonatomic, strong) NSString *filter;
@property (nonatomic, readonly) UISwitch *toggle;
@property (nonatomic, assign, getter = isTopCell) BOOL topCell;

@property (nonatomic, weak) id <CCCFilterCellDelegate> delegate;

+ (NSString *)localizedStringForFilter:(NSString *)filter;
+ (UIImage *)largeIconForFilter:(NSString *)filter;

@end

@protocol CCCFilterCellDelegate <NSObject>

- (void)filterCellDidUpdateValue:(CCCFilterCell *)filterCell;

@end
