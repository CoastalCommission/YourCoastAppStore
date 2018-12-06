//
//  CCCAccessPointImagesCell.h
//  Coastal
//
//  Created by Aaron Williams on 2016-09-08.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCCThumbnailView;
@class CCCPhoto;

@interface CCCAccessPointImagesCell : UITableViewCell

@property (nonatomic, readonly) CCCThumbnailView *thumbnailView;
@property (nonatomic, readonly) NSArray *photos;

- (instancetype)initWithPhotos:(NSArray<CCCPhoto *> *)photos;

@end
