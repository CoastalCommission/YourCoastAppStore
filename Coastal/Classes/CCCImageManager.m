//
//  CCCImageManager.m
//  Coastal
//
//  Created by Rehat Kathuria on 09/06/2016.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCImageManager.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

@interface CCCImageManager()

@property (nonatomic, retain) NSOperationQueue *imageDownloadQueue;

@end

@implementation CCCImageManager

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        sharedManager = [[[self class] alloc] init];
    });
    
    return sharedManager;
}

- (void)imageForURL:(NSURL *)url forceFetch:(BOOL)shouldForceFetch completion:(void (^)(UIImage *, NSURL *))completion
{
    __weak typeof(self) weakSelf = self;

    NSString *key = [NSString stringWithFormat:@"%@", url.absoluteString];
    
    [[SDWebImageManager sharedManager] diskImageExistsForURL:url completion:^(BOOL isInCache) {

        if (isInCache == YES && shouldForceFetch == NO)
        {
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            completion(image, url);
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[self documentPathForURL:url]] && shouldForceFetch == NO)
        {
            UIImage *image = [self imageAtPath:[self documentPathForURL:url]];
            completion(image, url);
        }
        else
        {
            __block UIImage *completionBlockImage;

            if (weakSelf.imageDownloadQueue == nil)
            {
                weakSelf.imageDownloadQueue = [NSOperationQueue new];
            }

            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{

                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                [[SDImageCache sharedImageCache] storeImage:image forKey:key completion:nil];
                completionBlockImage = image;
            }];

            [operation setCompletionBlock:^{

                dispatch_async(dispatch_get_main_queue(), ^{

                    completion(completionBlockImage, url);
                });
            }];

            [weakSelf.imageDownloadQueue addOperation:operation];
        }
    }];
}

- (void)deleteImageAtPath:(NSString *)path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (UIImage *)imageAtPath:(NSString *)path
{
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:path];
    return [UIImage imageWithData:imageData];
}

- (void)saveImage:(UIImage *)image toPath:(NSString *)path
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData != nil)
    {
        [imageData writeToFile:path atomically:YES];
    }
}

- (NSString *)documentPathForURL:(NSURL *)url
{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] lastObject];
    return [documentsDirectory URLByAppendingPathComponent:url.lastPathComponent].path;
}

@end
