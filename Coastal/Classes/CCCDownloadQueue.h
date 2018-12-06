//
//  CCCDownloadQueue.h
//  Coastal
//
//  Created by Jeremy Petter on 4/25/17.
//  Copyright © 2017 MetaLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCDownloadQueue : NSObject

+ (instancetype)sharedQueue;

- (void)downloadQueuedImagesAndMaps;

@end
