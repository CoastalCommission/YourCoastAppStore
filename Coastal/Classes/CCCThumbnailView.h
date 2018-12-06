//
//  CCCThumbnailView.h
//  Coastal
//
//  Created by Aaron Williams on 2016-09-16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCCPhoto;
@protocol  CCCThumbnailViewDelegate;

@interface CCCThumbnailView : UIView

@property (nonatomic, weak) id<CCCThumbnailViewDelegate> delegate;
@property (nonatomic, assign) BOOL shouldDimUnselected;


- (void)addPhoto:(CCCPhoto *)photo;
- (void)scrollToImageAtIndex:(NSInteger)index;
- (void)setContentInset:(UIEdgeInsets)contentInset;

@end

@protocol CCCThumbnailViewDelegate <NSObject>

- (void)thumbnailView:(CCCThumbnailView *)thumbnailView didSelectImage:(CCCPhoto *)image AtIndex:(NSInteger)index;

@end
