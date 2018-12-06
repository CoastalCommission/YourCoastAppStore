//
//  CCCImageManager.h
//  Coastal
//
//  Created by Rehat Kathuria on 09/06/2016.
//  Copyright © 2016 MetaLab. All rights reserved.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface CCCImageManager : NSObject

+ (instancetype)sharedManager;

- (void)imageForURL:(NSURL *)url forceFetch:(BOOL)shouldForceFetch completion:(void (^)(UIImage *image, NSURL *url))completion;

- (void)deleteImageAtPath:(NSString *)path;

- (UIImage *)imageAtPath:(NSString *)path;

- (void)saveImage:(UIImage *)image toPath:(NSString *)path;

- (NSString *)documentPathForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
