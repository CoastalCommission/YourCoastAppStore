//
//  CCCPhotosViewController.h
//  Coastal
//
//  Created by Aaron Williams on 2016-09-15.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "NYTPhotosViewController.h"
#import "CCCThumbnailView.h"

extern NSString * const CCCPhotosViewControllerWillNavigateToPhotoNotification;

@protocol CCCPhotosViewControllerDelegate;

@interface CCCPhotosViewController : NYTPhotosViewController
<
CCCThumbnailViewDelegate
>

@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (nonatomic, weak) id<CCCPhotosViewControllerDelegate, NYTPhotosViewControllerDelegate> delegate;

@end

@protocol CCCPhotosViewControllerDelegate <NYTPhotosViewControllerDelegate>

- (void)photosViewController:(CCCPhotosViewController *)photosViewController willNavigateToPhoto:(id <NYTPhoto>)photo atIndex:(NSUInteger)photoIndex;

@end
