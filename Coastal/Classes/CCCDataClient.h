//
//  CCCDataClient.h
//  Coastal
//
//  Created by Oliver White on 1/28/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import UIKit;
@import MobileCoreServices;

@interface CCCDataClient : NSObject

+ (void)getAccessPoints:(void (^)(NSArray *accessPoints, BOOL cached))completion;

+ (void)getAccessPoint:(NSNumber *)identifier
            completion:(void (^)(NSDictionary *))completion;

@end
