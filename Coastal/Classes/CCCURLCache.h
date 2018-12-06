//
//  CCCURLCache.h
//  Coastal
//
//  Created by Oliver White on 1/29/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

@import Foundation;

@interface CCCURLCache : NSObject

+ (instancetype)sharedCache;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;

- (void)setObject:(id)object
forKeyedSubscript:(id <NSCopying>)key;

@end
