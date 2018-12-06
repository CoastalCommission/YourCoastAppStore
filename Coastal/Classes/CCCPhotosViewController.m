//
//  CCCPhotosViewController.m
//  Coastal
//
//  Created by Aaron Williams on 2016-09-15.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCPhotosViewController.h"
#import "CCCPhoto.h"
#import "NYTPhotosDataSource.h"
#import "NYTPhotoContainer.h"

@interface CCCPhotosViewController ()
<
CCCThumbnailViewDelegate,
UIPageViewControllerDelegate
>

@property (nonatomic, strong) NYTPhotosDataSource *dataSource;

@end

@implementation CCCPhotosViewController

@dynamic dataSource;
@dynamic delegate;

- (instancetype)init
{
    self = [super init];

    if (self != nil)
    {
        self.shouldHideStatusBar = NO;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return self.shouldHideStatusBar;
}

#pragma mark - CCCThumbnailViewDelegate

- (void)thumbnailView:(CCCThumbnailView *)thumbnailView didSelectImage:(CCCPhoto *)image AtIndex:(NSInteger)index
{
    [thumbnailView scrollToImageAtIndex:index];
    [self displayPhoto:image animated:NO];
}

#pragma mark - CCCPhotosViewControllerDelegate

- (void)willNavigateToPhoto:(id<NYTPhoto>)photo
{
    if ([self.delegate respondsToSelector:@selector(photosViewController:willNavigateToPhoto:atIndex:)])
    {
        [self.delegate photosViewController:self willNavigateToPhoto:photo atIndex:[self.dataSource indexOfPhoto:photo]];
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    UIViewController <NYTPhotoContainer> *photoViewController = (UIViewController <NYTPhotoContainer> *)pendingViewControllers.firstObject;
    [self willNavigateToPhoto:photoViewController.photo];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self willNavigateToPhoto:self.currentlyDisplayedPhoto];
}

@end
